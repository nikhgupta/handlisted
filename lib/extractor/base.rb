# Read: https://sethvargo.com/authorizers-extractors-and-policy-objects/
module Extractor
  class Error < StandardError; end
  class Base
    class << self
      def class_for(provider)
        provider = provider.to_s.camelize
        begin
          "#{provider}Extractor".constantize
        rescue NameError
          raise Error, "#{provider} is not a valid extractor!"
        end
      end

      def load(auth)
        class_for(auth['provider']).new(auth)
      end

      def reauth_hash; {}; end
    end

    attr_reader :auth

    def initialize(auth)
      @auth = auth
    end

    def signature
      { provider: provider, uid: uid }
    end

    def attributes_data
      {
        provider: provider,
        uid: uid,
        url: url,
        name: name,
        email: email,
        username: username,
        image: image,
        gender: gender,
        verified: verified,
        timezone_offset: timezone_offset.to_i,
        language: language,
        token: credentials[:token],
        secret: credentials[:secret],
        refresh_token: credentials[:refresh_token],
        expires_at: credentials[:expires_at]
      }
    end

    def uid
      auth['uid']
    end

    def provider
      auth['provider']
    end

    def name; end
    def username; end
    def email; end
    def image; end
    def gender; end
    def timezone_offset; 0; end
    def language; end
    def url; end
    def verified; false; end
    def credentials
      { token: nil, secret: nil, refresh_token: nil, expires_at: nil }
    end
  end
end

