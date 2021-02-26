# duo_authproxy::config
#
# Private class that configures the auth proxy
#
# @summary configure the proxy
#
# @example
#   don't use this class directly
class duo_authproxy::config {

  file { 'authproxy.cfg':
    ensure  => file,
    path    => "${duo_authproxy::install_dir}/conf/authproxy.cfg",
    owner   => 'nobody',
    group   => 'root',
    mode    => '0400',
    content => Sensitive(template("${module_name}/authproxy.cfg.erb")),
  }
}
