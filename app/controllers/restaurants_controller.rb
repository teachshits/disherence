class RestaurantsController < ApplicationController
  
  def index
    @restaurants = Restaurant.limit(20)
    @restaurants = @restaurants.by_distance(cookies[:lat], cookies[:lng]) if cookies[:lat] && cookies[:lng]
    
    # @restaurants_info = Hash.new { |h, k| h[k] = {} }
    # @restaurants.each do |r|
    #   @restaurants_info[r.id][:name] = r.name.gsub(/'/, "\\\\'")
    #   @restaurants_info[r.id][:lat] = r.lat
    #   @restaurants_info[r.id][:lng] = r.lng
    # end
    
    @restaurants_info = ""
    i = 0
    @restaurants.each do |r|
      @restaurants_info += "r_info[#{i}] = {};\n"
      @restaurants_info += "r_info[#{i}]['name'] = '#{r.name.gsub(/'/, "\\\\'")}';\n"
      @restaurants_info += "r_info[#{i}]['lat'] = '#{r.lat}';\n"
      @restaurants_info += "r_info[#{i}]['lng'] = '#{r.lng}';\n"
      i += 1
    end  
  end
  
  def show
    @restaurant = Restaurant.find_by_id(params[:id])
  end
  
  def info
    if r = Restaurant.find_by_id(params[:id])
      return render :json => {
        :place => r.name.gsub(/'/, "\\\\'"),
        :lat => r.lat, 
        :lng => r.lng, 
        :flag => 1}
    else
      return render :json => [0]
    end
  end
  
end
