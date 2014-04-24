class Neuigkeiten < ActiveRecord::Base

  attr_accessible :content, :datum, :title, :user_id, :guid, :feed_name, :pubDate,
    :description, :link, :initiative_id, :date, :latitude, :longitude, :openinghours, :postalcode, :street, :city

  belongs_to :user
  belongs_to :initiative

  scope :recent, limit(3).order("created_at desc")
  validates :title, :length => { :maximum => 250, :message => :maximum_title}
  validates :street, :length => { :maximum => 250, :message => :maximum_street}
  validates :city, :length => { :maximum => 250, :message => :maximum_city}

  def self.create_from_xml(name, item)
    model = where(feed_name: name, guid: item['id']).first
    if model
      return if Time.parse(model.pubDate) >= Time.parse(item['lastmod'])
    else
      model = new(feed_name: name, guid: item['id'])
    end

    geo = item.css('location geo').first

    model.update_attributes!(title: item.search('title').first.content,
      description: item.search('abstract').first.try(:content), pubDate: item['lastmod'],
      link: item.search('href').first.try(:content), datum: item.css('date start').first.try(:content), openinghours: item.search('openinghours').first.try(:content), postalcode: item.search('postalcode').first.try(:content),
      street: item.search('street').first.try(:content), city: item.search('city').first.try(:content),
      latitude: geo && geo.search('latitude').first.content, longitude: geo && geo.search('longitude').first.content)
  end

end
