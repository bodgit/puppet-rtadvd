# rtadvd

Tested with Travis CI

[![Build Status](https://travis-ci.org/bodgit/puppet-rtadvd.svg?branch=master)](https://travis-ci.org/bodgit/puppet-rtadvd)
[![Coverage Status](https://coveralls.io/repos/bodgit/puppet-rtadvd/badge.svg?branch=master&service=github)](https://coveralls.io/github/bodgit/puppet-rtadvd?branch=master)
[![Puppet Forge](http://img.shields.io/puppetforge/v/bodgit/rtadvd.svg)](https://forge.puppetlabs.com/bodgit/rtadvd)
[![Dependency Status](https://gemnasium.com/bodgit/puppet-rtadvd.svg)](https://gemnasium.com/bodgit/puppet-rtadvd)

#### Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with rtadvd](#setup)
    * [Beginning with rtadvd](#beginning-with-rtadvd)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Description

This module manages the IPv6 route advertisement daemon; `rtadvd` or `radvd`
as befits your operating system.

RHEL/CentOS and OpenBSD are supported using Puppet 4.6.0 or later.

## Setup

### Beginning with rtadvd

You need to enable advertisements on at least one interface to be useful with
something like:

```puppet
class { '::rtadvd':
  interfaces => {
    'em0' => {},
  },
}
```

## Usage

Enable route advertisements on an interface, setting the `other` and `managed`
flags as well as managing the IPv6 forwarding sysctl by other means:

```puppet
class { '::rtadvd':
  manage_sysctl => false,
}

::rtadvd::interface { 'ens32':
  other_configuration   => true,
  managed_configuration => true,
}
```

## Reference

The reference documentation is generated with
[puppet-strings](https://github.com/puppetlabs/puppet-strings) and the latest
version of the documentation is hosted at
[https://bodgit.github.io/puppet-rtadvd/](https://bodgit.github.io/puppet-rtadvd/).

## Limitations

This module has been built on and tested against Puppet 4.6.0 and higher.

The module has been tested on:

* OpenBSD 6.2/6.3
* RedHat/CentOS Enterprise Linux 6/7

## Development

The module has both [rspec-puppet](http://rspec-puppet.com) and
[beaker-rspec](https://github.com/puppetlabs/beaker-rspec) tests. Run them
with:

```
$ bundle exec rake test
$ PUPPET_INSTALL_TYPE=agent PUPPET_INSTALL_VERSION=x.y.z bundle exec rake beaker:<nodeset>
```

Please log issues or pull requests at
[github](https://github.com/bodgit/puppet-rtadvd).
