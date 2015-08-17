class User < ActiveRecord::Base
  include Sluggable

  has_many :found_products, dependent: :nullify, autosave: true, class_name: "Product", foreign_key: "founder_id"
  has_many :identities

  acts_in_relation role: :self, action: :follow, target: :user
  acts_in_relation role: :source, target: :product, action: :like

  devise :database_authenticatable, :registerable, :omniauthable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable, omniauth_providers: [:facebook, :twitter, :google_plus]
         # authentication_keys: [:login],

  validates :name, presence: true
  validates :username, presence: true, uniqueness: { case_sensitive: false }
  validates_format_of :username, with: /\A[a-z0-9]+\z/i, message: "can have letters and numbers only."

  def to_s
    login
  end

  def to_param
    username
  end

  def login=(login)
    @login = login
  end

  def login
    @login || username || email
  end

  def has_identity?(name)
    identities.where(provider: name).exists?
  end

  def merge_data_from_omniauth(auth)
    auth = auth.is_a?(Extractor::Base) ? auth.attributes_data : auth
    auth = Hash[auth.map{|k,v| [k.to_s,v]}]
    self.email    = auth["email"] if self.email.blank?
    self.name     = auth["name"]  if self.name.blank?
    self.image    = auth["image"] if self.image.blank?
    self.gender   = auth["gender"] if self.gender.blank?
    self.username = auth["username"] if self.username.blank?
    # self.language = auth["language"] if self.language.blank?
    # self.timezone_offset = auth["timezone_offset"] if self.timezone_offset.blank?
    self
  end

  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    conditions[:email].downcase! if conditions[:email].present?

    if login = conditions.delete(:login)
      sql = "lower(username) = :value OR lower(email) = :value"
      where(conditions).where([sql, { value: login.downcase }]).first
    else
      where(conditions).first
      # if conditions[:username].nil?
      #   where(conditions).first
      # else
      #   where(username: conditions[:username]).first
      # end
    end
  end

  def self.confirm_via_omniauth(auth)
    auth = Extractor::Base.load(auth)
    find_by(email: auth.email).tap do |user|
      if user.present?
        user.confirm
        user.merge_data_from_omniauth(auth).save
      end
    end
  end

  def self.create_from_omniauth(auth)
    auth = Extractor::Base.load(auth)
    new(email: auth.email, name: auth.name, username: auth.username).tap do |user|
      user.password = user.password_confirmation = Devise.friendly_token[0,20]
      user.skip_confirmation! if user.email.present?
      user.merge_data_from_omniauth(auth).save
    end
  end

  def self.new_with_session(params, session)
    super.tap do |user|
      auth = session["devise.oauth_data"]
      if auth.present?
        user.merge_data_from_omniauth(auth)
        user.identities.build auth
        user.skip_confirmation! if auth["email"] && user.email == auth["email"]
      end
    end
  end

  private

  def slug_candidates
    [ :username, :name ]
  end
end
