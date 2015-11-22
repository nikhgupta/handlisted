module EmailHelpers
  def deliveries
    ActionMailer::Base.deliveries
  end

  def deliver_enqueued_emails
    Sidekiq::Extensions::DelayedMailer.drain
  end

  def last_email
    deliveries.last
  end

  def recipients_for_last_email
    last_email.to.map(&:to_s)
  end

  def sender_for_last_email
    last_email.from
  end

  def subject_for_last_email
    last_email.subject
  end

  def emails_for(email)
    deliveries.select{ |message| message.to.include?(email) }
  end

  def links_in_last_email
    body = (last_email.text_part || last_email.html_part || last_email).body.to_s
    links = URI.extract(body.to_s, ['http', 'https'])
    links.map{|url| URI.decode(url) }.uniq
  end

  def click_first_link_in_last_email
    visit links_in_last_email.first
  end

  def click_first_link_matching(regex_or_string)
    if regex_or_string.is_a? Regexp
      visit links_in_last_email.detect{|url| url =~ regex_or_string}
    else
      visit links_in_last_email.detect{|url| url.include? regex_or_string}
    end
  end
end
