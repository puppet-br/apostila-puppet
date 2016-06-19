class libreoffice {

  exec { '/usr/bin/apt-get install -y -t squeeze-backports libreoffice':
    timeout => 0
  }

}
