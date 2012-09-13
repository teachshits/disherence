class AddPriceAndDescriptionCurrencyToDishes < ActiveRecord::Migration
  def change
    add_column :dishes, :price, :float
    add_column :dishes, :description, :text
    add_column :dishes, :currency, :string
  end
end
