# duo_authproxy
#
# Installs and configures Duo Authentication Proxy
#
# @summary Installs and configures Duo Authentication Proxy
#
# @example
#   include duo_authproxy
class duo_authproxy (
  Array[String] $dep_packages,
  String $version,
  Stdlib::Absolutepath $install_dir,
  Hash $settings = {},
  $proxy_server = undef,
  $proxy_type = undef,
) {

  if $::operatingsystemrelease == '18.04' {
    $python_version = 'python3_version'
  }else {
    $python_version = 'python_version'
  }

  unless versioncmp($facts[$python_version], '2.6') >= 0 {
    fail("${name} requires at least python version 2.6, you have ${facts[$python_version]}.")
  }

  contain 'duo_authproxy::install'
  contain 'duo_authproxy::config'
  contain 'duo_authproxy::service'

  Class['::duo_authproxy::install']
  -> Class['::duo_authproxy::config']

  Class['::duo_authproxy::install']
  ~> Class['::duo_authproxy::service']

  Class['::duo_authproxy::config']
  ~> Class['::duo_authproxy::service']
}
