class rst2pdf {

  include rst2pdf::packages

  package { 'rst2pdf':
    ensure   => 'latest',
    provider => 'pip',
  }

  #Arquivo de template no Debian 6.10
  file {'/usr/lib/python2.7/dist-packages/docutils/parsers/rst/languages/pt_br.py':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => 'puppet:///modules/rst2pdf/pt_br.py',
  }

  #Arquivo de template no Debian 6.10
  #file {'/usr/share/pyshared/docutils/parsers/rst/languages/pt_br.py':
  #  ensure => file,
  #  owner  => 'root',
  #  group  => 'root',
  #  mode   => '0644',
  #  source => 'puppet:///modules/rst2pdf/pt_br.py',
  #}

}
