Hiera
=====

O Hiera é uma ferramenta que busca por dados de configuração de seus manifests. Ele foi criado pelo R.I.Piennar (que também criou o extlookup).

O Hiera permite separar os dados do código Puppet. Com ele você pode definir dados para diferentes nodes usando o mesmo código. 
Ao invés dos dados serem armazenados dentro de um manifest, com o Hiera eles serão armazenados externamente.

O Hiera facilita a configuração de seus nodes de forma que podemos ter configurações com dados default ou então vários níveis de hierarquia. Ou seja, com o Hiera você pode definir dados comuns para a maioria dos seus nodes e sobrescrever dados para nodes específicos.

Hiera Datasources
-----------------

O Hiera suporta nativamente os datasources YAML e JSON. Outros datasources podem ser suportados com plugin adicionais. Veja os links abaixo:

* https://github.com/crayfishx/hiera-http
* https://github.com/crayfishx/hiera-mysql

Configurando Hiera
------------------

A primeira coisa a se fazer é criar o arquivo ``/etc/puppetlabs/code/hiera.yaml`` e definir a hierarquia de pesquisa, o backend e o local onde ele deverá procurar os arquivos, veja o exemplo abaixo:

.. code-block:: ruby

  ---
  :hierarchy:
     - "host/%{::fqdn}"
     - "host/%{::hostname}"
     - "os/%{::osfamily}"
     - "domain/%{::domain}"
     - "common"
  :backends:
     - yaml
  :yaml:
     :datadir: '/etc/puppetlabs/code/environments/production/hieradata/meucliente'
    
Observe que na configuração do arquivo, estamos definindo a seguinte sequencia de pesquisa:

* host/fqdn
* host/hostname
* os/osfamily
* domain/domain
* common

E definimos também que o backend é o YAML e que os arquivos ficarão no diretório ``/etc/puppetlabs/code/environments/production/hieradata/meucliente``. Se esse diretório não existir, crie-o. 

::

  # mkdir -p /etc/puppetlabs/code/environments/production/hieradata/meucliente

Dentro desse diretório ficarão os diretórios e arquivos a seguir, por exemplo:

* host/node1.domain.com.br.yaml
* host/node2.yaml
* os/ubuntu.yaml
* os/redhat.yaml
* domain/domain.com.br.yaml
* common.yaml

::

  # mkdir -p /etc/puppetlabs/code/environments/production/hieradata/meucliente/os
  # mkdir -p /etc/puppetlabs/code/environments/production/hieradata/meucliente/host
  # mkdir -p /etc/puppetlabs/code/environments/production/hieradata/meucliente/domain
  # cd /etc/puppetlabs/code/environments/production/hieradata/meucliente/
  # touch os/ubuntu.yaml
  # touch os/redhat.yaml
  # touch domain/domain.com.br.yaml
  # touch host/node2.yaml
  # touch host/node1.domain.com.br.yaml
  # touch common.yaml
  
Dentro de cada arquivo YAML, são definidos os valores para as variàveis a serem usadas nos manifests. Essas variáveis podem ter valores diferentes para cada arquivo especificado no exemplo acima. Se houverem variàveis com o mesmo nome e valores diferentes em vários arquivos, o Hiera seguirá a ordem de prioridade da hierarquia dos dados que definimos no arquivo ``/etc/puppetlabs/puppet/hiera.yaml``. A seguir está o exemplo do conteúdo de cada arquivo.

Exemplo do conteúdo do arquivo ``host/node1.domain.com.br.yaml``:

.. code-block:: ruby

  #SSH
  ssh_port: '22'
  ssh_allow_users: 'puppetbr teste'

  #Postfix
  smtp_port: '25'
  smtp_server: '127.0.0.1'

  #Diretorio de conteudos
  content_dir:
      - '/home/puppetbr'
      - '/home/puppetbr/content2/'

Exemplo do conteúdo do arquivo ``host/node2.yaml``:

.. code-block:: ruby

  #SSH
  ssh_port: '2220'
  ssh_allow_users: 'teste'

  #Postfix
  smtp_port: '587'

.. raw:: pdf

 PageBreak

Exemplo do conteúdo do arquivo ``domain/domain.com.br.yaml``:

.. code-block:: ruby
 
  scripts_version: 2.0

Exemplo do conteúdo do arquivo ``os/ubuntu.yaml``:

.. code-block:: ruby

  #Apache	
  apache_service: apache2
  
Exemplo do conteúdo do arquivo ``os/redhat.yaml``:

.. code-block:: ruby

  #Apache	
  apache_service: httpd
  
Exemplo do conteúdo do arquivo ``common.yaml``:

.. code-block:: ruby

  #Apache	
  apache_service: apache2
  
  #SSH
  ssh_port: '22'
  ssh_allow_users: 'puppetbr teste'

  #Postfix
  smtp_port: '25'
  smtp_server: '127.0.0.1'

  #Diretorio de conteudos
  content_dir:
      - '/home/puppetbr'
      - '/home/puppetbr/content/'
  config_package: 'config.tar.bz2'
  deploy_scripts: true
  scripts_version: 1.0

.. raw:: pdf

 PageBreak

Usando o exemplo dado anteriormente, se queremos obter um valor definido para a variável ``apache_service``, o Hiera tentará obter este valor lendo a seguinte sequencia de arquivos e retornará o primeiro valor que encontrar para essa variável.

* host/node1.domain.com.br.yaml
* host/node2.yaml
* os/ubuntu.yaml
* os/redhat.yaml
* domain/domain.com.br.yaml
* common.yaml

Depois que o Hiera é configurado, o serviço ``puppetserver`` precisa ser reiniciado.

::

  # service puppetserver restart
  
Comandos e consultas Hiera
--------------------------

Execute o hiera para uma pesquisa seguindo a hierarquia definida.

::
  
  # hiera apache_service

Execute o hiera especificando parâmetros de busca:

::
  
  # hiera apache_service -yaml ubuntu.yaml 

É bem simples fazer a pesquisa e testar se vai retornar o que você está esperando. O Hiera retornará o valor ``nil`` quando não encontrar um valor para a variável especificada na busca.

.. nota::

  |nota| **Mais documentação sobre o Hiera**

  Mais informações sobre o Hiera podem ser encontradas nesta página: https://docs.puppet.com/hiera/3.1/
  
Criando um módulo para usar dados vindos do Hiera
-------------------------------------------------

Agora que já configuramos o Hiera para localizar dados da estrutura do ``meucliente``, vamos criar um módulo que usará esses dados e que também definirá valores padrão para as variáveis, caso não seja possível obter via Hiera.

1. Primeiramente, crie a estrutura básica de um módulo ``doc``:

::

  # cd /etc/puppetlabs/code/environments/production/modules
  # mkdir -p doc/manifests
  # mkdir -p doc/templates

2. O nosso módulo ``doc`` terá dois manifests: o ``init.pp`` (código principal) e o ``params.pp`` (apenas para declaração de variáveis).

.. code-block:: ruby

  # vim doc/manifests/init.pp

  class doc(

    #Usando as variaveis definidas no manifest params.pp
    $apache_service  = $doc::params::apache_service,
    $ssh_port        = $doc::params::ssh_port,
    $ssh_allow_users = $doc::params::ssh_allow_users,
    $smtp_port       = $doc::params::smtp_port,
    $smtp_server     = $doc::params::smtp_server,
    $content_dir     = $doc::params::content_dir,
    $config_package  = $doc::params::config_package,
    $deploy_scripts  = $doc::params::deploy_scripts,
    $scripts_version = $doc::params::scripts_version,
    ) inherits doc::params {

      file { '/tmp/doc.txt':
        ensure  => 'file',
        content => template("doc/documentation.txt.erb"),
        mode    => '0644',
        owner   => 'root',
        group   => 'root',
      }
  }

.. code-block:: ruby

  # vim doc/manifests/params.pp

  class doc::params {

    #Variaveis gerais
    $content_dir     = hiera('content_dir', ['/home/puppetbr', 
    					     '/home/puppetbr/content/'])   
    $config_package  = hiera('config_package', 'config.tar.bz2')
    $deploy_scripts  = hiera('deploy_scripts', true)
    $scripts_version = hiera('scripts_version', '1.0')

    #Apache
    $apache_service = hiera('apache_service', 'apache2')

    #SSH
    $ssh_port        = hiera('ssh_port', '22')
    $ssh_allow_users = hiera('ssh_allow_users', 'puppetbr teste')

    #SMTP
    $smtp_server = hiera('smtp_server', '127.0.0.1')
    $smtp_port   = hiera('smtp_port', '25')
  }


.. code-block:: ruby

  # vim doc/templates/documentation.txt.erb
  
  #Informacoes sobre SSH
  SSH_PORT=<%= @ssh_port %>
  Usuario que podem acessar o SSH=<%= @ssh_allow_users %>
  Distribuição GNU/Linux=<%= @osfamily %>
  Hostname=<%= @hostname %>
  Qual é o nome do processo do Apache nesta distro? <%= @apache_service %>
  #Informacoes sobre o servico de envio de email
  SMTP_PORT=<%= @smtp_port %>
  SMTP_SERVER=<%= @smtp_server %>
  Diretorio de conteudos=<%= @content_dir %>
  #Informacoes sobre a atualizacao do Script
  PACKAGE=<%= @config_package %>
  ENABLE_DEPLOY=<%= @deploy_scripts %>
  PACKAGE_VERSION=<%= @scripts_version %>


3. Deixe o código de ``site.pp`` dessa maneira:

.. code-block:: ruby

  # vim /etc/puppetlabs/code/environments/production/modules/doc/manifests/params.pp
  node 'node1.domain.com.br' {
    include doc
  }

4. Em **node1** aplique a configuração:

::

  # puppet agent -t

Agora veja o conteúdo do arquivo ``/tmp/doc.txt`` e observe se o conteúdo está como o esperado.

.. code-block:: ruby

  #Informacoes sobre SSH
  SSH_PORT=22
  Usuario que podem acessar o SSH=puppetbr teste
  Distribuição GNU/Linux=Debian
  Hostname=node1
  Qual é o nome do processo do Apache nesta distro? apache2
  #Informacoes sobre o servico de envio de email
  SMTP_PORT=25
  SMTP_SERVER=127.0.0.1
  Diretorio de conteudos=["/home/puppetbr", "/home/puppetbr/content2/"]
  #Informacoes sobre a atualizacao do Script
  PACKAGE=config.tar.bz2
  ENABLE_DEPLOY=true
  PACKAGE_VERSION=1.0
