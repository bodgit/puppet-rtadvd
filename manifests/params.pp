#
class rtadvd::params {

  $manage_sysctl  = true

  case $::osfamily {
    'OpenBSD': {
      $conf_file      = '/etc/rtadvd.conf'
      $manage_package = false
      $service_name   = 'rtadvd'
      $sysctl_name    = 'net.inet6.ip6.forwarding'
    }
    'RedHat': {
      $conf_file      = '/etc/radvd.conf'
      $manage_package = true
      $package_name   = 'radvd'
      $service_name   = 'radvd'
      $sysctl_name    = 'net.ipv6.conf.all.forwarding'
    }
    default: {
      fail("The ${module_name} module is not supported on ${::osfamily} based system.") # lint:ignore:80chars
    }
  }
}
