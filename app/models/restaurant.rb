class Restaurant < ActiveRecord::Base
  attr_accessible :name, :city, :address, :phone, :cuisine, :bill, :yelp_reviews_count, :lat, :lng, :yelp_restaurant_id
  has_many :dishes

  scope :with_dishes, where("id IN (SELECT DISTINCT(restaurant_id) FROM dishes)")
   
  RAD_PER_DEG = 0.017453293 # PI/180; PI = 3.1415926535

  Rmiles = 3956           # radius of the great circle in miles
  Rkm = 6371              # radius in kilometers...some algorithms use 6367
  Rfeet = Rmiles * 5282   # radius in feet
  Rmeters = Rkm * 1000    # radius in meters
  
  def bill
    self[:bill] || ""
  end
  
  def self.near(lat, lng, rad = 1)
    where("((ACOS(
    	SIN(lat * PI() / 180) * SIN(? * PI() / 180) + 
    	COS(lat * PI() / 180) * COS(? * PI() / 180) * 
    	COS((? - lng) * PI() / 180)) * 180 / PI()) * 60 * 1.1515) * 1.609344 <= ?", lat, lat, lng, rad)
  end
  
  def self.by_distance(lat, lng)
    order("((ACOS(
      SIN(#{lat} * PI() / 180) * SIN(lat * PI() / 180) +
      COS(#{lat} * PI() / 180) * COS(lat * PI() / 180) * 
      COS((#{lng} - lng) * PI() / 180)) * 180 / PI()) * 60 * 1.1515) * 1.609344")
  end
  
  def self.bounds(bounds)
    c = bounds.split(',').map {|x| x.to_f}
    if c[0] > c[2]
      where("lat > ? && lat < 180 && lat > -180 && lat < ? && lng > ? && lng < ?", c[0], c[2], c[1], c[3])
    else
      where("lat > ? && lat < ? && lng > ? && lng < ?", c[0], c[2], c[1], c[3])
    end
  end  
  
  def as_json(options={})
    super(:only => [:id, :name, :address, :cuisine, :bill, :yelp_reviews_count, :lat, :lng, :yelp_rating])
  end
  
  def remoteness(lat_cur,lng_cur)
    lat_cur = lat_cur.to_f
    lng_cur = lng_cur.to_f
    
    lat = lat.to_f
    lng = lng.to_f
    
    dlng = lng_cur - lng 
    dlat = lat_cur - lat

    dlng_rad = dlng * RAD_PER_DEG 
    dlat_rad = dlat * RAD_PER_DEG

    lat_rad = lat * RAD_PER_DEG
    lng_rad = lng * RAD_PER_DEG

    lat_cur_rad = lat_cur * RAD_PER_DEG
    lng_cur_rad = lng_cur * RAD_PER_DEG
    
    a = (Math.sin(dlat_rad/2))**2 + Math.cos(lat_rad) * Math.cos(lat_cur_rad) * (Math.sin(dlng_rad/2))**2
    c = 2 * Math.atan2( Math.sqrt(a), Math.sqrt(1-a))
    
    dMi = Rmiles * c          # delta between the two points in miles
    dKm = Rkm * c             # delta in kilometers
    dFeet = Rfeet * c         # delta in feet
    dMeters = Rmeters * c     # delta in meters
    
    distances = {
      :mi => dMi,
      :km => dKm,
      :ft => dFeet,
      :m => dMeters
    }
  end
    
end
