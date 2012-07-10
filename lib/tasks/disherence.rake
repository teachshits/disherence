namespace :disherence do
  namespace :generate do
    desc "Generate random fake reviews"
    task :reviews => :environment do
      all_users_ids =  User.select(:id).order('id').map { |u| u.id }
      slice_size = (all_users_ids.size * 0.3).to_i
      puts slice_size
      all_users_ids.shuffle[0..slice_size].each do |user_id|
        shuffled_slice = (all_users_ids - [user_id]).shuffle[0..slice_size]
        puts "User_id: #{user_id} started!"
        User.find(shuffled_slice).each do |target_user|
          ActiveRecord::Base.transaction do
            target_user.reviews.with_photos.each do |target_review|
              (rand(1..100) < 90) ? Review.agree(target_review.id, user_id) : Review.disagree(target_review.id, user_id)
            end
          end
        end
        puts "User_id: #{user_id} processed!"
      end
    end
  end
end