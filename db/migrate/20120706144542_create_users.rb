class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :email
      t.string :crypted_password
      t.string :salt
      t.string :remember_me_token
      t.string :photo	
      t.string :name
      t.integer :facebook_id, :limit => 8
      t.string :twitter_id	
      t.string :vkontakte_id
      t.string :gender	
      t.string :current_city
      t.string :fb_access_token	
      t.string :oauth_token_secret
      t.string :oauth_token
      t.datetime :fb_valid_to
      t.datetime :remember_me_token_expires_at
      t.timestamps
    end
  end
end
