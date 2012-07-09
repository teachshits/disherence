class CreateDishes < ActiveRecord::Migration
  def change
    create_table :dishes do |t|
      t.references :restaurant
      t.string :name
      t.integer :likes, :default => 0
      t.integer :dislikes, :default => 0
      t.integer :photos, :default => 0

      t.timestamps
    end
  end
end
