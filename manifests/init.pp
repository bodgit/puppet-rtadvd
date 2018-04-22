# Installs and manages the IPv6 route advertisement daemon.
#
# @example Declaring the class
#   include ::rtadvd
#
# @example Don't manage any IPv6 forwarding sysctl
#   class { '::rtadvd':
#     manage_sysctl => false,
#   }
#
# @param conf_file
# @param interfaces List of interfaces to advertise on.
# @param manage_package Whether a package is needed to be installed.
# @param manage_sysctl Whether to manage the sysctl controlling IPv6 forwarding
#   or not.
# @param package_name The package name.
# @param service_name The service name.
# @param sysctl_name
#
# @see puppet_defined_types::rtadvd::interface ::rtadvd::interface
class rtadvd (
  Stdlib::Absolutepath            $conf_file      = $::rtadvd::params::conf_file,
  Hash[String, Hash[String, Any]] $interfaces     = {},
  Boolean                         $manage_package = $::rtadvd::params::manage_package,
  Boolean                         $manage_sysctl  = $::rtadvd::params::manage_sysctl,
  Optional[String]                $package_name   = $::rtadvd::params::package_name,
  String                          $service_name   = $::rtadvd::params::service_name,
  String                          $sysctl_name    = $::rtadvd::params::sysctl_name,
) inherits ::rtadvd::params {

  contain ::rtadvd::install
  contain ::rtadvd::config
  contain ::rtadvd::service

  Class['::rtadvd::install'] ~> Class['::rtadvd::config']
    ~> Class['::rtadvd::service']
}
