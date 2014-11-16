class fogmail::tor {
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
            hsport => $tubPort,
            origin => "127.0.0.1:${tubPort}",
          },
          # web
          {
            hsport => $webPort,
            origin => "127.0.0.1:${webPort}",
          },
        ]
      },
    ]
  }
}
