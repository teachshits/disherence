class CreateRestaurants < ActiveRecord::Migration
  def change
    create_table :restaurants do |t|
      t.string :name
      t.string :address
      t.string :phone
      t.string :cuisine
      t.integer :bill
      t.integer :yelp_reviews_count
      t.float :lat
      t.float :lng
      t.timestamps
    end
  end
end
