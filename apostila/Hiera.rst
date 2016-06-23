Hiera
=====

O Hiera é uma ferramenta que busca por dados de configuração de seus manifests. Ele foi criado pelo R.I.Piennar (que também criou o extlookup).

O Hiera permite separar os dados do código Puppet. Com ele você pode definir dados para diferentes nodes usando o mesmo código. 
Ao invés dos dados serem armazenados dentro de um manifest, com o Hiera eles serão armazenados externamente.

O Hiera facilita a configuração de seus nodes de forma que podemos ter configurações com dados default ou então vários níveis de hierarquia. Ou seja, com o Hiera você pode definir dados comuns para a maioria dos seus nodes e sobrescrever dados para nodes específicos.

Hiera Datasources
-----------------

O Hiera suporta nativamente vários datasources, tais como: YAML, JSON, MySQL, entre outros.

Configurando Hiera
------------------

A primeira coisa a se fazer é criar o arquivo ``/etc/puppetlabs/puppet/hiera.yaml`` ou ``/etc/puppetlabs/code/hiera.yaml`` e definir a hierarquia de pesquisa, o backend e o local onde ele deverá procurar os arquivos, veja o exemplo abaixo:

.. code-block:: ruby

  ---
  :hierarchy:
     - host/%{::fqdn}
     - host/%{::hostname}
     - os/%{::osfamily}
     - domain/%{::domain}
     - common
  :backends:
     - yaml
  :yaml:
     :datadir: '/etc/puppetlabs/code/environments/%{::environment}/hieradata/client1'
    
Observe que na configuração do arquivo, estamos definindo a seguinte precedência de pesquisa:

* host/fqdn
* host/hostname
* os/osfamily
* domain/domain
* common

E definimos também que o backend é o YAML e que os arquivos ficarão no diretório ``/etc/puppetlabs/code/environments/production/hieradata/client1`` (por exemplo). Se o diretório não existir, ele deve ser criado. Dentro desse diretório ficarão os diretórios e arquivos a seguir, por exemplo:

* host/node1.domain.com.br.yaml
* host/node2.yaml
* os/ubuntu.yaml
* os/redhat.yaml
* domain/domain.com.br.yaml
* common.yaml

Dentro de cada arquivo YAML, são definidos os valores para as variaveis a serem usadas nos manifests. Essas variáveis podem ter valores diferentes para cada arquivo especificado no exemplo acima. Se houverem variaveis com o mesmo nome e valores diferentes em vários arquivos, o Hiera seguirá a ordem de prioridade da hierarquia dos dados que definimos no arquivo ``/etc/puppetlabs/puppet/hiera.yaml``. A seguir está o exemplo do conteúdo de um arquivo YAML.

Exemplo do conteúdo do arquivo ``os/node1.domain.com.br.yaml``:

.. code-block:: ruby

  #Apache	
  apache-service: apache2
  
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
  manage_deploy_scripts: true
  scripts_version: 1.0


Depois que o Hiera é configurado, o serviço ``puppetserver`` precisa ser reiniciado.

::

  # service puppetserver restart
  
Criando um módulo para usar dados vindos do Hiera
-------------------------------------------------

Com o Hiera os dados ficam fora do arquivo deixando o código mais limpo, coeso, evitando repetição e erros de edição.

Comandos e consultas Hiera
--------------------------

Execute o hiera para uma pesquisa seguindo a hierarquia definida.

::
  
  # hiera ntp_server

Execute o hiera especificando parâmetros de busca:

::
  
  # hiera ntp_server -yaml web01.example.com.yaml 

É bem simples fazer a pesquisa e testar se vai retornar o que você está esperando.
