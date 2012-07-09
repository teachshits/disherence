class AddYelpProfileId < ActiveRecord::Migration
  def change
    add_column :users, :yelp_profile_id, :string
    add_index :users, [:yelp_profile_id]
  end
end
