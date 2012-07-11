namespace :yelp do
  desc "Convert parsed Yelp's Highlights to Disherense models' "
  task :convert => :environment do
    count = Yelp::HighlightDish.where('dish_photo_url IS NOT NULL').count
    current = 0
    Yelp::HighlightDish.where('dish_photo_url IS NOT NULL').find_each(:batch_size => 100) do |hightlight|
      #begin
        current += 1
        puts "#{current} from #{count}"
        user = User.where(:yelp_profile_id => hightlight.profile_id).first
        unless user
          user = User.new(:yelp_profile_id => hightlight.profile_id, :name => hightlight.profile_name)
          user.remote_photo_url = hightlight.profile_photo_url
          user.save
        end

        restaurant = Restaurant.where(:yelp_restaurant_id => hightlight.restaurant.id).first
        unless restaurant
          restaurant = Restaurant.create(:name => hightlight.restaurant.name, :city => hightlight.restaurant.city,
                                         :address => hightlight.restaurant.address, :phone => hightlight.restaurant.phone,
                                         :cuisine => hightlight.restaurant.category, :bill => hightlight.restaurant.price,
                                         :lat => hightlight.restaurant.lat, :lng => hightlight.restaurant.lng,
                                         :yelp_reviews_count => 0, :yelp_restaurant_id => hightlight.restaurant.id)
        end

        dish = Dish.where(:restaurant_id => restaurant.id, :name => hightlight.dish_name).first
        unless dish
          dish = Dish.create(:restaurant_id => restaurant.id, :name => hightlight.dish_name)
          restaurant.yelp_reviews_count += hightlight.reviews_count
          restaurant.save
        end

        review = Review.where(:user_id => user.id, :dish_id => dish.id, :comment => hightlight.quote).first
        unless review
          review = Review.create(:user_id => user.id, :dish_id => dish.id, :comment => hightlight.quote, :opinion => true)
          review.remote_photo_url = hightlight.dish_photo_url
          review.save
          dish.photos += 1
          dish.save
        end

        if review.photo.blank?
          review.remote_photo_url = hightlight.dish_photo_url
          review.save
          dish.photos += 1
          dish.save
        end


        puts user.inspect
        puts restaurant.inspect
        puts dish.inspect
        puts review.inspect
      #rescue Exception => ex
      #  "SKIPPED! Reason: #{ex.message}"
      #end
    end
  end
end