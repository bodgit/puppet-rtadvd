# Configure advertisements on an interface.
#
# @example Advertise on an interface with the `other` flag set
#   include ::rtadvd
#   ::rtadvd::interface { 'em0':
#     other_configuration => true,
#   }
#
# @param interface The interface name.
# @param managed_configuration Whether to enable the managed configuration flag
#   in advertisements, (i.e. use DHCPv6 exclusively).
# @param max_interval The maximum time allowed between sending unsolicited
#   advertisements.
# @param min_interval The minimum time allowed between sending unsolicited
#   advertisements.
# @param other_configuration Whether to enable the other configuration flag in
#   advertisements, (i.e. use SLAAC for address configuration and DHCPv6 for
#   things like DNS servers, etc.).
#
# @see puppet_classes::rtadvd ::rtadvd
define rtadvd::interface (
  String                     $interface             = $title,
  Boolean                    $managed_configuration = false,
  Optional[Integer[4, 1800]] $max_interval          = undef,
  Optional[Integer[3, 1350]] $min_interval          = undef,
  Boolean                    $other_configuration   = false,
) {

  case $::osfamily {
    'OpenBSD': {

      $managed_raflag = $managed_configuration ? {
        true    => 128,
        default => 0,
      }
      $other_raflag = $other_configuration ? {
        true    => 64,
        default => 0,
      }

      $raflags = $managed_raflag + $other_raflag

      # Turn parameters into an array of termcap-style capabilities
      $capabilities = delete_undef_values([
        $raflags ? {
          0       => undef,
          default => "raflags#${raflags}",
        },
        $max_interval ? {
          undef   => undef,
          default => "maxinterval#${max_interval}",
        },
        $min_interval ? {
          undef   => undef,
          default => "mininterval#${min_interval}",
        },
      ])

      ::concat::fragment { "rtadvd interface ${interface}":
        content => template('rtadvd/rtadvd.erb'),
        target  => $::rtadvd::conf_file,
      }

      datacat_fragment { "rtadvd interface ${interface}":
        target => 'rtadvd interfaces',
        data   => {
          'interface' => [$interface],
        },
      }
    }
    'RedHat': {

      ::concat::fragment { "rtadvd interface ${interface}":
        content => template('rtadvd/radvd.erb'),
        target  => $::rtadvd::conf_file,
      }
    }
    default: {
      # noop
    }
  }
}
