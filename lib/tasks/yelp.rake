namespace :yelp do
  desc "Convert parsed Yelp's Highlights to Disherense models' "
  task :convert => :environment do
    hightlight = Yelp::HighlightDish.where('dish_photo_url IS NOT NULL').first
    user = User.where(:yelp_profile_id => hightlight.profile_id).first
    unless user
      user = User.new(:yelp_profile_id => hightlight.profile_id, :name => hightlight.profile_name)
      user.remote_photo_url = hightlight.profile_photo_url
      user.save
    end

    puts user.inspect
  end
end