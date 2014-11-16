class fogmail::tahoe::introducer {

  class {'::fogmail::tahoe::base': }->
  exec {'init introducer':
    command => 'tahoe  create-introducer "/var/lib/tahoe-lafs/introducer"',
    creates => '/var/lib/tahoe-lafs/introducer/tahoe.cfg',
  }->
  file {'/var/lib/tahoe-lafs/introducer':
    ensure => directory,
    owner  => 'introducer',
    group  => 'nogroup',
    mode   => '0700',
  }->
  ::fogmail::tahoe::ports {'introducer': }
}
