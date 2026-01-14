# @summary Installs and configures Duo Authentication Proxy
#
# @example Basic usage
#   class { 'duo_authproxy':
#     settings  => {
#       'ad_client' => {
#         'transport'           => 'ldaps',
#         'ssl_ca_certs_file'   => 'ca-bundle.crt',
#         'ssl_verify_hostname' => true,
#       },
#       'ldap_server_auto' => {
#           'client'              => 'ad_client',
#           'ssl_key_path'        => "${facts['fqdn']}.key",
#           'ssl_cert_path'       => "${facts['fqdn']}.crt",
#           'minimum_tls_version' => 'tls1.2',
#       },
#     },
#   }
#   contain 'duo_authproxy'
#
# @see https://github.com/MiamiOH/puppet-duo_authproxy
#
# @param dep_packages
#   Array list of packages to install prior to build
# @param version
#   Version of duoauthproxy to install (default: 6.5.2)
# @param python_env
#   Executable for python
# @param build_dir
#   Absolute path to source directory
# @param extract_dir
#   Absolute path for extracted source files
# @param install_dir
#   Absolute path for installed binaries
# @param install_src
#   Site from which to download source code (default: dl.duosecurity.com)
# @param install_proto
#   Protocol to use for download (default: https)
# @param proxy_server
#   Address of proxy server (if needed)
# @param proxy_type
#   Type of proxy (none|http|https|ftp) (defaults to none if proxy_server is undef, otherwise defaults to $duo_authproxy::install_proto)
# @param settings
#   Hash of values for main config 
# @param checksum
#   REQUIRED: sha-256 checksum of downloaded tgz file
# @param service_user
#   Service will run as specific user (default: duo_authproxy_svc)
# @param log_group
#   Syslog group for logging (default: duo_authproxy_grp)
# @param init_script
#   Whether to install systemd scripts (default: true)
# @param selinux
#   Whether to install the Authentication Proxy SELinux module (default: true)
class duo_authproxy (
  Optional[Array[String]] $dep_packages,
  Optional[String]        $version,
  Optional[String]        $python_env,
  Optional[Stdlib::Absolutepath]    $build_dir,
  Optional[Stdlib::Absolutepath]    $extract_dir,
  Optional[Stdlib::Absolutepath]    $install_dir,
  Optional[String]        $install_src,
  Optional[String]        $install_proto,
  Optional[String]        $proxy_server,
  Optional[String]        $proxy_type,
  Optional[Hash]          $settings,
  String                  $checksum      = '67d8ca00f256f1fb65ade92e4bf3a788f12323312168440d03239b4a6f53fcfd',
  String                  $service_user  = 'duo_authproxy_svc',
  String                  $log_group     = 'duo_authproxy_grp',
  Boolean                 $init_script   = true,
  Boolean                 $selinux       = true,
) {
  if $facts['os']['family'] == 'RedHat' {
    if versioncmp($facts['os']['release']['major'], '8') < 0 {
      $python_version = $facts['python3_version']
    }
  } elsif $facts['os']['family'] == 'Debian' {
    if versioncmp($facts['os']['release']['full'], '18.04') < 0 {
      $python_version = $facts['python3_version']
    }
  } else {
    $python_version = $facts['python_version']
  }

  unless (($python_version == undef) or (versioncmp($python_version, '2.6') >= 0 )) {
    fail("${name} requires at least python version 2.6, you have ${python_version}.")
  }

  contain 'duo_authproxy::install'
  contain 'duo_authproxy::config'
  contain 'duo_authproxy::service'

  Class['duo_authproxy::install']
  -> Class['duo_authproxy::config']

  Class['duo_authproxy::install']
  ~> Class['duo_authproxy::service']

  Class['duo_authproxy::config']
  ~> Class['duo_authproxy::service']
}
