class LatLngRestaurantsChangeType < ActiveRecord::Migration
  def change
    change_column :restaurants, :lat, :string
    change_column :restaurants, :lng, :string
  end

end
