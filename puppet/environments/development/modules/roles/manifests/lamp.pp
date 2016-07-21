class roles::lamp {

  include profiles::webserver
  include profiles::php  
  include profiles::mysql
  include profiles::redis_lamp
  include profiles::appdeploy

  include git
 
  $vhosts = hiera_hash('apache::vhost')
  create_resources('apache::vhost', $vhosts)
  
  ## Note there are basic puppet modules available for installing ffmpeg and graphicsmagick
  package { ['ffmpeg','ghostscript','graphicsmagick','libgraphicsmagick1-dev']:
      ensure => installed,
  }

  class gmagicksymlink {

  # needs to be done due to not being created during pecl installation

    exec { 'apache-gmagick':
      command => '/bin/ln -s /etc/php/7.0/mods-available/gmagick.ini /etc/php/7.0/apache2/conf.d/20-gmagick.ini',
      creates => '/etc/php/7.0/apache2/conf.d/20-gmagick.ini',
    }
    exec { 'cli-gmagick':
      command => '/bin/ln -s /etc/php/7.0/mods-available/gmagick.ini /etc/php/7.0/cli/conf.d/20-gmagick.ini',
      creates => '/etc/php/7.0/cli/conf.d/20-gmagick.ini',
    }
   

  }

  include roles::lamp::gmagicksymlink

}


