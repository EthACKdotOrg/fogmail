class fogmail::tahoe::base {

  user {'client':
    home   => '/var/lib/tahoe-lafs/client',
    system => true,
  }
  
  user {'introducer':
    home   => '/var/lib/tahoe-lafs/introducer',
    system => true,
  }

  user {'storage':
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
    value  => 'all',
  }

  # TODO: python script mounting tahoe
}
