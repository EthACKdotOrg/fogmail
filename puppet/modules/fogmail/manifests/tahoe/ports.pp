define fogmail::tahoe::ports() {
  Ini_setting {
    path => "/var/lib/tahoe-lafs/${name}/tahoe.cfg",
  }
  
  $webPort = hiera('webPort')
  $tubPort = hiera('tubPort')

  ini_setting {
    "set tub port for ${name}":
      section => 'node',
      setting => 'tub.port',
      value   => $tubPort;
    "set tub URL for ${name}":
      section => 'node',
      setting => 'tub.location',
      value   => "CHANGEME:${tubPort},127.0.0.1:${tubPort}";
    "set web port for ${name}":
      section => 'node',
      setting => 'web.port',
      value   => $webPort;
  }
}
