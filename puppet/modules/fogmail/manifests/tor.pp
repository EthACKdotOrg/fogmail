class fogmail::tor(
  $hidden_services,
) {

  $tubPort = hiera('tubPort')
  $webPort = hiera('webPort')

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
    hidden_services => $hidden_services,
  }
}
