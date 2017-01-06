Recursos Exportados
=====================

Uma declaração de recursos exportados especifica um estado desejado para um recurso, mas não gerencia o recurso no sistema destino. Ela apenas publica o recurso para ser utilizado por outros nós. Qualquer nó (incluindo o nó no qual o recurso é exportado) pode então coletar o recurso exportado e gerenciar uma cópia do mesmo.

Objetivo
---------

Os recursos exportados permitem que o compilador Puppet compartilhe informações entre nós, combinando informações de catálogos de vários nós. Isso ajuda a gerenciar coisas que dependem do conhecimento dos estados ou atividade de outros nós.

.. nota::

  |nota| **Uso de dados pelos recursos exportados**
  
   Os recursos exportados permitem ao compilador ter acesso à informação, e não podem usar informações que nunca foram enviadas ao compilador, tais como: o conteúdo dos arquivos de um nó. 

Os casos de uso mais comuns são: o monitoramento e os backups. Uma classe que gerencia um serviço como o PostgreSQL pode exportar o recurso ``nagios_service``, que descreve como monitorar o serviço, incluindo informações como o nome do host e a porta. O servidor Nagios pode então coletar todos os recursos ``nagios_service``, e iniciar automaticamente o monitoramento do servidor Postgres.

Sintaxe
-------

O uso de recursos exportados requer duas etapas: declarar e coletar.

.. code-block:: ruby

  class ssh {
    # Declarando a exportação de um recurso:
    @@sshkey { $::hostname:
      type => dsa,
      key  => $::sshdsakey,
    }
    # Coletando os recursos 'sshkey' exportados:
    Sshkey <<| |>>
  }


No exemplo acima, cada nó com a classe ``ssh`` irá exportar a sua própria chave de host SSH e depois coletar a chave de host SSH de cada nó (incluindo o seu próprio). Isso fará com que cada nó confie nas conexões SSH de todos os outros nós.

Declarando um recurso exportado
`````````````````````````````````

Para declarar um recurso exportado, inclua ( ``@@`` ) (um duplo "arroba") antes do tipo de recurso. Exemplo:

.. raw:: pdf
 
 PageBreak

.. code-block:: ruby

  @@nagios_service { "check_zfs${::hostname}":
    use                 => 'generic-service',
    host_name           => $::fqdn,
    check_command       => 'check_nrpe_1arg!check_zfs',
    service_description => "check_zfs${::hostname}",
    target              => '/etc/nagios3/conf.d/nagios_service.cfg',
    notify              => Service[$nagios::params::nagios_service],
  }

Coleta de recursos exportados
``````````````````````````````

Para fazer a coleta de recursos exportados você deve usar um coletor de recursos exportados. Exemplo:


.. code-block:: ruby

  # Coleta todos os recursos ``nagios_service resources`` exportados
  Nagios_service <<| |>> 

  #Coleta apenas o recurso exportado que contém determinada tag
  Concat::Fragment <<| tag == "bacula-storage-dir-${bacula_director}" |>>

Veja mais detalhes sobre os coletores de recursos exportados nesta página: https://docs.puppet.com/puppet/latest/lang_collectors.html#exported-resource-collectors e também no capítulo sobre `Coletores de Recursos`_.

Cada recurso exportado deve ser globalmente exclusivo em cada nó. Se dois recursos forem exportados no mesmo nó com o mesmo título ou mesmo nome/namevar ao tentar coletá-los, a compilação irá falhar. 

Para garantir a exclusividade, cada recurso que você exporta deve incluir uma substring exclusiva para o nó que o exporta para seu título e nome/namevar. A maneira mais conveniente é usar fatos como: o hostname ou fqdn.

Os coletores de recursos exportados não coletam recursos normais ou virtuais. Em particular, eles não podem recuperar recursos *não exportados* de outros catálogos de nós.

Recursos exportados com Nagios
```````````````````````````````

O exemplo a seguir mostra tipos nativos de Puppet para gerenciar arquivos de configuração do Nagios. Esses tipos se tornam muito poderosos quando você exporta e os coleta. Por exemplo, você poderia criar uma classe para algo como o Apache que adiciona uma definição de serviço no seu host Nagios, monitorando automaticamente o servidor web:

::
  
  # /etc/puppetlabs/puppet/modules/nagios/manifests/target/apache.pp

.. code-block:: ruby

  class nagios::target::apache {
    @@nagios_host { $::fqdn:
      ensure  => present,
      alias   => $::hostname,
      address => $::ipaddress,
      use     => 'generic-host',
    }

.. raw:: pdf
 
 PageBreak

.. code-block:: ruby

    @@nagios_service { "check_ping_${::hostname}":
      check_command       => 'check_ping!100.0,20%!500.0,60%',
      use                 => 'generic-service',
      host_name           => $::fqdn,
      notification_period => '24x7',
      service_description => "${::hostname}_check_ping"
    }
  }  

::

  # /etc/puppetlabs/puppet/modules/nagios/manifests/monitor.pp

.. code-block:: ruby

  class nagios::monitor {
    package { [ 'nagios', 'nagios-plugins' ]: ensure => installed, }
    service { 'nagios':
      ensure     => running,
      enable     => true,
      #subscribe => File[$nagios_cfgdir],
      require    => Package['nagios'],
    }
    # Coletando recursos e populando o arquivo /etc/nagios/nagios_*.cfg
    Nagios_host <<||>>
    Nagios_service <<||>>
  }

.. nota::

  |nota| **Mais informações sobre recursos exportados**
  
   Para obter mais informações sobre os recursos exportados acesse a página abaixo.

   https://docs.puppet.com/puppet/latest/lang_exported.html







