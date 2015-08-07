require 'rails_helper'

RSpec.describe ProductScraperJob, type: :job do
  let(:user) { create :confirmed_user }
  let(:echo_url){ PRODUCTS_LIST[:amazon_echo][:url] }
  let(:echo_pid){ PRODUCTS_LIST[:amazon_echo][:pid] }

  it 'queues the product in background queue' do
    expect {
      described_class.perform_async(1, 'http://some.url')
    }.to change(described_class.jobs, :size).by(1)
  end

  it 'creates a new product for the given user and url', :vcr do
    described_class.perform_async(user.id, echo_url)
    expect(Product.find_by(pid: echo_pid)).to be_nil

    described_class.drain # run the queued jobs
    product = Product.find_by(pid: echo_pid)
    expect(product).to be_present
    expect(product.founder).to eq user
  end

  # FIXME: not really sure how to test this in a correct manner
  it 'expiration for job status is moderately timed' do
    expect(described_class.new.expiration).to be >= 60
  end

  # NOTE: Sidekiq tests don't run server middleware.
  # Read More: https://github.com/mperham/sidekiq/issues/1846
  # Read More: spec/support/sidekiq.rb
  it 'returns the current status of the job' do
    jid = described_class.perform_async(user.id, echo_url)
    expect(Sidekiq::Status.status(jid)).to eq(:queued)

    described_class.drain

    expected = { 'id' => Product.last.to_param }
    expect(Sidekiq::Status.status(jid)).to eq(:complete)
    expect(Sidekiq::Status.get_all(jid)).to include(expected)
  end

  it 'returns validation errors when creating the product' do
    service = double(Object)
    allow(ProductMigratingService).to receive(:new).and_return(service)
    allow(service).to receive(:run).and_return(errors: ["Name can't be blank"])

    jid = described_class.perform_async(user.id, echo_url)
    described_class.drain

    expect(Sidekiq::Status.status(jid)).to eq(:complete)
    expect(Sidekiq::Status.get_all(jid)).to include('errors' => "<li>Name can't be blank</li>")
  end

  it 'catches scraper errors and returns them as error messages' do
    jid = described_class.perform_async(user.id, 'http://url.to/not-implemented/')
    err = 'Merchant not implemented.'

    expect { described_class.drain }.to raise_error(ProductScraper::Error).with_message(err)

    expect(Sidekiq::Status.status(jid)).to eq(:failed)
    expect(Sidekiq::Status.get_all(jid)).to include('errors' => "<li>#{err}</li>")
  end
end
