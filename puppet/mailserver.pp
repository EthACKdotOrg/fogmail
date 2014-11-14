#
# !! Receipt based on Jessie for a Mailserver, part of EthACK Mail Infrastructure
#

Exec {
  path => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/use/local/sbin',
}

# initialize apt
class {'::apt':
  purge_sources_list   => true,
  purge_sources_list_d => true,
  purge_preferences_d  => true,
}

#Exec['apt_update'] -> Package
#Apt::Pin -> Package


::apt::conf {'ignore-recommends':
  content => '
APT::Install-Recommends "0";
APT::Install-Suggests "0";
',
}

# install common source lists
::apt::source {$::lsbdistcodename:
  location => 'http://http.debian.net/debian',
  release  => $::lsbdistcodename,
  repos    => 'main contrib non-free',
}

::apt::source {"${::lsbdistcodename}-updates":
  location => 'http://http.debian.net/debian',
  release  => "${::lsbdistcodename}-updates",
  repos    => 'main contrib non-free',
}

::apt::source {"${::lsbdistcodename}-security":
  location => 'http://security.debian.org',
  release  => "${::lsbdistcodename}/updates",
  repos    => 'main contrib non-free',
}

# install torproject sourcelist

::apt::source {'torproject':
  location    => 'http://deb.torproject.org/torproject.org',
  release     => 'unstable',
  repos       => 'main',
  key         => 'EE8CBC9E886DDD89',
  pin         => '1001',
  include_src => false,
}->

# install Tor and configure it
class {'::tor':
  relay                   => false,
  nickname                => false,
  publishserverdescriptor => false,
  sockspolicies => [
    {
      policy => 'accept',
      target => '127.0.0.1/8'
    },
    {
      policy => 'reject',
      target => '*',
    },
  ],
  hidden_services => [
    {
      name  => 'webmail',
      ports => [
        {
          hsport => 443,
          origin => '127.0.0.1:433',
        },
        {
          hsport => 80,
          origin => '127.0.0.1:80',
        }
      ]
    },
    {
      name  => 'mail',
      ports => [
        {
          hsport => 993,
          origin => '127.0.0.1:993', # IMAPs
        },
        {
          hsport => 110,
          origin => '127.0.0.1:995', # POP3s
        },
        #{
        #  hsport => 25,
        #  origin => '127.0.0.1:25', # SMTP
        #},
        {
          hsport => 465,
          origin => '127.0.0.1:465', # SMTPs
        },
      ]
    },
    {
      name  => 'postgresql',
      ports => [
        {
          hsport => 5432,
          origin => '127.0.0.1:5432',
        }
      ]
    },
    {
      name  => 'tahoe',
      ports => [
        # tub
        {
          hsport => 34000,
          origin => '127.0.0.1:34000',
        },
        # web
        {
          hsport => 3456,
          origin => '127.0.0.1:3456',
        },
        # lafs-rpg
        {
          hsport => 7766,
          origin => '127.0.0.1:7766',
        },
      ]
    },
  ]
}


# Taohe
# some help is provided here
# https://github.com/david415/ansible-tahoe-lafs

# Postgresql
class {'::postgresql::globals':
  encoding        => 'UTF8',
  postgis_version => '2.1',
  version         => '9.4',
}
class {'::postgresql::server':
  service_ensure => 'running',
  service_enable => 'true',
}

::postgresql::server::config_entry {
  'hot_standby':           value => 'on';
  'hot_standby_feedback':  value => 'on';
  'wal_level':             value => 'hot_standby';
  'wal_buffers':           value => '1MB';
  'checkpoint_segments':   value => '8';
  'wal_keep_segments':     value => '50';
  'max_replication_slots': value => '6';
}

::postgresql::server::role {'mail':
}->
::postgresql::server::database {'mail':
  owner => 'mail',
}

::postgresql::server::pg_hba_rule {'mail local':
  type        => 'local',
  database    => 'mail',
  user        => 'mail',
  auth_method => 'ident',
}

# Dovecot
file {'/etc/ssl/private/dovecot.key':
  ensure => file,
  owner  => 'root',
  group  => 'root',
  mode   => '0600',
  source => '/ssl/dovecot.key',
}->
file {'/etc/ssl/certs/dovecot.crt':
  ensure => file,
  owner  => 'root',
  group  => 'root',
  mode   => '0644',
  source => '/ssl/dovecot.crt',
}->
class {'::dovecot': }
class {'::dovecot::ssl':
  ssl          => 'yes',
  ssl_keyfile  => '/etc/ssl/private/dovecot.key',
  ssl_certfile => '/etc/ssl/certs/dovecot.crt',
}
class {'::dovecot::master':
  postfix => yes,
}
include ::dovecot::mail

# Postfix
file {'/etc/postfix/virtual.cf':
  ensure => file,
  owner  => 'root',
  group  => 'postfix',
  mode   => '0640',
  source => '/postfix/virtual.cf',
}
file {'/etc/postfix/mailboxes.cf':
  ensure => file,
  owner  => 'root',
  group  => 'postfix',
  mode   => '0640',
  source => '/postfix/mailboxes.cf',
}
class {'::postfix::server':
  myhostname              => 'mx.cloudfog.org',
  mydomain                => 'cloudfog.org',
  mydestination           => "${::fqdn}, \$myhostname",
  inet_interfaces         => 'all',
  message_size_limit      => '15360000', # 15MB
  mail_name               => 'fogmail',
  virtual_alias_maps      => [
    'pgsql:/etc/postfix/virtual.cf',
  ],
  virtual_mailbox_maps    => [
    'pgsql:/etc/postfix/mailboxes.cf',
  ],
}

# startup script for docker
file {'/usr/local/sbin/startall':
  ensure => file,
  mode   => '0700',
  owner  => 'root',
  group  => 'root',
  source => '/startall',
}

# Replication stuff
file {'/usr/local/bin/replication-bootstrap':
  ensure => file,
  mode   => '0700',
  owner  => 'postgres',
  group  => 'postgres',
  source => '/replication-bootstrap',
}
class {'::sudo':
}
::sudo::conf {'postgres-on-postgresql':
  content => 'postgres ALL=(ALL) NOPASSWD: /usr/sbin/service postgresql start, NOPASSWD: /usr/sbin/service postgresql stop';
}
