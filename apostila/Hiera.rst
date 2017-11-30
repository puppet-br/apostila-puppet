Hiera
=====

O Hiera é uma ferramenta que busca por dados de configuração de seus manifests. Ele foi criado pelo R.I.Piennar (que também criou o extlookup).

O Hiera permite separar os dados do código Puppet. Com ele você pode definir dados para diferentes nodes usando o mesmo código. 
Ao invés dos dados serem armazenados dentro de um manifest, com o Hiera eles serão armazenados externamente.

O Hiera facilita a configuração de seus nodes de forma que podemos ter configurações com dados default ou então vários níveis de hierarquia. Ou seja, com o Hiera você pode definir dados comuns para a maioria dos seus nodes e sobrescrever dados para nodes específicos.

A partir da versão 4.9 do Puppet, foi lançado a versão 5 do Hiera que irá gradativamente substituir a versão 3, que ainda é bastante ultilizada.

Hiera Datasources
-----------------

O Hiera suporta nativamente os datasources YAML e JSON. Outros datasources podem ser suportados com plugin adicionais. Veja os links abaixo:

* https://github.com/crayfishx/hiera-http
* https://github.com/crayfishx/hiera-mysql

Configurando Hiera
------------------

As versões 3 e 5 do Hiera são incompatíveis entre si. O arquivo de configuração é diferente para cada versão. A seguir são mostrados os exemplos de configuração para cada versão.

A versão 4 do Hiera foi lançada na versão 4.8 do Puppet, mas logo foi substituída pela versão 5.

No Hiera 3:
```````````

A primeira coisa a se fazer é criar o arquivo ``/etc/puppetlabs/code/hiera.yaml`` e definir a hierarquia de pesquisa, o backend e o local onde ele deverá procurar os arquivos, veja o exemplo abaixo:

.. code-block:: ruby

  ---
  :hierarchy:
     - "host/%{::trusted.certname}"
     - "host/%{::fqdn}"
     - "host/%{::hostname}"
     - "os/%{::osfamily}"
     - "domain/%{::domain}"
     - "common"
  :backends:
     - yaml
  :yaml:
     :datadir: '/etc/puppetlabs/code/environments/%{::environment}/hieradata/'

Da forma como o arquivo está definido, o Hiera irá procurar pelos dados dentro do diretório ``hieradata`` de cada environment.

No Hiera 5:
```````````

A primeira coisa a se fazer é remover os arquivos ``/etc/puppetlabs/code/hiera.yaml`` e ``/etc/puppetlabs/code/hiera.yaml`` e criar o arquivo ``/etc/puppetlabs/code/environments/production/hiera.yaml`` para definir a hierarquia de pesquisa apenas dentro do environment ``production``. Veja o exemplo de configuração abaixo:

.. code-block:: ruby

  ---
  version: 5
  defaults:
    datadir: hieradata
    data_hash: yaml_data
  hierarchy:
    - name: "Hosts"
      paths:
        - "host/%{::trusted.certname}.yaml"
        - "host/%{::facts.networking.fqdn}.yaml"
        - "host/%{::facts.networking.hostname}.yaml"
    - name: "Dominios"
      paths:
        - "domain/%{::trusted.domain}.yaml"
        - "domain/%{::domain}.yaml"
    - name: "Tipo de S.O"
      path: "os/%{::osfamily}.yaml"
    - name: "Dados comuns"
      path: "common.yaml"

Com o Hiera 5, cada environment pode ter um arquivo de configuração ``hiera.yaml`` diferente especificando uma hierarquia de pesquisa e organização dos dados sem interferir na configuração dos demais environments.
    
Observe que na configuração do arquivo ``hiera.yaml``, tanto na versão 3 como na 5, estamos definindo a seguinte sequencia de pesquisa:

* host/certname
* host/fqdn
* host/hostname
* os/osfamily
* domain/domain
* common

E definimos também que o backend é o YAML e que os arquivos ficarão no diretório ``/etc/puppetlabs/code/environments/production/hieradata/``. Se esse diretório não existir, crie-o. 

::

  # mkdir -p /etc/puppetlabs/code/environments/production/hieradata/

Dentro desse diretório ficarão os diretórios e arquivos a seguir, por exemplo:

* host/node1.domain.com.br.yaml
* host/node2.yaml
* os/ubuntu.yaml
* os/redhat.yaml
* domain/domain.com.br.yaml
* common.yaml

::

  # mkdir -p /etc/puppetlabs/code/environments/production/hieradata/os
  # mkdir -p /etc/puppetlabs/code/environments/production/hieradata/host
  # mkdir -p /etc/puppetlabs/code/environments/production/hieradata/domain
  # cd /etc/puppetlabs/code/environments/production/hieradata/
  # touch os/ubuntu.yaml
  # touch os/redhat.yaml
  # touch domain/domain.com.br.yaml
  # touch host/node2.yaml
  # touch host/node1.domain.com.br.yaml
  # touch common.yaml
  
Dentro de cada arquivo YAML, são definidos os valores para as variáveis a serem usadas nos manifests. Essas variáveis podem ter valores diferentes para cada arquivo especificado no exemplo acima. Se houverem variáveis com o mesmo nome e valores diferentes em vários arquivos, o Hiera seguirá a ordem de prioridade da hierarquia dos dados que definimos no arquivo ``hiera.yaml``. A seguir está o exemplo do conteúdo de cada arquivo.

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

Usando o exemplo dado anteriormente, se queremos obter um valor definido para a variável ``apache_service``, o Hiera tentará obter este valor lendo a seguinte sequencia de arquivos e retornará o primeiro valor que encontrar para essa variável.

* host/node1.domain.com.br.yaml
* host/node2.yaml
* os/ubuntu.yaml
* os/redhat.yaml
* domain/domain.com.br.yaml
* common.yaml

.. nota::

  |nota| **Obtendo o certname de um node**

  Como já foi visto antes, o certname é definido no arquivo ``/etc/puppetlabs/puppet/puppet.conf``. Para ver qual é o certname configurado use o comando: ``puppet config print certname``. O certname pode ser diferente do FQDN (Fully Qualified Domain Name).

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

  Mais informações sobre o Hiera podem ser encontradas nestas páginas: 
 
  https://docs.puppet.com/hiera/latest/
  https://docs.puppet.com/puppet/4.9/hiera_migrate_environments.html
  https://docs.puppet.com/puppet/4.9/hiera_config_yaml_5.html
  https://docs.puppet.com/hiera/3.3/configuring.html
  https://docs.puppet.com/puppet/4.9/hiera_intro.html
  https://docs.puppet.com/puppet/4.9/hiera_migrate_v3_yaml.html
  https://docs.puppet.com/puppet/4.9/hiera_migrate.html
  https://docs.puppet.com/puppet/latest/lookup_quick.html

Você também pode usar o ``puppet lookup`` para testar. Veja o exemplo abaixo.

::
   
  puppet lookup --debug --explain --node node1.domain.com.br \
   --environment production nome_variavel_a_ser_testada

O puppet lookup só servirá para os testes se alguma vez o node tiver estabelecido comunicação com o puppet server.

.. nota::

  |nota| **Mais documentação sobre o Puppet Lookup**

  Mais informações sobre o ``puppet lookup`` podem ser encontradas nesta página: https://docs.puppet.com/puppet/latest/man/lookup.html
  
Criando um módulo para usar dados vindos do Hiera
-------------------------------------------------

Agora que já configuramos o Hiera para localizar os dados, vamos criar um módulo que irá utilizá-los e também definirá os valores padrão para as variáveis, caso não seja possível obtê-los via Hiera.

1. Primeiramente, crie a estrutura básica de um módulo ``doc``:

::

  # cd /etc/puppetlabs/code/environments/production/modules
  # mkdir -p doc/manifests
  # mkdir -p doc/templates

2. O nosso módulo ``doc`` terá dois manifests: o ``init.pp`` (código principal) e o ``params.pp`` (apenas para declaração de variáveis).

::

  # vim doc/manifests/init.pp

.. code-block:: ruby

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

.. raw:: pdf

 PageBreak

.. code-block:: ruby

      file { '/tmp/doc.txt':
        ensure  => 'file',
        content => template("doc/documentation.txt.erb"),
        mode    => '0644',
        owner   => 'root',
        group   => 'root',
      }
  }

::
  
  # vim doc/manifests/params.pp

.. code-block:: ruby

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


::

  # vim doc/templates/documentation.txt.erb
  
.. code-block:: ruby

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

::

  # vim /etc/puppetlabs/code/environments/production/manifests/site.pp

.. code-block:: ruby

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
  
5. Em **master.domain.com.br** mova o arquivo ``node1.domain.com.br.yaml`` para ``/root/manifests``.

::

  # cd /etc/puppetlabs/code/environments/production/hieradata/host/
  # mv node1.domain.com.br.yaml /root/manifests.
  
6. Em **node1** aplique a configuração:

::

  # puppet agent -t
  
Agora observe o que mudou no conteúdo do arquivo ``/tmp/doc.txt``.  
