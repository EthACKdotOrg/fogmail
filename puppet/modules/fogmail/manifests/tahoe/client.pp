class fogmail::tahoe::client {
  class {'::fogmail::tahoe::base': }->

  exec {'init client':
    command => 'tahoe -d "/var/lib/tahoe-lafs/client" create-client -n "client"',
    creates => '/var/lib/tahoe-lafs/client/tahoe.cfg',
  }->
  file {'/var/lib/tahoe-lafs/client':
    ensure => directory,
    owner  => 'client',
    group  => 'nogroup',
    mode   => '0700',
  }->
  file {'/var/lib/tahoe-lafs/client/private':
    ensure => directory,
    owner  => 'client',
    group  => 'nogroup',
    mode   => '0700',
  }
}
