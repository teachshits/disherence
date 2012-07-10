class AddIndexes < ActiveRecord::Migration
  def change
    add_index :reviews, [:photo]
    add_index :reviews, [:opinion]
    add_index :restaurants, [:lat, :lng]
    add_index :restaurants, [:yelp_reviews_count]
    add_index :dishes, [:likes]
    add_index :dishes, [:dislikes]
  end
end
