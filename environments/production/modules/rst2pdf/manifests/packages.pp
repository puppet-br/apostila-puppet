class rst2pdf::packages {

  package { 'vim':
    ensure => installed,
  }

  package { 'python-setuptools':
#    ensure => '0.6.14-4',
    ensure => present,
  }

  package { 'liblcms2-2':
#    ensure => '1.18.dfsg-1.2+b3',
    ensure => present,
  }

  package { 'python-pygments':
#    ensure => '1.3.1+dfsg-1',
    ensure => present,
  }

  package { 'python-reportlab':
#    ensure => '2.4-4',
    ensure => present,
  }

  package { 'python-imaging':
#    ensure => '1.1.7-2',
    ensure => present,
  }

  package { 'libxslt1.1':
#    ensure => '1.1.26-6+squeeze3',
    ensure => present,
  }

  package { 'python-lxml':
#    ensure => '2.2.8-2',
    ensure => present,
  }

  package { 'python-renderpm':
#    ensure => '2.4-4',
    ensure => present,
  }

  package { 'python-docutils':
#    ensure => '0.7-2',
    ensure => present,
  }

  package { 'python-chardet':
#    ensure => '2.0.1-1',
    ensure => present,
  }

  package { 'python-simplejson':
#    ensure => '2.1.1-1',
    ensure => present,
  }

  package { 'libjpeg62':
#    ensure => '6b1-1',
    ensure => present,
  }

  package { 'wwwconfig-common':
#    ensure => '0.2.1',
    ensure => present,
  }

  package { 'libart-2.0-2':
#    ensure => '2.3.21-1',
    ensure => present,
  }

  package { 'libpaper-utils':
#    ensure => '1.1.24',
    ensure => present,
  }

  package { 'python-roman':
#    ensure => '0.7-2',
    ensure => present,
  }

  package { 'python-pkg-resources':
#    ensure => '0.6.14-4',
    ensure => present,
  }

  package { 'libjs-jquery':
#    ensure => '1.4.2-2',
    ensure => present,
  }

  package { 'javascript-common':
#    ensure => '7',
    ensure => present,
  }

  package { 'libpaper1':
#    ensure => '1.1.24',
    ensure => present,
  }

  package { 'python-reportlab-accel':
#    ensure => '2.4-4',
    ensure => present,
  }

  package { 'python-pip':
#    ensure => '0.7.2-1',
    ensure => present,
  }
}
