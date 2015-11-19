require 'rails_helper'

RSpec.describe MailchimpSubscriptionJob, type: :job do
  let(:user) { create :confirmed_user, email: "registered@example.com", name: "Some Great User" }

  it 'queues the subscription in background queue' do
    expect {
      described_class.perform_async("someone@example.com", 'abcdef')
    }.to change(described_class.jobs, :size).by(1)
  end

  context "subscribe to Mailchimp via Gibbon" do
    after(:each) do
      request = double("request")
      expect(Gibbon::Request).to receive(:new).and_return request
      expect(request).to receive(:lists).with("abcdef").and_return request
      expect(request).to receive(:members).with(@digest).and_return request
      expect(request).to receive(:upsert).with(@data)

      described_class.drain
    end

    it 'sends email address without any extra info for guests' do
      described_class.perform_async("someone@example.com", "abcdef")
      @digest  = Digest::MD5.hexdigest("someone@example.com")
      @data    = { body: {
        email_address: "someone@example.com",
        status: "pending", merge_fields: {}
      }}
    end

    it 'sends email address along with other data for registered users' do
      described_class.perform_async(user.email, "abcdef")
      @digest  = Digest::MD5.hexdigest("registered@example.com")
      @data    = { body: {
        email_address: "registered@example.com", status: "pending",
        merge_fields: { "FNAME" => "Some", "LNAME" => "Great User"}
      }}
    end
  end
end
