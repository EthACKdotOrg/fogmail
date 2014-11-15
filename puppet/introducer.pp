#
# !! Receipt based on Jessie for a Mailserver, part of EthACK Mail Infrastructure
#
Exec {
  path => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/use/local/sbin',
}

include ::fogmail::base
include ::fogmail::scripts
include ::fogmail::tahoe::introducer

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
}

file {'/var/lib/tahoe-lafs/introducer/introducer.port':
  ensure  => file,
  require => Class['fogmail::tahoe::introducer'],
  mode    => '0600',
  owner   => 'introducer',
  group   => 'nogroup',
  content => '59933',
}

