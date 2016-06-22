Classes e Módulos
=================

Ao criar diversos resources para vários nodes, em algum momento passa a fazer sentido que certos resources que são relacionados estejam juntos, ou resources que sejam utilizados muitas vezes possam ser resumidos.

Muitas vezes, configurações específicas de um node precisam ser aproveitadas em outro e torna-se necessário copiar tudo para o outro node. Quando alterações são necessárias, é preciso realizar diversas modificações.

O Puppet fornece alguns mecanismos chamados *resource collections*, que são a aglutinação de vários *resources* para que possam ser utilizados em conjunto.

Classes
-------

Deixe seu conhecimento sobre programação orientada a objetos de lado a partir de agora.

Para o Puppet, uma classe é a junção de vários resources sob um nome, uma unidade. É um bloco de código que pode ser ativado ou desativado.

Definindo uma classe:

.. code-block:: ruby

  class nomedaclasse {
  ...
  }

Dentro do bloco de código da classe podemos colocar qualquer código Puppet, por exemplo:

.. code-block:: ruby

  # vim ntp.pp
  class ntp {
    package { 'ntp':
      ensure => installed,
    }
        
    service { 'ntpd':
      ensure  => running,
      enable  => true,
      require => Package['ntp'],
    }
  }

Vejamos o resultado ao aplicar esse código:

::

  # puppet apply ntp.pp
  Finished catalog run in 0.03 seconds

.. raw:: pdf

 PageBreak


Simplesmente nada aconteceu, pois nós apenas definimos a classe. Para utilizá-la, precisamos declará-la.

.. code-block:: ruby

  # vim ntp.pp
  class ntp {
    package { 'ntp':
      ensure => installed,
    }
        
    service { 'ntpd':
      ensure  => running,
      enable  => true,
      require => Package['ntp'],
    }
  }
  
  # declarando a classe
  class {'ntp': }

Aplicando-a novamente:

::

  # puppet apply --verbose ntp.pp
  Info: Applying configuration version '1352909337'
  /Stage[main]/Ntp/Package[ntp]/ensure: created
  /Stage[main]/Ntp/Service[ntpd]/ensure: ensure changed 'stopped' to 'running'
  Finished catalog run in 5.29 seconds

Portanto, primeiro definimos uma classe e depois a declaramos.

Diretiva include
````````````````
Existe um outro método de usar uma classe, nesse caso usando a diretiva ``include``.

.. code-block:: ruby

  # arquivo ntp.pp
  class ntp {
  ...
  }

  # declarando a classe ntp usando include
  include ntp

O resultado será o mesmo.

.. nota::

  |nota| **Declaração de classes sem usar include**

  A sintaxe ``class {'ntp': }`` é utilizada quando usamos classes que recebem parâmetros.

.. raw:: pdf

 PageBreak


Módulos
-------
Usando classes puramente não resolve nosso problema de repetição de código. O código da classe ainda está presente nos manifests.

Para solucionar esse problema, o Puppet possui o recurso de carregamento automático de módulos (*module autoloader*).

Primeiramente, devemos conhecer de nosso ambiente onde os módulos devem estar localizados. Para isso, verificamos o valor da opção de configuração ``modulepath``.

::

  # puppet config print modulepath
  /etc/puppetlabs/code/environments/production/modules: \
    /etc/puppetlabs/code/modules:/opt/puppetlabs/puppet/modules


No Puppet, módulos são a união de um ou vários manifests que podem ser reutilizados. O Puppet carrega automaticamente os manifests dos módulos presentes em ``modulepath`` e os torna disponíveis.

Estrutura de um módulo
``````````````````````

Como já podemos perceber, módulos são nada mais que arquivos e diretórios. Porém, eles precisam estar nos lugares corretos para que o Puppet os encontre.

Vamos olhar mais de perto o que há em cada diretório.

* ``meu_modulo/``: diretório onde começa o módulo e dá nome ao mesmo

 * ``manifests/``: contém todos os manifests do módulo

  * ``init.pp``: contém definição de uma classe que deve ter o mesmo nome do módulo

  * ``outra_classe.pp``: contém uma classe chamada meu_modulo::outra_classe

  * ``um_diretorio/``: o nome do diretório afeta o nome das classes abaixo

   * ``minha_outra_classe1pp``: contém uma classe chamada meu_modulo::um_diretorio::minha_outra_classe1

   * ``minha_outra_classe2.pp``: contém uma classe chamada meu_modulo::um_diretorio::minha_outra_classe2

 * ``files/``: arquivos estáticos que podem ser baixados pelos agentes

 * ``lib/``: plugins e fatos customizados implementados em Ruby

 * ``templates/``: contém templates usados no módulo

 * ``tests/``: exemplos de como classes e tipos do módulo podem ser chamados

Prática: criando um módulo
--------------------------

1. Primeiramente, crie a estrutura básica de um módulo:

::

  # cd /etc/puppetlabs/code/environments/production/modules
  # mkdir -p ntp/manifests

.. raw:: pdf

 PageBreak


2. O nome de nosso módulo é ``ntp``. Todo módulo deve possuir um arquivo ``init.pp``, e nele deve haver uma classe com o nome do módulo.

.. code-block:: ruby

  # vim /etc/puppetlabs/code/environments/production/modules/ntp/manifests/init.pp
  class ntp {
    case $::operatingsystem {
      centos, redhat: { $service_ntp = "ntpd" }
      debian, ubuntu: { $service_ntp = "ntp" }
      default: { fail("sistema operacional desconhecido") }
    }
  
    package { 'ntp':
      ensure => installed,
    }
        
    service { $service_ntp:
      ensure  => running,
      enable  => true,
      require => Package['ntp'],
    }
  }

3. Deixe o código de ``site.pp`` dessa maneira:

.. code-block:: ruby

  # vim /etc/puppetlabs/code/environments/production/manifests/site.pp
  node 'node1.domain.com.br' {
    include ntp
  }
  
4. Em **node1** aplique a configuração:

::

  # puppet agent -t

5. Aplique a configuração no master também, dessa maneira:

::

  # puppet apply -e 'include ntp'


Agora temos um módulo para configuração de NTP sempre a disposição!

.. nota::

  |nota| **Nome do serviço NTP**

  No Debian/Ubuntu, o nome do serviço é ``ntp``. No CentOS/Red Hat, o nome do serviço é ``ntpd``.

.. raw:: pdf

 PageBreak

Prática: arquivos de configuração em módulos
--------------------------------------------

Além de conter manifests, módulos também podem servir arquivos. Para isso, faça os seguintes passos:

1. Crie um diretório ``files`` dentro do módulo ``ntp``:

::

  # cd /etc/puppetlabs/code/environments/production/modules
  # mkdir -p ntp/files

2. Como aplicamos o módulo ntp no *master*, ele terá o arquivo ``/etc/ntp.conf`` disponível. Copie-o:

::

  # cp /etc/ntp.conf /etc/puppetlabs/code/environments/production/modules/ntp/files/

3. Acrescente  um *resource type* ``file`` ao código da classe ``ntp`` em ``/etc/puppetlabs/code/environments/production/modules/ntp/manifests/init.pp``:

.. code-block:: ruby

  class ntp {
    
    ...
    
    file { 'ntp.conf':
      path     => '/etc/ntp.conf',
      require  => Package['ntp'],
      source   => "puppet:///modules/ntp/ntp.conf",
      notify   => Service[$service_ntp],
    }
  
  }

4. Faça qualquer alteração no arquivo ``ntp.conf`` do módulo (em ``/etc/puppetlabs/code/environments/production/modules/ntp/files/ntp.conf``), por exemplo, acrescentando ou removendo um comentário.

5. Aplique a nova configuração no **node1**.

::

  # puppet agent -t

.. dica::

  |dica| **Servidor de arquivos do Puppet**

  O Puppet pode servir os arquivos dos módulos, e funciona da mesma maneira se você está operando de maneira serverless ou master/agente. Todos os arquivos no diretório ``files`` do módulo ``ntp`` estão disponíveis na URL ``puppet:///modules/ntp/``.
