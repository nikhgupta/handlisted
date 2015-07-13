class Identity < ActiveRecord::Base
  belongs_to :user, dependent: :destroy

  # validates :user_id, presence: true
  validates :user, associated: true, presence: true
  validates :token, presence: true
  validates :uid, uniqueness: {
    scope: :provider,
    message: 'already exists for this provider'
  }

  def self.find_with_omniauth(auth)
    find_by Extractor::Base.load(auth).signature
  end

  def self.initialize_with_omniauth(auth)
    new Extractor::Base.load(auth).attributes_data
  end

  def self.find_or_initialize_with_omniauth(auth)
    identity = find_with_omniauth auth
    return identity if identity.present?
    initialize_with_omniauth auth
  end

  def linked?
    user.present?
  end

  def linked_with?(user)
    linked? && self.user == user
  end

  def link_with(user)
    return false if linked?
    self.user = user
    save
  end

  def link_with!(user)
    self.user = nil
    link_with user
  end
end
