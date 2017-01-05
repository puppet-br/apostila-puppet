Recursos Virtuais
==================

A declaração de recurso virtual especifica o estado desejado para um recurso sem necessariamente impor esse estado. Você pode dizer ao Puppet para gerenciar o recurso virtual através da função ``realize`` em qualquer lugar dos seus manifests que fazem parte do seu módulo.

Embora os recursos virtuais só possam ser declarados uma vez, você pode usar a função ``realize`` quantas vezes for necessária, mesmo que seja numa mesma classe ou manifest. 

Objetivo
---------

Os recursos virtuais são úteis para:

* Recursos cuja gestão depende de pelo menos uma das múltiplas condições que estão sendo atendidas.
* Sobreposição de conjuntos de recursos que podem ser necessários em várias classes.
* Recursos que só devem ser geridos se forem cumpridas condições entre várias classes. 

As características que distinguem os recursos virtuais dos demais são:

* *Searchability* (pesquisa) via coletores de recursos, o que permite que você realize a sobreposição de aglomerados de recursos virtuais.
* *Flatness* (planicidade), de tal forma que você pode declarar um recurso virtual e realizá-lo algumas linhas mais tarde sem ter que encher seus módulos com muitas classes de recurso único. 

Um exemplo de uso para recursos virtuais é o gerenciamento de pacotes. Imagine que você tem um módulo no Puppet Master que gerencia a configuração do Apache e que neste módulo existe um manifest que possui o recurso ``package`` para gerenciar a instalação do pacote ``php5.6``. Se houver a necessidade de gerenciar o PHP através de outro módulo e que nele também exista o recurso ``package`` para gerenciar a instalação do pacote ``php5.6``, ao compilar um catálogo, contendo o estado desejado através destes dois módulos, o Puppet irá mostrar um erro de compilação do catálogo e informará que o recurso ``package`` está duplicado, mesmo que o recurso tenha sido declarado em módulos diferentes.

Para resolver este problema você pode criar um módulo para gerenciar pacotes e neste módulo você pode declarar um recurso virtual para gerenciar o pacote ``php5.6``. Nos módulos que gerenciam o Apache e o PHP, você utiliza a função ``realize`` para realizar o estado desejado do recurso virtual. Veja os detalhes no trecho de código abaixo.

.. code-block:: ruby
   
  #Classe pertecente ao módulo packages
  class packages {

    #Declarando um recurso virtual, o pacote nao sera instalado neste ponto.
    @package{ 'php5.6':
      ensure => installed,
    }
  }


  #Classe pertecente ao módulo apache
  class apache {

    #Incluindo as classes do modulo packages
    include packages
    ...

    #Realizando um recurso virtual, o pacote é instalado neste ponto, \
    # caso nao esteja instalado.
    realize(Package['php5.6'])

    ...
  }

  #Classe pertecente ao módulo apache
  class php {
  
    #Incluindo as classes do modulo packages
    include packages
    ...

    #Realizando um recurso virtual, o pacote é instalado neste ponto, \
    # caso nao esteja instalado.
    realize(Package['php5.6'])

    ...
  }

Quando o catálogo for compilado, o Puppet não exibirá erros de compilação porque o recurso ``package``, que gerencia o pacote ``php5.6``, só foi declarado uma vez como sendo um recurso virtual no módulo ``packages``. Os módulos ``apache`` e ``php`` não estão declarando o recurso, estão apenas referenciando o recurso virtual para realizar o estado desejado.

Sintaxe
--------

Para declarar um recurso virtual, você usa o prefixo ( ``@`` ) antes do nome do recurso. Exemplo:

.. code-block:: ruby

  #Declarando um recurso virtual para um usuario
  @user {'deploy':
    uid     => 2004,
    comment => 'Deployment User',
    group   => 'www-data',
    groups  => ["enterprise"],
    tag     => [deploy, web],
  }

  #Declarando um recurso virtual para um array de pacotes
  @package {[
    'build-essential',
    'gcc',
    'gcc-c++',
    'g++',
    'autoconf',
      ensure => installed,
  }

  
Para realizar um ou mais recursos virtuais, use a função ``realize``, que aceita uma ou mais referências de recursos. Exemplo:

.. code-block:: ruby

  realize(Package['gcc'],
          Package['autoconf'],
          Package['gcc-c++'],
          Package['g++'],
          Package['build-essential'],
          User['deploy'],
         ) 

Mesmo que a função ``realize`` referencie várias vezes o mesmo recurso virtual no mesmo manifest, o recurso só será gerenciado apenas uma vez. 

Se um recurso virtual estiver declarado em uma classe, ele não poderá ser realizado na mesma, a menos que a classe seja declarada ou referênciada por outra classe ou módulo. Os recursos virtuais que não forem realizados continuarão disponíveis no catálogo, mas eles estarão marcados como inativos. A função ``realize`` falhará na compilação do catálogo se você tentar realizar um recurso virtual que não foi declarado ou se foi declarado em uma classe ou módulo que em nenhum momento foi referenciado.

.. nota::

  |nota| **Mais informações sobre recursos virtuais**
  
  Para obter mais informações sobre os recursos virtuais, acesse a página abaixo.
  https://docs.puppet.com/puppet/latest/lang_virtual.html

Prática: usando recursos virtuais
----------------------------------

1. Acesse o servidor Puppet Master. Crie a estrutura básica de um módulo ``rvirtual``:

::

  # cd /etc/puppetlabs/code/environments/production/modules
  # mkdir -p rvirtual/manifests
  # mkdir -p rvirtual/templates

2. O módulo ``rvirtual`` terá um manifest: o ``init.pp`` (código principal). Nele declare os recursos virtuais abaixo.

::

  # vim rvirtual/manifests/init.pp

.. code-block:: ruby

  class rvirtual{

     @package {[
       'nfs-utils',
       'nfs-utils-lib',
       'nfs-common',
       ]:
       ensure => installed,
     }

    @file { '/media/storage':
      ensure  => 'directory',
      mode    => '755',
      owner   => root,
      group   => root,
    }

     @file { '/media/storage/doc.txt':
         ensure  => 'file',
         content => template("rvirtual/doc.txt.erb"),
         mode    => '0644',
         owner   => 'root',
         group   => 'root',
         require => File['/media/storage'],
     }
  }

3. Informe o conteúdo abaixo no arquivo de template ``rvirtual/templates/doc.txt.erb``.

.. code-block:: ruby

  #Informacoes sobre o host
  Distribuição GNU/Linux=<%= @osfamily %>
  Hostname=<%= @hostname %>

4. Crie outra estrutura básica para o módulo ``mount``:

::

  # cd /etc/puppetlabs/code/environments/production/modules
  # mkdir -p mount/manifests
 
5. O módulo ``mount`` terá um manifest: o ``init.pp`` (código principal). Nele informe o seguinte conteúdo.

::

  # vim mount/manifests/init.pp

.. code-block:: ruby

  class mount{

    include rvirtual

    case $::operatingsystem {
      'ubuntu': {
         realize(Package['nfs-common'])
      }
      'redhat': {
         realize(Package['nfs-utils','nfs-utils-lib'])
      }
      default: {
       fail('[ERRO] S.O NAO suportado.')
      }
    }

     realize(File['/media/storage/doc.txt'],
	     File['/media/storage'], )

     mount { '/media/storage':
      device  => "192.168.100.13:/home/m2",
      fstype  => 'nfs',
      ensure  => 'mounted',
      options => 'rw',
      atboot  => true,
      before  => File['/media/storage/doc.txt'],
    }
  }

.. aviso::

  |aviso| **Configurar pontos de montagem via NFS**

  Para realizar este exercício, será necessário que você configure o NFSv3 num host remoto e compartilhe dois diretórios, com permissão de leitura e escrita para a montagem de diretório remoto.
  Na Internet você encontra vários tutoriais explicando como fazer isso. Abaixo estão alguns deles.

  Ubuntu: https://www.digitalocean.com/community/tutorials/how-to-set-up-an-nfs-mount-on-ubuntu-16-04

  CentOS/Red Hat 7: https://goo.gl/3NqOs2

6. Deixe o conteúdo do arquivo ``site.pp`` dessa maneira:

::

  # vim /etc/puppetlabs/code/environments/production/manifests/site.pp

.. code-block:: ruby

  node 'node1.domain.com.br' {
    include mount
  }

7. Em **node1** aplique a configuração:

::

  # puppet agent -t

Agora veja se no diretório ``/media/storage/`` existe o arquivo ``doc.txt``.
