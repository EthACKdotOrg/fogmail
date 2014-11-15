class fogmail::base {

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

  # install torproject sourcelist
  ::apt::source {'torproject':
    location    => 'http://deb.torproject.org/torproject.org',
    release     => 'unstable',
    repos       => 'main',
    key         => 'EE8CBC9E886DDD89',
    pin         => '1001',
    include_src => false,
    before      => Class['tor'],
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

  class {'::sudo':
  }
}
