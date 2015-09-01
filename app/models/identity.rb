class Identity < ActiveRecord::Base
  belongs_to :user

  # validates :user_id, presence: true
  validates :user, associated: true, presence: true
  validates :token, presence: true
  validates :uid, uniqueness: {
    scope: :provider,
    message: 'already exists for this provider'
  }

  def self.find_with_omniauth(auth)
    find_by auth.signature
  end

  def self.initialize_with_omniauth(auth)
    new auth.attributes_data
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

  def link_with(user, auth_data = nil)
    return false if linked?
    self.user = user
    user.merge_data_from_omniauth(auth_data).save if auth_data
    save
  end

  def link_with!(user, auth_data = nil)
    self.user = nil
    link_with user, auth_data
  end
end
