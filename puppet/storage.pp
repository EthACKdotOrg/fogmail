#
# !! Receipt based on Jessie for a Mailserver, part of EthACK Mail Infrastructure
#
Exec {
  path => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/use/local/sbin',
}

include ::fogmail::base
include ::fogmail::scripts

$tubPort = hiera('tubPort')
$webPort = hiera('webPort')
$introducer = hiera('introducer')

class {'::fogmail::tor':
  hidden_services => [
    {
      name  => 'tahoe',
      ports => [
        {
          hsport => $tubPort,
          origin => "127.0.0.1:${tubPort}",
        },
        {
          hsport => $webPort,
          origin => "127.0.0.1:${webPort}",
        },
      ],
    },
  ],
}
class {'::fogmail::tahoe::storage':
  introducer => $introducer,
}
