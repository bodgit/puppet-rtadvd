# rtadvd

Tested with Travis CI

[![Build Status](https://travis-ci.org/bodgit/puppet-rtadvd.svg?branch=master)](https://travis-ci.org/bodgit/puppet-rtadvd)
[![Coverage Status](https://coveralls.io/repos/bodgit/puppet-rtadvd/badge.svg?branch=master&service=github)](https://coveralls.io/github/bodgit/puppet-rtadvd?branch=master)
[![Puppet Forge](http://img.shields.io/puppetforge/v/bodgit/rtadvd.svg)](https://forge.puppetlabs.com/bodgit/rtadvd)
[![Dependency Status](https://gemnasium.com/bodgit/puppet-rtadvd.svg)](https://gemnasium.com/bodgit/puppet-rtadvd)

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with rtadvd](#setup)
    * [What rtadvd affects](#what-rtadvd-affects)
    * [Beginning with rtadvd](#beginning-with-rtadvd)
4. [Usage - Configuration options and additional functionality](#usage)
    * [Classes and Defined Types](#classes-and-defined-types)
        * [Class: rtadvd](#class-rtadvd)
        * [Defined Type: rtadvd::interface](#defined-type-rtadvdinterface)
    * [Examples](#examples)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

This module manages the IPv6 route advertisement daemon; `rtadvd` or `radvd`
as befits your operating system.

## Module Description

This module configures the router advertisement daemon typically used on a
machine configured as an IPv6 router.

## Setup

### What rtadvd affects

* Installation of the package providing the route advertisement daemon, if
  required by the operating system.
* The configuration file controlling the advertisements on each enabled
  interface.
* The sysctl setting enabling forwarding of IPv6 packets.
* The service controlling the daemon.

### Beginning with rtadvd

```puppet
include ::rtadvd
```

## Usage

### Classes and Defined Types

#### Class: `rtadvd`

**Parameters within `rtadvd`:**

##### `conf_file`

The location of the configuration file, usually `/etc/rtadvd.conf` or
`/etc/radvd.conf` depending on the operating system.

##### `interfaces`

A shortcut for creating [rtadvd::interface](#defined-type-rtadvdinterface)
without declaring them separately. It should be a hash suitable for passing
to `create_resources()`.

##### `manage_package`

Whether to manage a package or not. Some operating systems have a route
advertisement daemon as part of the base system.

##### `manage_sysctl`

Whether to manage the sysctl to enable forwarding of IPv6 packets. This should
be enabled but you may choose to manage this elsewhere.

##### `package_name`

The name of the package to install that provides the route advertisement
daemon.

##### `service_name`

The name of the service.

##### `sysctl_name`

The name of the sysctl that enables forwarding of IPv6 packets. This is
usually `net.inet6.ip6.forwarding` or `net.ipv6.conf.all.forwarding`
depending on the operating system.

#### Defined Type: `rtadvd::interface`

**Parameters within `rtadvd::interface`:**

##### `name`

The name of the interface.

##### `managed_configuration`

Whether to enable the managed configuration flag in advertisements, (i.e. use
DHCPv6 exclusively).

##### `max_interval`

The maximum time allowed between sending unsolicited advertisements.

##### `min_interval`

The minimum time allowed between sending unsolicited advertisements.

##### `other_configuration`

Whether to enable the other configuration flag in advertisements, (i.e. use
SLAAC for address configuration and DHCPv6 for things like DNS servers, etc.).

### Examples

Install `rtadvd` and enable advertisements on the `em0` interface setting the
other configuration flag in advertisements using the separate defined type:

```puppet
include ::rtadvd

::rtadvd::interface { 'em0':
  other_configuration => true,
}
```

Install `radvd` and enable advertisements on the `ens32` interface setting the
managed configuration flag in advertisements using the interfaces parameter
shortcut:

```puppet
class { '::rtadvd':
  interfaces => {
    ens32 => {
      managed_configuration => true,
    },
  },
}
```

## Reference

### Classes

#### Public Classes

* [`rtadvd`](#class-rtadvd): Main class for configuring the route advertisement
  daemon.

#### Private Classes

* `rtadvd::config`: Handles BSD authentication configuration.
* `rtadvd::install`: Handles `radvd` package installation.
* `rtadvd::params`: Different configuration data for different systems.
* `rtadvd::service`: Handles starting the route advertisement daemon.

### Defined Types

#### Public Defined Types

* [`rtadvd::interface`](#defined-type-rtadvdinterface): Enables advertisements
  for an interface.

## Limitations

This module has been built on and tested against Puppet 3.0 and higher.

The module has been tested on:

* OpenBSD 5.7/5.8/5.9
* RedHat/CentOS Enterprise Linux 6/7

Testing on other platforms has been light and cannot be guaranteed.

## Development

Please log issues or pull requests at
[github](https://github.com/bodgit/puppet-rtadvd).
