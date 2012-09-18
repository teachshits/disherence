class Dish < ActiveRecord::Base
  attr_accessible :restaurant_id, :name, :likes, :dislikes, :photos
  belongs_to :restaurant
  has_many :reviews
  
  def as_json(options={})
    self.description ||= ""
    super(:only => [:id, :name, :likes, :dislikes, :description], :methods => [:top_review])
  end
  
  def top_review
    self.reviews.select("reviews.remote_photo as photo, comment, user_id, users.remote_photo as user_photo, users.name as user_name").order('photo DESC').limit(1).joins(:user)
  end
end
