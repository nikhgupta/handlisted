OmniAuth.config.test_mode = true
OmniAuth.config.mock_auth[:facebook] = OmniAuth::AuthHash.new(
  provider: 'facebook',
  uid: '12345',
  info: {
    name: 'Test Facebook User',
    email: 'testuser@facebook.com',
    image: 'http://url.to/profile-image.jpg',
    verified: true,
    urls: { Facebook: "https://facebook.com/testuser" },
  },
  credentials: {
    token: "some-token", expires_at: 4.hours.since, expires: true
  },
  extra: {
    raw_info: { gender: "female", timezone: "3.5", locale: "fr_FR" }
  }
)

OmniAuth.config.mock_auth[:twitter] = OmniAuth::AuthHash.new(
  provider: "twitter",
  uid: "12345",
  info: {
    nickname: "testusername",
    name: "Test Twitter User",
    image: "http://url.to/profile-image.jpg",
    urls: {
      Twitter: "https://twitter.com/testusername"
    }
  },
  credentials: {
    token: "some-token", secret: "some-secret"
  },
  extra: {
    access_token: "some-long-data",
    raw_info: {
      utc_offset: 19800,
      verified: true,
      lang: "fr"
    }
  }
)

OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(
  provider: "github",
  uid: "12345",
  info: {
    nickname: "testusername",
    email: "testuser@github.com",
    name: "Test Github User",
    image: "http://url.to/profile-image.jpg",
    urls: {
      GitHub: "https://github.com/testusername"
    }
  },
  credentials: {
    token: "some-token", expires: false
  },

  extra: {
    raw_info: { has_a_lot_of_irrelevant_info: true }
  }
)

OmniAuth.config.mock_auth[:google] = OmniAuth::AuthHash.new(
  provider: "google",
  uid: "12345",
  info: {
    name: "Test Google User",
    email: "testuser@google.com",
    image: "http://url.to/profile-image.jpg",
    urls: {
      Google: "http://plus.google.com/some-profile-id"
    }
  },
  credentials: {
    token: "some-long-token" * 100,
    refresh_token: "some-refresh-token",
    expires_at: 4.hours.since,
    expires: true
  },
  extra: {
    raw_info: {
      gender: "female",
      email_verified: "true",
      locale: "fr"
    }
  }
)

OmniAuth.config.mock_auth[:linkedin] = OmniAuth::AuthHash.new(
  provider: "linkedin",
  uid: "12345",
  info: {
    name: "Test Linkedin User",
    email: "testuser@linkedin.com",
    image: "http://url.to/profile-image.jpg",
    urls: {
      public_profile: "https://www.linkedin.com/in/testusername"
    }
  },
  credentials: {
    token: "some-token" * 100,
    expires_at: 4.hours.since,
    expires: true
  },
  extra: {
    raw_info: { has_irrelevant_information: true }
  }
)

OmniAuth.config.mock_auth[:foursquare] = OmniAuth::AuthHash.new(
  provider: "foursquare",
  uid: "12345",
  info: {
    name: "Test Foursquare User",
    email: "testuser@foursquare.com",
    image: {
      prefix: "http://url.to/",
      suffix: "/profile-image.jpg",
      default: true
    }
  },
  credentials: {
    token: "some-token",
    expires: false
  },
  extra: {
    raw_info: {
      gender: "female",
    }
  }
)
