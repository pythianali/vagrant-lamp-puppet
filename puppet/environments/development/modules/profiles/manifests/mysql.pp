class profiles::mysql {
  
  $override_options = hiera_hash('mysql::server::override_options')
 
  class { 'mysql::server':
    override_options => $override_options,
  }  
  
  include mysql::client
 
}

