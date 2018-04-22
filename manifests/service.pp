# @!visibility private
class rtadvd::service {

  service { $::rtadvd::service_name:
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }
}
