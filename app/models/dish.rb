class Dish < ActiveRecord::Base
  attr_accessible :likes, :dislikes
  belongs_to :restaurant
  has_many :reviews
  
end
