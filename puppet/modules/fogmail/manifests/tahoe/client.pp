class fogmail::tahoe::client (
  $introducer,
){

  $basedir = '/var/lib/tahoe-lafs/client'

  class {'::fogmail::tahoe::base': }->

  exec {'init client':
    command => "tahoe create-client -n client -i ${introducer} ${basedir}",
    creates => "${basedir}/tahoe.cfg",
  }->
  file {$basedir:
    ensure => directory,
    owner  => 'tahoe-client',
    group  => 'nogroup',
    mode   => '0700',
  }->
  file {"${basedir}/private":
    ensure => directory,
    owner  => 'tahoe-client',
    group  => 'nogroup',
    mode   => '0700',
  }->
  ::fogmail::tahoe::ports {'client': }
}
