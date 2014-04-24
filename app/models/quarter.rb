class Quarter
  include Cacheable

  attr_reader :id, :name, :lat, :long, :kommune

  def initialize(id, name, lat=nil, long=nil, kommune=nil)
    @id = id
    @name = name
    @lat = lat
    @long = long
    @kommune = kommune
  end

  def self.find(id)
    result = CartoDB::Connection.row("aachen_quartiere", id)
    row = result
    new(row[:cartodb_id], row[:name], row[:latitude], row[:longitude], row[:kommune])
  end

  def self.all
    cache do
      fetch_quarters
    end
  end

  def self.fetch_quarters
    result = CartoDB::Connection.query("SELECT cartodb_id, latitude, longitude, name, kommune FROM aachen_quartiere ORDER BY name ASC")
    result[:rows].map do |row|
      Quarter.new(row[:cartodb_id], row[:name], row[:latitude], row[:longitude], row[:kommune])
    end
  end

  def self.fetch_quarters_with_ids(ids)
    result = CartoDB::Connection.query("SELECT cartodb_id, latitude, longitude, name, kommune FROM aachen_quartiere WHERE cartodb_id IN (#{ids.join(',')}) ORDER BY name ASC")
    result[:rows].map do |row|
      Quarter.new(row[:cartodb_id], row[:name], row[:latitude], row[:longitude], row[:kommune])
    end
  end

  def self.id_for_coordinates(lat, long)
    result = CartoDB::Connection.query("SELECT cartodb_id FROM aachen_quartiere where ST_contains(the_geom, st_pointfromText('POINT(#{lat} #{long})', 4326)) LIMIT 1")
    (result[:rows].first || {})[:cartodb_id]
  end

  def coordinates
    "#{lat}, #{long}"
  end

  def streets
    result = CartoDB::Connection.query("SELECT strasse AS street, ST_X(ST_PointOnSurface(the_geom)) AS long, ST_Y(ST_PointOnSurface(the_geom)) AS lat, cartodb_id from aachen_streets_quartiere where name = '#{@name}' order by strasse")
    result[:rows].map do |row|
      Street.new(row[:cartodb_id], row[:street], row[:lat], row[:long])
    end
  end
end
