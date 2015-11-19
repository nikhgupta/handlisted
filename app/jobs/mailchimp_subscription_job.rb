class MailchimpSubscriptionJob
  include Sidekiq::Worker

  def perform(email, list_id)
    user = User.find_by(email: email)
    first_name, last_name = user.name.to_s.split(" ", 2) if user.present?
    data = user ? { "FNAME" => first_name, "LNAME" => last_name } : {}
    data = { body: { email_address: email, status: "pending", merge_fields: data } }
    request = Gibbon::Request.lists(list_id)
    request = request.members(Digest::MD5.hexdigest(email))
    request.upsert(data)
  end
end
