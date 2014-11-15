class fogmail::scripts {

  # startup script for docker
  file {'/usr/local/sbin/startall':
    ensure => file,
    mode   => '0700',
    owner  => 'root',
    group  => 'root',
    source => '/scripts/startall',
  }

  # Replication stuff
  @file {'/usr/local/bin/replication-bootstrap':
    ensure => file,
    mode   => '0700',
    owner  => 'postgres',
    group  => 'postgres',
    source => '/scripts/replication-bootstrap',
  }
}
