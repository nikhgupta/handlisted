class GooglePlusExtractor < Extractor::Base

  def self.reauth_hash
    { prompt: 'consent' }
  end

  def name
    auth["info"]["name"]
  end

  def username
    match = email.match(/^(.*)@(?:gmail|google|googlemail)\.com/)
    match[1] if match.present?
  end

  # present if user provided email permission
  def email
    auth["info"]["email"]
  end

  def image
    auth["info"]["image"]
  end

  def credentials
    cred = auth["credentials"]
    super.merge token: cred["token"],
      refresh_token: cred["refresh_token"],
      expires_at: cred["expires_at"]
  end

  def gender
    auth["extra"]["raw_info"]["gender"]
  end

  def verified
    auth["extra"]["raw_info"]["email_verified"] == "true"
  end

  def language
    auth["extra"]["raw_info"]["locale"]
  end

  def url
    auth["info"]["urls"]["Google"]
  end
end
