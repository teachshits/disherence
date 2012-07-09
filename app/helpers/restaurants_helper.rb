module RestaurantsHelper
  
  def remoteness(restaurant, lat_cur, lng_cur)
    
    if restaurant.lat && restaurant.lng && lat_cur && lng_cur
      rem = restaurant.remoteness(lat_cur,lng_cur)
      rem = rem[:m] < 1000 ? "#{rem[:m].round} m" : "#{rem[:km].round} Km"
      raw "<div class=\"distance\">#{rem}</div>"
    end
  end
  
end
