class TwitterExtractor < Extractor::Base

  def self.reauth_hash
    { force_login: true }
  end

  def name
    auth["info"]["name"]
  end

  def username
    auth["info"]["nickname"]
  end

  # twitter does not disclose email
  def email; end

  def image
    auth["info"]["image"]
  end

  def credentials
    cred = auth["credentials"]
    super.merge token: cred["token"], secret: cred["secret"]
  end

  def verified
    auth["extra"]["raw_info"]["verified"]
  end

  def timezone_offset
    auth["extra"]["raw_info"]["utc_offset"].to_i
  end

  def language
    auth["extra"]["raw_info"]["lang"]
  end

  def url
    auth["info"]["urls"]["Twitter"]
  end
end
