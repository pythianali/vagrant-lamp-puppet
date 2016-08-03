class profiles::appdeploy {

  include git

  $databases = hiera_hash('databases')
  create_resources('mysql::db', $databases)

  $database_host = $databases['CAdb']['host']
  $database_user = $databases['CAdb']['user']
  $database_pass = $databases['CAdb']['password']
  $database_name = $databases['CAdb']['name']

  $frontendpath = hiera('frontendpath')
  $backendpath = hiera('backendpath')

  vcsrepo { "$frontendpath":
    ensure => latest,
    provider => git,
    source => 'https://github.com/collectiveaccess/pawtucket2.git',
    revision => 'dev/ns11mm',
    # eventually:
    # revision => 'branchname'
    require => Package["git"],
  } ->
  file { 'setup.php.frontend':
    path    => "${frontendpath}/setup.php",
    ensure  => file,
    notify  => Service['apache2'],
    content => template('profiles/setup-frontend.php.erb'),
  }

  vcsrepo { "$backendpath":
    ensure => latest,
    provider => git,
    source => 'https://github.com/collectiveaccess/providence.git',
    revision => 'dev/ns11mm',
    # eventually:
    # revision => 'branchname'
    require =>  Package["git"],
  } ->
  file { 'setup.php.backend':
    path    => "${backendpath}/setup.php",
    ensure  => file,
    notify  => Service['apache2'],
    content => template('profiles/setup-backend.php.erb'),
  }

  exec { 'backend/app/tmp chown':
     command  => "/bin/chown -R www-data:www-data ${backendpath}/app/tmp",
     onlyif  =>  '/usr/bin/test -d ${backendpath}/app/tmp',
     unless   => '/bin/ls -ld ${backendpath}/app/tmp | /bin/grep "www-data www-data"',
  }
  exec { 'backend/vendor/ezyang/htmlpurifier chown':
     command  => "/bin/chown -R www-data:www-data ${backendpath}/vendor/ezyang/htmlpurifier",
     onlyif  =>  '/usr/bin/test -d ${backendpath}/vendor/ezyang/htmlpurifier',
     unless   => '/bin/ls -ld ${backendpath}/ezyang/htmlpurifier | /bin/grep "www-data www-data"',
  }
  exec { 'backend/media chown':
     command  => "/bin/chown -R www-data:www-data ${backendpath}/media",
     onlyif  => '/usr/bin/test -d ${backendpath}/media',
     unless   => '/bin/ls -ld ${backendpath}/media | /bin/grep "www-data www-data"',  }

  exec { 'frontend/app/tmp chown':
     command  => "/bin/chown -R www-data:www-data ${frontendpath}/app/tmp",
     onlyif  => '/usr/bin/test -d ${frontendpath}/app/tmp',
     unless   => '/bin/ls -ld ${frontendpath}/app/tmp | /bin/grep "www-data www-data"',
  }
  exec { 'frontend/vendor/ezyang/htmlpurifier chown':
     command  => "/bin/chown -R www-data:www-data ${frontendpath}/vendor/ezyang/htmlpurifier",
     onlyif  => '/usr/bin/test -d ${frontendpath}/vendor/ezyang/htmlpurifier',
     unless   => '/bin/ls -ld ${frontendpath}/ezyang/htmlpurifier | /bin/grep "www-data www-data"',
  }
  file { "${frontendpath}/media":
    ensure => 'link',
    target   => "${backendpath}/media",
    force  => true,
  }

}
