define fogmail::tahoe::ports() {
  Ini_setting {
    path => "/var/lib/tahoe-lafs/${name}/tahoe.cfg",
  }

  ini_setting {
    "set tub port for ${name}":
      section => 'node',
      setting => 'tub.port',
      value   => hiera('tubPort');
    "set web port for ${name}":
      section => 'node',
      setting => 'web.port',
      value   => hiera('webPort');
  }
}
