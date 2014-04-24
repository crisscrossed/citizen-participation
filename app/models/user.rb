class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  attr_accessible :email, :password, :password_confirmation, :avatar, :remove_avatar, :remember_me, :username, :public_fields, :kommune, :verein, :partei, :polit_amt, :verwaltung, :nutzungsbedingung, :ortsteil, :jahrgang, :notes, :kommune_name
  has_many :sympathies, :class_name => "Supporter", :dependent => :destroy
  has_many :subscriptions, :dependent => :destroy
  has_many :quarter_subscriptions, :dependent => :destroy

  validates_uniqueness_of :username, :case_sensitive => false
  validates_presence_of :nutzungsbedingung
  validates_presence_of :kommune

  mount_uploader :avatar, AvatarUploader
  has_many :initiatives
  has_many :neuigkeiten

  has_many :comments, :dependent => :destroy

  scope :moderators, -> { where(role: 'moderator') }

  def superadmin?
    role == 'superadmin'
  end

  def admin?
    role == 'admin'
  end

  def moderator?
    role == 'moderator'
  end

  def blocked?
    role == 'blocked'
  end

  def public_fields
    (super || '').split(',')
  end

  def public_fields=(fields)
    super(Array(fields).join(','))
  end

  def all_fields
    %w(username kommune_name ortsteil_name verein partei polit_amt verwaltung)
  end

  def always_visible_fields
    %w(username kommune_name)
  end

  def fields_visible_to(user)
    if user && (user.moderator? || user.admin? || user.superadmin?)
      all_fields
    else
      visible_fields = (always_visible_fields + public_fields)
      all_fields.select { |f| visible_fields.include?(f) }
    end
  end

  def ortsteil_name
    Quarter.find(ortsteil).name if ortsteil.present?
  end

  def update_with_password(params={})
    if params[:password].blank?
      params.delete(:password)
      params.delete(:password_confirmation) if params[:password_confirmation].blank?
    end
    update_attributes(params)
  end

end
