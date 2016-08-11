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
  $themes_by_device = hiera('themes_by_device')
  $use_clean_urls = hiera('use_clean_urls')
  $app_display_name = hiera('app_display_name')
  $admin_email = hiera('admin_email')


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
  } ->
  exec { 'frontend/app/tmp chown':
     command  => "/bin/chown -R www-data:www-data ${frontendpath}/app/tmp",
     onlyif  => "/usr/bin/test -d ${frontendpath}/app/tmp",
     unless   => "/bin/ls -ld ${frontendpath}/app/tmp | /bin/grep 'www-data www-data'",
  } ->
  exec { 'frontend/vendor/ezyang/htmlpurifier chown':
     command  => "/bin/chown -R www-data:www-data ${frontendpath}/vendor/ezyang/htmlpurifier",
     onlyif  => "/usr/bin/test -d ${frontendpath}/vendor/ezyang/htmlpurifier",
     unless   => "/bin/ls -ld ${frontendpath}/ezyang/htmlpurifier | /bin/grep 'www-data www-data'",
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
  } ->
  exec { 'backend/app/tmp chown':
     command  => "/bin/chown -R www-data:www-data ${backendpath}/app/tmp",
     onlyif  =>  "/usr/bin/test -d ${backendpath}/app/tmp",
     unless   => "/bin/ls -ld ${backendpath}/app/tmp | /bin/grep 'www-data www-data'",
  } ->
  exec { 'backend/app/log chown':
     command  => "/bin/chown -R www-data:www-data ${backendpath}/app/log",
     onlyif  =>  "/usr/bin/test -d ${backendpath}/app/log",
     unless   => "/bin/ls -ld ${backendpath}/app/log | /bin/grep 'www-data www-data'",
  } ->
  exec { 'backend/vendor/ezyang/htmlpurifier chown':
     command  => "/bin/chown -R www-data:www-data ${backendpath}/vendor/ezyang/htmlpurifier",
     onlyif  =>  "/usr/bin/test -d ${backendpath}/vendor/ezyang/htmlpurifier",
     unless   => "/bin/ls -ld ${backendpath}/ezyang/htmlpurifier | /bin/grep 'www-data www-data'",
  } ->
  exec { 'backend/media chown':
     command  => "/bin/chown -R www-data:www-data ${backendpath}/media",
     onlyif  => "/usr/bin/test -d ${backendpath}/media",
     unless   => "/bin/ls -ld ${backendpath}/media | /bin/grep 'www-data www-data'",
  } ->
  file { "${frontendpath}/media":
    ensure => 'link',
    target   => "${backendpath}/media",
    force  => true,
  }

  cron { 'flush-frontend-app-tmp':
    command => "/bin/rm -rf ${frontendpath}/app/tmp/*",
    user    => 'root',
    hour    => ['0,12'],
  }

}
