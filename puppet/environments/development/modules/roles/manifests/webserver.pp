class roles::webserver {
  include ::profiles::webserver
  include ::profiles::php

  $vhosts = hiera_hash('apache::vhost')
  create_resources('apache::vhost', $vhosts)
}
