class Antraege < ActiveRecord::Base
  include Geodata

  attr_accessible :begruendung, :betreff, :datum, :ergebnisse, :title, :verfasser, :link, :federfuehrend, :kommune, :content, :lat, :long, :last_updated, :check

  has_many :comments, as: :commentable
  has_and_belongs_to_many :categories, join_table: 'categories_antraeges'

  has_many :consultations, class_name: 'AntraegeConsultation'

  scope :search, ->(text) do
    where('title ILIKE ? or content ILIKE ?', "%#{text}%", "%#{text}%")
  end

  scope :recent, limit(3).order("last_updated desc")
  scope :with_location, ->{ where("lat != ''") }
  scope :created_after, ->(timestamp) { where('created_at > ?', timestamp) }
  scope :updated_after, ->(timestamp) { where('created_at <= ?', timestamp).where('updated_at > ?', timestamp) }

end