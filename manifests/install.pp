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

  $inst_cmd = "duoauthproxy-build/install --install-dir ${duo_authproxy::install_dir} --service-user duo_authproxy_svc --log-group duo_authproxy_grp --create-init-script yes"
  $creates_path = "${duo_authproxy::install_dir}/${duo_authproxy::version}"

  archive { "/tmp/duoauthproxy-${duo_authproxy::version}-src.tgz":
    source       => "https://dl.duosecurity.com/duoauthproxy-${duo_authproxy::version}-src.tgz",
    extract      => true,
    extract_path => '/tmp',
    cleanup      => true,
    creates      => $creates_path,
    proxy_server => $duo_authproxy::proxy_server,
    proxy_type   => $duo_authproxy::proxy_type,
  }

  -> exec { 'duoauthproxy-move':
    command => "mv duoauthproxy-${duo_authproxy::version}*-src duoauthproxy-${duo_authproxy::version}-src",
    cwd     => '/tmp',
    path    => '/bin',
    creates => $creates_path,
  }

  -> exec { 'duoauthproxy-make':
    command     => 'make > duoauthproxy-make.log',
    cwd         => "/tmp/duoauthproxy-${duo_authproxy::version}-src",
    environment => ['PYTHON=python'],
    path        => $facts['path'],
    creates     => $creates_path,
    require     => Package[$duo_authproxy::dep_packages],
  }

  -> exec { 'duoauthproxy-install':
    command     => "/tmp/duoauthproxy-${duo_authproxy::version}-src/${inst_cmd} > duoauthproxy-install.log",
    cwd         => "/tmp/duoauthproxy-${duo_authproxy::version}-src",
    environment => ['PYTHON=python'],
    path        => $facts['path'],
    creates     => $creates_path,
  }

  -> exec { 'duoauthproxy-tag':
    command => "touch ${creates_path}",
    path    => $facts['path'],
    creates => $creates_path,
  }
}
