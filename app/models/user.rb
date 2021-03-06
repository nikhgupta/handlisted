class User < ActiveRecord::Base
  has_merit

  include Sluggable

  has_many :found_products, dependent: :nullify, autosave: true, class_name: "Product", foreign_key: "founder_id"
  has_many :identities, dependent: :destroy

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
    username.downcase
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

  def likes_gained_count
    products = found_products.includes(:likes_as_target)
    products.map{|fp| fp.likes_as_target_ids.count}.sum
  end

  def likes_count
    liking_ids.count
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
    find_by(email: auth.email).tap do |user|
      if user.present?
        user.confirm
        user.merge_data_from_omniauth(auth).save
      end
    end
  end

  def self.create_from_omniauth(auth)
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

  # NOTE: following checks are used by Merit for awarding Badges.
  # OPTIMIZE: Probably, it will be wise to put them into separate concern?
  def is_developer?
    HandListed::Facts::DEVELOPER_EMAILS.include? email
  end

  def is_alpha_user?
    !is_developer? && created_at < HandListed::Facts::BETA_STARTED_ON
  end

  def is_beta_user?
    !is_developer? && !is_alpha_user? &&
      (created_at < HandListed::Facts::LAUNCHED_ON)
  end

  def is_new_user?
    !is_developer? && !is_alpha_user? && !is_beta_user? &&
      (sign_in_count < 10 || created_at > 30.days.ago)
  end

  def has_completed_profile_information?
    profile_fields  = [:name, :email, :gender, :image]
    profile_fields.all?{ |field| send(field).present? }
  end

  private

  def slug_candidates
    [ :username, :name ]
  end
end
