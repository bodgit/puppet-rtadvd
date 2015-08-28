#
class rtadvd (
  $conf_file      = $::rtadvd::params::conf_file,
  $interfaces     = {},
  $manage_package = $::rtadvd::params::manage_package,
  $manage_sysctl  = $::rtadvd::params::manage_sysctl,
  $package_name   = $::rtadvd::params::package_name,
  $service_name   = $::rtadvd::params::service_name,
  $sysctl_name    = $::rtadvd::params::sysctl_name,
) inherits ::rtadvd::params {

  validate_absolute_path($conf_file)
  validate_hash($interfaces)
  validate_bool($manage_package)
  validate_bool($manage_sysctl)
  if $manage_package {
    validate_string($package_name)
  }
  if $manage_sysctl {
    validate_string($sysctl_name)
  }

  include ::rtadvd::install
  include ::rtadvd::config
  include ::rtadvd::service

  anchor { 'rtadvd::begin': }
  anchor { 'rtadvd::end': }

  Anchor['rtadvd::begin'] -> Class['::rtadvd::install']
    ~> Class['::rtadvd::config'] ~> Class['::rtadvd::service']
    -> Anchor['rtadvd::end']
}
