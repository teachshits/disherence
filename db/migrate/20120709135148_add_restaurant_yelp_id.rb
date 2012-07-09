class AddRestaurantYelpId < ActiveRecord::Migration
  def change
    add_column :restaurants, :yelp_restaurant_id, :integer
    add_index :restaurants, [:yelp_restaurant_id]
  end
end
