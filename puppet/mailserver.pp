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
class {'::apt::unattended_upgrades':
  origins =>  [
    'o=Debian,n=jessie',
    'o=Debian,n=jessie-updates',
    'o=Debian,n=jessie-proposed-updates',
    'o=Debian,n=jessie,l=Debian-Security',
  ],
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

# install cron/anacron in order to get some
# periodic tasks, such as system updates, filter
# updates for SA and so on
package {['cron', 'anacron']: }

# SSH service
class {'::ssh':
  storeconfigs_enabled       => false,
  server_options             => {
    'PasswordAuthentication' => 'no',
    'PermitRootLogin'        => 'without-password',
    'X11Forwarding'          => 'no',
  },
}

# git
class {'::git':
}->
vcsrepo {'/usr/src/gpg-mailgate':
  ensure   => present,
  provider => 'git',
  source   => 'https://github.com/ajgon/gpg-mailgate.git',
}


# Taohe
# some help is provided here
# https://github.com/david415/ansible-tahoe-lafs

package {'tahoe-lafs':
  ensure => latest,
}->
user {'tahoe-mail':
  home   => '/var/lib/tahoe-lafs/tahoe-mail',
  system => true,
}->
exec {'init tahoe-mail':
  command => 'tahoe -d "/var/lib/tahoe-lafs/tahoe-mail" create-client -n "tahoe-mail"',
  creates => '/var/lib/tahoe-lafs/tahoe-mail/tahoe.cfg',
}->
file {'/var/lib/tahoe-lafs/tahoe-mail':
  ensure => directory,
  owner  => 'tahoe-mail',
  group  => 'nogroup',
  mode   => '0700',
}->
file {'/var/lib/tahoe-lafs/tahoe-mail/private':
  ensure => directory,
  owner  => 'tahoe-mail',
  group  => 'nogroup',
  mode   => '0700',
}

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
  password_hash => postgresql_password('mail', 'Ew7aisei3Ugae')
}->
::postgresql::server::database {'mail':
  owner => 'mail',
}

::postgresql::server::pg_hba_rule {'mail local':
  type        => 'local',
  database    => 'mail',
  user        => 'mail',
  auth_method => 'password',
}

# Dovecot
file {'/etc/ssl/private/mail.key':
  ensure => file,
  owner  => 'root',
  group  => 'root',
  mode   => '0600',
  source => '/ssl/mail.key',
}->
file {'/etc/ssl/certs/mail.crt':
  ensure => file,
  owner  => 'root',
  group  => 'root',
  mode   => '0644',
  source => '/ssl/mail.crt',
}->
class {'::dovecot': }
class {'::dovecot::ssl':
  ssl          => 'yes',
  ssl_keyfile  => '/etc/ssl/private/mail.key',
  ssl_certfile => '/etc/ssl/certs/mail.crt',
}
class {'::dovecot::postgres':
  dbname     => 'mail',
  dbusername => 'mail',
  dbpassword => 'Ew7aisei3Ugae',
}
class {'::dovecot::master':
  postfix => yes,
}
class {'::dovecot::mail':
}

# Postfix
file {'/etc/postfix/virtual.cf':
  ensure  => file,
  owner   => 'root',
  group   => 'postfix',
  mode    => '0640',
  source  => '/postfix/virtual.cf',
  require => Class['::postfix::server'],
}
file {'/etc/postfix/mailboxes.cf':
  ensure  => file,
  owner   => 'root',
  group   => 'postfix',
  mode    => '0640',
  source  => '/postfix/mailboxes.cf',
  require => Class['::postfix::server'],
}
class {'::postfix::server':
  inet_interfaces         => 'all',
  myhostname              => 'mx.cloudfog.org',
  mydomain                => 'cloudfog.org',
  mydestination           => "${::fqdn}, \$myhostname",
  message_size_limit      => '15360000', # 15MB
  mail_name               => 'fogmail',
  #spamassassin           => true,
  smtps_content_filter    => [],
  sa_loadplugin           => [
    'Mail::SpamAssassin::Plugin::Hashcash',
    'Mail::SpamAssassin::Plugin::SPF',
    'Mail::SpamAssassin::Plugin::Pyzor',
    'Mail::SpamAssassin::Plugin::Razor2',
    'Mail::SpamAssassin::Plugin::SpamCop',
    'Mail::SpamAssassin::Plugin::AutoLearnThreshold',
    'Mail::SpamAssassin::Plugin::WhiteListSubject',
    'Mail::SpamAssassin::Plugin::MIMEHeader',
    'Mail::SpamAssassin::Plugin::ReplaceTags',
    'Mail::SpamAssassin::Plugin::DKIM',
    'Mail::SpamAssassin::Plugin::Check',
    'Mail::SpamAssassin::Plugin::HTTPSMismatch',
    'Mail::SpamAssassin::Plugin::URIDetail',
    'Mail::SpamAssassin::Plugin::Bayes',
    'Mail::SpamAssassin::Plugin::BodyEval',
    'Mail::SpamAssassin::Plugin::DNSEval',
    'Mail::SpamAssassin::Plugin::HTMLEval',
    'Mail::SpamAssassin::Plugin::HeaderEval',
    'Mail::SpamAssassin::Plugin::MIMEEval',
    'Mail::SpamAssassin::Plugin::RelayEval',
    'Mail::SpamAssassin::Plugin::URIEval',
    'Mail::SpamAssassin::Plugin::WLBLEval',
    'Mail::SpamAssassin::Plugin::VBounce',
    'Mail::SpamAssassin::Plugin::ImageInfo',
    'Mail::SpamAssassin::Plugin::FreeMail',
  ],
  spampd_children         => 4,
  ssl                     => true,
  smtpd_client_restrictions    => [
    'permit_mynetworks',
    'permit_sasl_authenticated',
    'permit_auth_destination',
    'warn_if_reject'
  ],
  smtpd_helo_restrictions      => [
    'permit_mynetworks',
    'permit_sasl_authenticated',
    'reject_invalid_helo_hostname',
    'reject_non_fqdn_hostname'
  ],
  smtpd_recipient_restrictions => [
    'permit_mynetworks',
    'permit_sasl_authenticated',
    'reject_non_fqdn_recipient',
    'reject_invalid_hostname',
    'reject_non_fqdn_sender',
    'reject_non_fqdn_hostname',
    'reject_unknown_sender_domain',
    'reject_unknown_recipient_domain',
    'reject_unauth_destination',
  ],
  smtpd_sasl_auth         => true,
  smtpd_tls_key_file      => '/etc/ssl/private/mail.key',
  smtpd_tls_cert_file     => '/etc/ssl/certs/mail.crt',
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
