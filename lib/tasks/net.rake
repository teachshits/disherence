# encoding: utf-8
namespace :net do
  
  task :post do  
    require 'httparty'
    HTTParty.post(ENV["URL"])
  end
  
end