# @!visibility private
class rtadvd::config {

  if $::rtadvd::manage_sysctl {
    sysctl { $::rtadvd::sysctl_name:
      ensure => present,
      value  => '1',
    }
  }

  ::concat { $::rtadvd::conf_file:
    owner => 0,
    group => 0,
    mode  => '0644',
    warn  => "# !!! Managed by Puppet !!!\n",
  }

  $::rtadvd::interfaces.each |$resource, $attributes| {
    ::rtadvd::interface { $resource:
      * => $attributes,
    }
  }

  case $::osfamily {
    'OpenBSD': {

      # This bit is horrible, basically rtadvd(8) on OpenBSD will not start
      # unless rtadvd_flags is set to include at least one interface. The
      # datacat_collector resource here is used to collect the titles of all of
      # the instances of the rtadvd::interface defined type which should then
      # update the flags attribute of the service resource however Puppet
      # handles the ensure attribute of the service before the enable attribute
      # (which is when the OpenBSD service provider sets the flags in
      # /etc/rc.conf.local) so in the case of a brand new machine Puppet will
      # try and start rtadvd with no flags so it fails and then halts any
      # further processing of the catalog. So instead, use augeas to add the
      # flags to /etc/rc.conf.local bypassing the service provider. If this
      # behaviour is ever fixed, update the versioncmp() below.

      if versioncmp($::puppetversion, '9.9.9') >= 0 {
        datacat_collector { 'rtadvd interfaces':
          template_body   => "<%= @data['interface'].sort.join(' ') %>",
          target_resource => Service[$::rtadvd::service_name],
          target_field    => 'flags',
        }
      } else {
        # Add an empty rtadvd_flags= line iif one doesn't exist already
        augeas { '/etc/rc.conf.local/rtadvd_flags/empty':
          context => '/files/etc/rc.conf.local',
          changes => 'set 01 rtadvd_flags=',
          onlyif  => "match *[. =~ regexp('rtadvd_flags=.*')] size == 0",
        }

        # This is the augeas resource that will be tweaked by the
        # datacat_collector
        augeas { '/etc/rc.conf.local/rtadvd_flags/interfaces':
          context => '/files/etc/rc.conf.local',
          changes => '',
          require => Augeas['/etc/rc.conf.local/rtadvd_flags/empty'],
        }

        datacat_collector { 'rtadvd interfaces':
          template_body   => "set *[. =~ regexp('rtadvd_flags=.*')] 'rtadvd_flags=\"<%= @data['interface'].sort.join(' ') %>\"'",
          target_resource => Augeas['/etc/rc.conf.local/rtadvd_flags/interfaces'],
          target_field    => 'changes',
          before          => Augeas['/etc/rc.conf.local/rtadvd_flags/interfaces'],
        }
      }
    }
    default: {
      # noop
    }
  }
}
