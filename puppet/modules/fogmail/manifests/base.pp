class fogmail::base(
  $line,
) {

  # initialize apt
  class {'::apt':
    purge_sources_list   => true,
    purge_sources_list_d => true,
    purge_preferences_d  => true,
  }

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

  $repo = 'http://download.opensuse.org/repositories/home:/xtreemfs/xUbuntu_14.10/'
  ::apt::source {'xtreemfs':
    location   => $repo,
    repos      => './',
    release    => '',
    key        => '07D6EA4F2FA7E736',
    key_source => "${repo}/Release.key",
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

  class {'::sudo': }
  class {'::ntp':
    restrict => ['127.0.0.1'],
  }

  file {'/etc/profile.d/ps1.sh':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    content => template('fogmail/ps1.erb'),
  }

  class {'::xtreemfs::settings':
    add_repo => false,
    require  => Apt::Source['xtreemfs'],
  }

  file {"/etc/default/fogmail_${line}":
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
  }

  case $line {
    introducer: {
      class {'xtreemfs::role::directory':
      }
      class {'xtreemfs::role::metadata':
        dir_service  => 'localhost',
      }
    }
    storage: {
      class {'xtreemfs::role::storage':
        dir_service => hiera('xstreemfs::dir_server'),
        object_dir  => '/mnt/xtreemfs',
      }
    }
    client: {}
  }

  file {'/etc/xos/truststore':
    ensure  => directory,
    owner   => 'root',
    group   => 'xtreemfs',
    mode    => '0750',
    require => Anchor[$xtreemfs::internal::workflow::packages],
  }

}
