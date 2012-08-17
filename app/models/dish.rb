class Dish < ActiveRecord::Base
  attr_accessible :restaurant_id, :name, :likes, :dislikes, :photos
  belongs_to :restaurant
  has_many :reviews
end
