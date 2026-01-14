# duo_authproxy::install
#
# Private class that installs the auth proxy
#
# @summary install the proxy
#
# @example
#   don't use this class directly
class duo_authproxy::install {
  ensure_packages($duo_authproxy::dep_packages)

  $_init_script = $duo_authproxy::init_script ? {
    true    => 'yes',
    default => 'no',
  }
  $_selinux = $duo_authproxy::selinux ? {
    true    => 'yes',
    default => 'no',
  }
  $_proxy_type_from_url = $duo_authproxy::proxy_server ? {
    undef   => 'none',
    default => $duo_authproxy::install_proto,
  }
  $_proxy_type = $duo_authproxy::proxy_type ? {
    undef   => $_proxy_type_from_url,
    default => $duo_authproxy::proxy_type,
  }

  $inst_cmd = "duoauthproxy-build/install --install-dir ${duo_authproxy::install_dir} --service-user ${duo_authproxy::service_user} --log-group ${duo_authproxy::log_group} --create-init-script ${_init_script} --enable-selinux ${_selinux}"
  $creates_path = "${duo_authproxy::install_dir}/${duo_authproxy::version}"
  $source_path = "${duo_authproxy::extract_dir}/duoauthproxy-${duo_authproxy::version}-src"

  archive { "${source_path}.tgz":
    source        => "${duo_authproxy::install_proto}://${duo_authproxy::install_src}/duoauthproxy-${duo_authproxy::version}-src.tgz",
    extract       => true,
    extract_path  => $duo_authproxy::extract_dir,
    checksum      => $duo_authproxy::checksum,
    checksum_type => 'sha256',
    cleanup       => true,
    creates       => $creates_path,
    proxy_server  => $duo_authproxy::proxy_server,
    proxy_type    => $_proxy_type,
  }

  -> exec { 'duoauthproxy-make':
    command     => 'make > duoauthproxy-make.log',
    cwd         => $source_path,
    environment => ["PYTHON=${duo_authproxy::python_env}"],
    path        => $facts['path'],
    creates     => $creates_path,
    require     => Package[$duo_authproxy::dep_packages],
  }

  -> exec { 'duoauthproxy-install':
    command     => "${source_path}/${inst_cmd} > duoauthproxy-install.log",
    cwd         => $source_path,
    environment => ["PYTHON=${duo_authproxy::python_env}"],
    path        => $facts['path'],
    creates     => $creates_path,
  }

  -> exec { 'duoauthproxy-tag':
    command => "touch ${creates_path}",
    path    => $facts['path'],
    creates => $creates_path,
  }
}
