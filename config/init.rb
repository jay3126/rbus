# Go to http://wiki.merbivore.com/pages/init-rb
 
require 'config/dependencies.rb'
 
use_orm :datamapper
use_test :rspec
use_template_engine :haml
 
Merb::Config.use do |c|
  c[:use_mutex] = false
  c[:session_store] = 'datamapper'  # can also be 'memory', 'memcache', 'container', 'datamapper
  
  # cookie session store configuration
  c[:session_secret_key]  = 'cce1832a51efa234b804bc3b192efc679c8f8c10'  # required for cookie session store
  c[:session_id_key] = '_rbus_session_id' # cookie session id key, defaults to "_session_id"
end
 
Merb::BootLoader.before_app_loads do
  # This will get executed after dependencies have been loaded but before your app's classes have loaded.
  RANDOM_KEY  = "8be1632a38e5a1dd16f63d540dcf3be8c390abe6d3fa2e69b1c23f907f18f5b72f017a31fcfbe2a5f228a0ae7fc38aaf5ceeff3e4cfc4b8dbb520b54337f2928"
  require "lib/functions"
end
 
Merb::BootLoader.after_app_loads do
  # This will get executed after your app's classes have been loaded.
  # Activate SSL Support
  Net::SMTP.enable_tls(OpenSSL::SSL::VERIFY_NONE)
 
  # Configure Merb Mailer
  Merb::Mailer.config = {
    :host   => 'smtp.gmail.com',
    :port   => '587',
    :user   => '',
    :pass   => '',
    :auth   => :plain
  }

  TWITTER_NAME = ""
  TWITTER_PASSWORD = ""

end
