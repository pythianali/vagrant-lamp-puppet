class profiles::webserver {
  include ::apache
  include ::apache::mod::php
  include ::apache::mod::rewrite
}
