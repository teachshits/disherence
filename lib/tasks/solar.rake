namespace :solr do
  desc "Generate random fake reviews"
  task :test do
    solr = RSolr.connect :url => 'http://localhost:8983/solr/core0/'
    
    p 123
  end
end