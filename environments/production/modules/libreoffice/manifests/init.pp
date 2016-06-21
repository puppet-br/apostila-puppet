class libreoffice {

  #Instalando o libreoffice no Ubuntu 16.04
  package { 'libreoffice':
    ensure   => 'latest',
  }

  #Instalando o libreoffice no Debian 6.10
  #exec { '/usr/bin/apt-get install -y -t squeeze-backports libreoffice':
  #  timeout => 0
  #}

}
