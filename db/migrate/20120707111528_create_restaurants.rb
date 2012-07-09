class CreateRestaurants < ActiveRecord::Migration
  def change
    create_table :restaurants do |t|
      t.string :name
      t.string :address
      t.string :phone
      t.string :cuisine
      t.integer :bill
      t.integer :yelp_reviews_count
      t.integer :lat, :limit => 8
      t.integer :lng, :limit => 8
      t.timestamps
    end
  end
end
