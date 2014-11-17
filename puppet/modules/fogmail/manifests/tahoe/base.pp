class fogmail::tahoe::base {
  $client = 'tahoe-client'
  $introducer = 'tahoe-introducer'
  $storage = 'tahoe-storage'

  user {$client:
    home   => '/var/lib/tahoe-lafs/client',
    system => true,
  }
  
  user {$introducer:
    home   => '/var/lib/tahoe-lafs/introducer',
    system => true,
  }

  user {$storage:
    home   => '/var/lib/tahoe-lafs/storage',
    system => true,
  }

  package {[
    'python-fs-plugin-tahoe-lafs',
    'tahoe-lafs',
    ]:
    ensure => latest,
  }->  
  shellvar {'AUTOSTART':
    target => '/etc/default/tahoe-lafs',
    value  => 'none',
  }

  file {'/usr/local/bin/tahoe-service':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => '/scripts/tahoe-service',
  }

  # TODO: python script mounting tahoe

  if $::virtual != 'Docker' {
    # iptables: forces above Tahoe users through Tor
    class {'::firewall': }
    Firewall {
      table => 'nat',
      chain => 'OUTPUT',
      jump  => 'REDIRECT',
    }
    firewall {'000 redirect "client" DNS':
      uid    => $client,
      proto  => 'udp',
      dport  => 53,
      todest => 5400,
    }
    firewall {'001 redirect "client" tcp':
      uid      => $client,
      proto    => 'tcp',
      outiface => 'eth0',
      todest   => 9040,
    }
    firewall {'000 redirect "introducer" DNS':
      uid    => $introducer,
      proto  => 'udp',
      dport  => 53,
      todest => 5400,
    }
    firewall {'001 redirect "introducer" tcp':
      uid      => $introducer,
      proto    => 'tcp',
      outiface => 'eth0',
      todest   => 9040,
    }
    firewall {'000 redirect "storage" DNS':
      uid    => $storage,
      proto  => 'udp',
      dport  => 53,
      todest => 5400,
    }
    firewall {'001 redirect "storage" tcp':
      uid      => $storage,
      proto    => 'tcp',
      outiface => 'eth0',
      todest   => 9040,
    }
  }
}
