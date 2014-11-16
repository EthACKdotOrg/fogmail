class fogmail::tor(
  $hidden_services,
) {

  $tubPort = hiera('tubPort')
  $webPort = hiera('webPort')

  # install torproject sourcelist
  ::apt::source {'torproject':
    location    => 'http://deb.torproject.org/torproject.org',
    release     => 'unstable',
    repos       => 'main',
    key         => 'EE8CBC9E886DDD89',
    pin         => '1001',
    include_src => false,
  }->

  class {'::tor':
    relay                   => false,
    nickname                => false,
    publishserverdescriptor => false,
    dnsPort                 => 5400,
    transPort               => 9040,
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
    hidden_services => $hidden_services,
  }->
  package {'torsocks': }
}
