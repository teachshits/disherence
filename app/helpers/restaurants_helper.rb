module RestaurantsHelper
  
  def remoteness(restaurant, lat_cur, lng_cur)
    lat_cur = lat_cur.to_f
    lng_cur = lng_cur.to_f
    
    if restaurant.lat && restaurant.lng && lat_cur && lng_cur
      
      rem = restaurant.remoteness(lat_cur,lng_cur)
      
      if lat_cur > 25.64153 && lat_cur < 49.61071 && lng_cur > -125.77148 && lng_cur < -66.09375
        "#{rem[:mi].round(2)} Mi"
      else
        rem[:m] < 1000 ? "#{rem[:m].round} m" : "#{rem[:km].round} Km"
      end
      
    else
      'Unknown'
    end
  end
  
end
