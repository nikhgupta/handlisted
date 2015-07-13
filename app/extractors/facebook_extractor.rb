class FacebookExtractor < Extractor::Base

  def self.reauth_hash
    { auth_type: "reauthenticate" }
  end

  def name
    auth["info"]["name"]
  end

  # Facebook does not disclose username anymore
  def username; end

  # present if user provided email permission
  def email
    auth["info"]["email"]
  end

  def image
    auth["info"]["image"]
  end

  def credentials
    cred = auth["credentials"]
    super.merge token: cred["token"], expires_at: cred["expires_at"]
  end

  def gender
    auth["extra"]["raw_info"]["gender"]
  end

  def verified
    auth["info"]["verified"]
  end

  def timezone_offset
    auth["extra"]["raw_info"]["timezone"].to_f * 3600
  end

  def language
    auth["extra"]["raw_info"]["locale"].split("_")[0] rescue nil
  end

  def url
    auth["info"]["urls"]["Facebook"]
  end
end
