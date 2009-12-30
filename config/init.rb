# Go to http://wiki.merbivore.com/pages/init-rb
 
require 'config/dependencies.rb'
 
use_orm :datamapper
use_test :rspec
use_template_engine :haml
 
Merb::Config.use do |c|
  c[:use_mutex] = false
  c[:session_store] = 'cookie'  # can also be 'memory', 'memcache', 'container', 'datamapper
  
  # cookie session store configuration
  c[:session_secret_key]  = 'cce1832a51efa234b804bc3b192efc679c8f8c10'  # required for cookie session store
  c[:session_id_key] = '_rbus_session_id' # cookie session id key, defaults to "_session_id"
end
 
Merb::BootLoader.before_app_loads do
  # This will get executed after dependencies have been loaded but before your app's classes have loaded.
end
 
Merb::BootLoader.after_app_loads do
  # This will get executed after your app's classes have been loaded.
 dependency 'tlsmail'
 
  # Activate SSL Support
  Net::SMTP.enable_tls(OpenSSL::SSL::VERIFY_NONE)
 
  # Configure Merb Mailer
  Merb::Mailer.config = {
    :host   => 'smtp.gmail.com',
    :port   => '587',
    :user   => 'svs@rbus.in',
    :pass   => 's8s4a7m2',
    :auth   => :plain
  }

end
