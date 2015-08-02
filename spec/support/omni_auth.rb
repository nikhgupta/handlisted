MOCK_OMNIAUTH_CONFIG = {
  facebook: {
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
  }, twitter: {
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
  }, google_plus: {
    provider: "google_plus",
    uid: "12345",
    info: {
      name: "Test Google User",
      email: "testuser@google_plus.com",
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
  }
}
