class repos {

  #Instalando os repositorios no Ubuntu 16.04
  file { '/etc/apt/sources.list':
    ensure => file,
    content => "
deb http://br.archive.ubuntu.com/ubuntu/ xenial main restricted
deb http://br.archive.ubuntu.com/ubuntu/ xenial-updates main restricted
deb http://br.archive.ubuntu.com/ubuntu/ xenial universe
deb http://br.archive.ubuntu.com/ubuntu/ xenial-updates universe
deb http://br.archive.ubuntu.com/ubuntu/ xenial multiverse
deb http://br.archive.ubuntu.com/ubuntu/ xenial-updates multiverse
deb http://br.archive.ubuntu.com/ubuntu/ xenial-backports main restricted universe multiverse
deb http://security.ubuntu.com/ubuntu xenial-security main restricted
deb http://security.ubuntu.com/ubuntu xenial-security universe
deb http://security.ubuntu.com/ubuntu xenial-security multiverse",
  }
  ->
  exec { '/usr/bin/apt update': }


  #Instalando os repositorios no Debian 6.10	
  #file { '/etc/apt/apt.conf.d/99no-valid-check':
  #  ensure => file,
  #  content => 'Acquire::Check-Valid-Until "0";';
  #}
  #->
  #file { '/etc/apt/sources.list.d/backports.list':
  #  ensure => absent,
  #}
  #->
  #file { '/etc/apt/sources.list':
  #  ensure => file,
  #  content => "
#deb http://archive.debian.org/debian-backports squeeze-backports main
#deb http://archive.debian.org/debian squeeze main
#deb http://security.debian.org/ squeeze/updates main contrib",
  #}
  #->
  #exec { '/usr/bin/apt-get update': }

}
