class Services::MailchimpController < ApplicationController
  respond_to :js

  def subscribe
    @email   = params[:email]
    @list_id = ENV['MAILCHIMP_DEFAULT_LIST_ID']
    MailchimpSubscriptionJob.perform_async @email, @list_id
  end
end
