#
# !! Receipt based on Jessie for a Mailserver, part of EthACK Mail Infrastructure
#
Exec {
  path => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/use/local/sbin',
}

class {'::fogmail::base':
  line => 'mailserver',
}
include ::fogmail::scripts

class {'::fogmail::tor':
  hidden_services => [
    {
      name  => 'mail',
      ports => [
        {
          hsport => 110, # POP3s
          origin => '127.0.0.1:110',
        },
        {
          hsport => 465, # SMTPs
          origin => '127.0.0.1:465',
        },
        {
          hsport => 993, # IMAPs
          origin => '127.0.0.1:993',
        },
      ],
    },
    {
      name  => 'webmail',
      ports => [
        {
          hsport => 80,
          origin => "127.0.0.1:80",
        },
        {
          hsport => 443,
          origin => "127.0.0.1:443",
        },
      ],
    },
  ],
}

# git
class {'::git':
}->
vcsrepo {'/usr/src/gpg-mailgate':
  ensure   => present,
  provider => 'git',
  source   => 'https://github.com/ajgon/gpg-mailgate.git',
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
  password_hash => postgresql_password('mail', hiera('postgresql_password'))
}->
::postgresql::server::database {'mail':
  owner => 'mail',
}
realize(File['/usr/local/bin/replication-bootstrap'])

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
  dbpassword => hiera('postgresql_password'),
}
class {'::dovecot::master':
  postfix => yes,
}
class {'::dovecot::mail':
}

# Postfix
$postgresql_password = hiera('postgresql_password')
file {'/etc/postfix/virtual.cf':
  ensure  => file,
  owner   => 'root',
  group   => 'postfix',
  mode    => '0640',
  content  => template('fogmail/postfix/virtual.cf'),
  require => Class['::postfix::server'],
}
file {'/etc/postfix/mailboxes.cf':
  ensure  => file,
  owner   => 'root',
  group   => 'postfix',
  mode    => '0640',
  content => template('fogmail/postfix/mailboxes.cf'),
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
::sudo::conf {'postgres-on-postgresql':
  content => 'postgres ALL=(ALL) NOPASSWD: /usr/sbin/service postgresql start, NOPASSWD: /usr/sbin/service postgresql stop';
}
