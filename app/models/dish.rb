class Dish < ActiveRecord::Base
  attr_accessible :restaurant_id, :name, :likes, :dislikes, :photos
  attr_accessor :opinion
  belongs_to :restaurant
  has_many :reviews
  
  def as_json(options={})
    
    self[:description] ||= ""
    self[:price] ||= 0
    self[:currency] ||= ""
      
    super(:only => [:id, :name, :likes, :dislikes, :description, :price, :currency, :opinion], :methods => [:top_review, :voted])
  end
  
  def top_review
    self.reviews.select("reviews.remote_photo as photo, comment, user_id, users.remote_photo as user_photo, users.name as user_name").order('photo DESC').limit(1).joins(:user)
  end
  
  # def opinion=(state)
  #   self[:opinion] = state
  # end
  # 
  
end
