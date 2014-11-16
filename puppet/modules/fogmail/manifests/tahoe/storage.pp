class fogmail::tahoe::storage(
  $introducer,
){
  class {'::fogmail::tahoe::base': }->

  exec {'init storage':
    command => 'tahoe create-node -n storage /var/lib/tahoe-lafs/storage',
    creates => '/var/lib/tahoe-lafs/storage/tahoe.cfg',
  }->
  file {'/var/lib/tahoe-lafs/storage':
    ensure => directory,
    owner  => 'storage',
    group  => 'nogroup',
    mode   => '0700',
  }->
  file {'/var/lib/tahoe-lafs/storage/private':
    ensure => directory,
    owner  => 'storage',
    group  => 'nogroup',
    mode   => '0700',
  }->
  ini_setting {
    'set introducer':
      section => 'client',
      setting => 'introducer.furl',
      value   => $introducer;
  }->
  ::fogmail::tahoe::ports {'storage': }
}
