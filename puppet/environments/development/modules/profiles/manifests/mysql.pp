class profiles::mysql {
  
  class { '::mysql::server':
    root_password           => 'testtest',
    remove_default_accounts => true,
    override_options        => $override_options
  }
}

