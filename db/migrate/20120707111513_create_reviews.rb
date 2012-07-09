class CreateReviews < ActiveRecord::Migration
  def change
    create_table :reviews do |t|
      t.references :user
      t.references :dish
      t.string :photo
      t.boolean :opinion
      t.string :comment
      
      t.timestamps
    end
  end
end
