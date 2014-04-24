class Construction < ActiveRecord::Base
  include Geodata

  attr_accessible :title, :city, :subtitle, :end_date, :organisation, :exact_position, :approx_timeframe, :start_date, :lat, :long, :_id, :sidewalk_only, :name, :last_updated, :content, :description

  scope :recent, limit(3).order("start_date desc")
  scope :with_location, ->{ where("lat != ''") }
  scope :current, ->{ where("start_date <= ? and end_date >= ?", Time.now, Time.now) }

end
