class Services::NewsletterSubscriptionJob
  include Sidekiq::Worker

  def perform(email, list_id)
    user = User.find_by(email: email)
    subscribe_via_mailchimp(email, user, list_id: list_id, status: 'pending')
  end

  private

  def subscribe_via_mailchimp(email, user = nil, options = {})
    list_id = options.delete(:list_id)
    first_name, last_name = user.name.to_s.split(" ", 2) if user.present?
    data = user ? { "FNAME" => first_name, "LNAME" => last_name } : {}
    data = { email_address: email, merge_fields: data }.merge(options)

    request = Gibbon::Request.lists(list_id)
    request = request.members(Digest::MD5.hexdigest(email))
    request.upsert(body: data)
  end
end
