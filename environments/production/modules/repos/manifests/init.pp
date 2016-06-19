class repos {

  file { '/etc/apt/apt.conf.d/99no-valid-check':
    ensure => file,
    content => 'Acquire::Check-Valid-Until "0";';
  }

  ->

  file { '/etc/apt/sources.list.d/backports.list':
    ensure => absent,
  }

  ->

  file { '/etc/apt/sources.list':
    ensure => file,
    content => "
deb http://archive.debian.org/debian-backports squeeze-backports main
deb http://archive.debian.org/debian squeeze main
deb http://security.debian.org/ squeeze/updates main contrib",
  }

  ->

  exec { '/usr/bin/apt-get update': }

}
