class fogmail::tahoe::storage(
  $introducer,
){

  $basedir = '/var/lib/tahoe-lafs/storage'

  class {'::fogmail::tahoe::base': }->

  exec {'init storage':
    command => "tahoe create-node -n storage -i ${introducer} ${basedir}",
    creates => "${basedir}/tahoe.cfg",
  }->
  file {$basedir:
    ensure => directory,
    owner  => 'storage',
    group  => 'nogroup',
    mode   => '0700',
  }->
  file {"${basedir}/private":
    ensure => directory,
    owner  => 'storage',
    group  => 'nogroup',
    mode   => '0700',
  }->
  ::fogmail::tahoe::ports {'storage': }
}
