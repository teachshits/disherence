require 'net/https'

desc 'Import disherence data from GAE'
task :get_data => :environment do

  http = init_storage
  i = 220

  917.times do
    i += 1
    
    url = "/api/restaurant/info?offset=#{i}"
    data = get_data(http, url)
    
    restaurant_id = add_restaurant(data['yelp_uri'])
    data['dishes'].each do |dish|
      dish_id = add_dish(restaurant_id, dish)

      if dish_id
        if dish['users']
          dish['users'].each do |user|
            user_id = add_user(user)
            add_review(user_id, dish_id)
          end
        end

        add_photo(dish_id, dish['photo']) if dish['photo']
      end

    end
    
  end

end

desc 'Update yelp_rating for restaurants'
task :update_yelp_rating => :environment do
  Restaurant.all.each do |restaurant|
    yelp_restaurant = YelpRestaurant.find(restaurant.yelp_restaurant_id)
    restaurant.yelp_rating = yelp_restaurant.rating.nil? ? 0 : yelp_restaurant.rating
    restaurant.save
  end
end

desc 'Update dishes info'
task :update_dishes_info => :environment do
  Dish.all.each do |dish|
    yelp_restaurant_id = Restaurant.select('yelp_restaurant_id').where(:id => dish.restaurant_id).first.yelp_restaurant_id
    yelp_dish = Yelp::Dish.where(:ylp_restaurant_id => yelp_restaurant_id, :name => dish.name).first
    unless yelp_dish.nil?
      dish.price = yelp_dish.price.to_f
      dish.currency = yelp_dish.currency
      dish.description = yelp_dish.description
      dish.save
    end
  end
end

def init_storage
  server = 'debug.gaunitystorage.appspot.com'
  http = Net::HTTP.new(server)
end

def get_data(http, url)
  req = Net::HTTP::Get.new(url)
  response = http.request(req)
  data = response.body
  
  JSON.parse(data)
end

def add_dish(restaurant_id, dish)
  p dish['name']
  if dish['mentions_count'] > 0 || dish['photos_count'] > 0
    if ! mydish = Dish.find_by_restaurant_id_and_name(restaurant_id, dish['name'])
      mydish = Dish.create(
          :restaurant_id => restaurant_id,
          :name => dish['name'],
          :photos => dish['photo'] ? 1 : 0,
          :likes => dish['likes_count'],
          :dislikes => dish['dislikes_count']
      )
    else
      mydish.photos = dish['photo'] ? 1 : 0
      mydish.likes = dish['likes_count']
      mydish.dislikes = dish['dislikes_count']
      mydish.save
      p "updated!"
    end
    mydish.id
  end
end

def add_user(user)
  unless myuser = User.find_by_yelp_profile_id(user['profile_id'])
    myuser = User.create(
      :yelp_profile_id => user['profile_id'],
      :name => user['name'],
      :remote_photo => user['photo_url'] ? user['photo_url'] : ''
    )
  end
  myuser.id
end

def add_review(user_id, dish_id)
  unless Review.find_by_user_id_and_dish_id(user_id, dish_id)
    review = Review.create(
      :user_id => user_id,
      :dish_id => dish_id,
      :opinion => 1
    )
  end
end

def add_photo(dish_id, photo)
  unless myuser = User.find_by_yelp_profile_id(photo['user_profile_id'])
    myuser = User.create(
      :yelp_profile_id => photo['user_profile_id'],
      :name => photo['user_name']
    )
  end
  
  if review = Review.find_by_user_id_and_dish_id(myuser.id, dish_id)
    review.update_attributes(:remote_photo => photo['url'])
  else
    review = Review.create(
      :user_id => myuser.id,
      :dish_id => dish_id,
      :opinion => 1,
      :remote_photo => photo['url'],
      :comment => photo['caption']
    )
  end
end

def add_restaurant(ylp_uri)
  if yr = YelpRestaurant.find_by_ylp_uri(ylp_uri)
    unless r = Restaurant.find_by_yelp_restaurant_id(yr.id)
      r = Restaurant.create(
        :name => yr.name,
        :address => yr.address,
        :phone => yr.phone,
        :cuisine => yr.category,
        :bill => yr.price,
        :yelp_reviews_count => yr.review_count,
        :lat => yr.lat,
        :lng => yr.lng,
        :yelp_restaurant_id => yr.id,
        :city => yr.city
      )
    end
    r.id
  end
end
