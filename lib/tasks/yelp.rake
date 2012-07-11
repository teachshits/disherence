namespace :yelp do
  desc "Convert parsed Yelp's Highlights to Disherense models' "
  task :convert => :environment do
    count = Yelp::HighlightDish.where('dish_photo_url IS NOT NULL').count
    current = 0
    Yelp::HighlightDish.where('dish_photo_url IS NOT NULL').find_each(:batch_size => 100) do |highlight|
      begin
        current += 1
        puts "#{current} from #{count}"
        user = User.where(:yelp_profile_id => highlight.profile_id).first
        unless user
          user = User.new(:yelp_profile_id => highlight.profile_id, :name => highlight.profile_name)
          begin
            user.remote_photo_url = highlight.profile_photo_url
            user.save
          rescue OpenURI::HTTPError
            highlight.destroy
            next
          end
        end

        restaurant = Restaurant.where(:yelp_restaurant_id => highlight.restaurant.id).first
        unless restaurant
          restaurant = Restaurant.create(:name => highlight.restaurant.name, :city => highlight.restaurant.city,
                                         :address => highlight.restaurant.address, :phone => highlight.restaurant.phone,
                                         :cuisine => highlight.restaurant.category, :bill => highlight.restaurant.price,
                                         :lat => highlight.restaurant.lat, :lng => highlight.restaurant.lng,
                                         :yelp_reviews_count => 0, :yelp_restaurant_id => highlight.restaurant.id)
        end

        dish = Dish.where(:restaurant_id => restaurant.id, :name => highlight.dish_name).first
        unless dish
          dish = Dish.create(:restaurant_id => restaurant.id, :name => highlight.dish_name)
          restaurant.yelp_reviews_count += highlight.reviews_count
          restaurant.save
        end

        review = Review.where(:user_id => user.id, :dish_id => dish.id, :comment => highlight.quote).first
        unless review
          review = Review.create(:user_id => user.id, :dish_id => dish.id, :comment => highlight.quote, :opinion => true)
          review.remote_photo_url = highlight.dish_photo_url
          review.save
          dish.photos += 1
          dish.save
        end

        if review.photo.blank?
          review.remote_photo_url = highlight.dish_photo_url
          review.save
          dish.photos += 1
          dish.save
          puts dish.inspect
          puts review.inspect
        end
      rescue Exception => ex
        "SKIPPED! Reason: #{ex.class} -> #{ex.message}"
      end
    end
  end
end