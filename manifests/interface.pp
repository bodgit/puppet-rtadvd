#
define rtadvd::interface (
  $managed_configuration = false,
  $max_interval          = undef,
  $min_interval          = undef,
  $other_configuration   = false,
) {

  validate_bool($managed_configuration)
  if $max_interval {
    validate_integer($max_interval)
  }
  if $min_interval {
    validate_integer($min_interval)
  }
  validate_bool($other_configuration)

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

      ::concat::fragment { "rtadvd interface ${name}":
        content => template('rtadvd/rtadvd.erb'),
        target  => $::rtadvd::conf_file,
      }

      datacat_fragment { "rtadvd interface ${name}":
        target => 'rtadvd interfaces',
        data   => {
          'interface' => [$name],
        },
      }
    }
    'RedHat': {

      ::concat::fragment { "rtadvd interface ${name}":
        content => template('rtadvd/radvd.erb'),
        target  => $::rtadvd::conf_file,
      }
    }
  }
}
