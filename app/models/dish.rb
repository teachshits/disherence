class Dish < ActiveRecord::Base
  attr_accessible :restaurant_id, :name, :likes, :dislikes, :photos, :opinion
  belongs_to :restaurant
  has_many :reviews
  
  def as_json(options={})
    
    self[:description] ||= ""
    self[:price] ||= 0
    self[:currency] ||= ""
      
    super(:only => [:id, :name, :likes, :dislikes, :description, :price, :currency, :opinion], :methods => [:top_review])
  end
  
  def top_review
    self.reviews.select("reviews.comment_source_url, reviews.comment_source_type, reviews.remote_photo_source_type, reviews.remote_photo_source_url, reviews.local_photo, reviews.remote_photo, reviews.photo, comment, user_id, users.remote_photo as user_photo, users.name as user_name").order('photo DESC').where("reviews.local_photo IS NOT NULL || reviews.remote_photo IS NOT NULL || reviews.comment IS NOT NULL").limit(1).joins(:user)
  end
  
  def opinion=(state)
    self[:opinion] = state
  end
  
  
end
