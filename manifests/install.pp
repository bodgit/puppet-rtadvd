#
class rtadvd::install {

  if $::rtadvd::manage_package {
    package { $::rtadvd::package_name:
      ensure => present,
    }
  }
}
