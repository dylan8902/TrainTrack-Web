class Journey < ActiveRecord::Base
  belongs_to :user
  has_many :journey_legs
  validates :uuid, presence: true, uniqueness: true
  default_scope { order('created_at DESC') }
  before_validation :add_uuid


  def origin
    return journey_legs.first.origin if journey_legs.first
  end


  def destination
    return journey_legs.last.destination if journey_legs.last
  end


  def departure_time
    return nil if journey_legs.first.nil?
    return journey_legs.first.departure_time
  end


  def arrival_time
    return nil if journey_legs.first.nil?
    return journey_legs.last.arrival_time
  end


  def to_s
    origin = self.origin || "Unknown"
    destination = self.destination || "Unknown"
    return "#{origin} to #{destination}"
  end


  def google_map_image
    return nil if journey_legs.count == 0
    src = "https://maps.googleapis.com/maps/api/staticmap?path=color:0xff0000%7Cweight:7"
    journey_legs.each do |leg|
      src << "%7C#{leg.origin.lat},#{leg.origin.lng}" if leg.origin and leg.origin.lat and leg.origin.lng
    end
    if journey_legs.last.destination and journey_legs.last.destination.lat and journey_legs.last.destination.lng
      src << "%7C#{journey_legs.last.destination.lat},#{journey_legs.last.destination.lng}"
    end
    return src << "&size=320x320&sensor=false".html_safe
  end


  def departure_time_and_date
    return "" if self.departure_time.nil?
    return self.departure_time.strftime("%d/%m/%Y - %H:%M")
  end

  def new_journey_leg
    return "/stations" if self.journey_legs.count == 0
    station = self.journey_legs.last.destination
    if station.national_rail
      return "/stations/" + station.uuid + "/departures?journey_id=" + self.id.to_s
    elsif station.underground
      return "/stations/" + station.uuid + "/tube?journey_id=" + self.id.to_s
    end
  end


  def as_json(options={})
    super(include: [:origin, :destination, :user, { journey_legs: { include: [:origin, :destination, :operator] } }])
  end


  protected

  def add_uuid
    self.uuid = SecureRandom.uuid if uuid.nil?
  end


end
