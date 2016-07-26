class profiles::appdeploy {

  $databases = hiera_hash('databases')
  create_resources('mysql::db', $databases)


  vcsrepo { "/var/www/frontend":
    ensure => latest,
    provider => git,
    source => 'https://github.com/collectiveaccess/pawtucket2.git',
    revision => 'dev/ns11mm',
    # eventually:
    # revision => 'branchname'
    require => Package["git"],
  }
  vcsrepo { "/var/www/backend":
    ensure => latest,
    provider => git,
    source => 'https://github.com/collectiveaccess/providence.git',
    revision => 'dev/ns11mm',
    # eventually:
    # revision => 'branchname'
    require =>  Package["git"],
  }

  exec { 'backend/app/tmp chown':
     command  => "/bin/chown -R www-data:www-data /var/www/backend/app/tmp",
     onlyif  =>  '/usr/bin/test -d /var/www/backend/app/tmp',
     unless   => '/bin/ls -ld /var/www/backend/app/tmp | /bin/grep "www-data www-data"',
  }
  exec { 'backend/vendor/ezyang/htmlpurifier chown':
     command  => "/bin/chown -R www-data:www-data /var/www/backend/vendor/ezyang/htmlpurifier",
     onlyif  =>  '/usr/bin/test -d /var/www/backend/vendor/ezyang/htmlpurifier',
     unless   => '/bin/ls -ld /var/www/backend/ezyang/htmlpurifier | /bin/grep "www-data www-data"',
  }
  exec { 'backend/media chown':
     command  => "/bin/chown -R www-data:www-data /var/www/backend/media",
     onlyif  => '/usr/bin/test -d /var/www/backend/media',
     unless   => '/bin/ls -ld /var/www/backend/media | /bin/grep "www-data www-data"',  }

  exec { 'frontend/app/tmp chown':
     command  => "/bin/chown -R www-data:www-data /var/www/frontend/app/tmp",
     onlyif  => '/usr/bin/test -d /var/www/frontend/app/tmp',
     unless   => '/bin/ls -ld /var/www/frontend/app/tmp | /bin/grep "www-data www-data"',
  }
  exec { 'frontend/vendor/ezyang/htmlpurifier chown':
     command  => "/bin/chown -R www-data:www-data /var/www/frontend/vendor/ezyang/htmlpurifier",
     onlyif  => '/usr/bin/test -d /var/www/frontend/vendor/ezyang/htmlpurifier',
     unless   => '/bin/ls -ld /var/www/frontend/ezyang/htmlpurifier | /bin/grep "www-data www-data"',
  }
  exec { 'frontend/media chown':
     command  => "/bin/chown -R www-data:www-data /var/www/frontend/media",
     onlyif  => '/usr/bin/test -d /var/www/frontend/media',
     unless   => '/bin/ls -ld /var/www/frontend/media | /bin/grep "www-data www-data"',  }


  file { 'setup.php.frontend':
    path    => '/var/www/frontend/setup.php',
    ensure  => file,
    notify  => Service['apache2'],
    content => template('profiles/setup-frontend.php.erb'),
  }

  file { 'setup.php.backend':
    path    => '/var/www/backend/setup.php',
    ensure  => file,
    notify  => Service['apache2'],
    content => template('profiles/setup-backend.php.erb'),
  }

}

