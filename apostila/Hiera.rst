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
  smtp_server: '127.0.0.1'

.. raw:: pdf

 PageBreak

Exemplo do conteúdo do arquivo ``domain/domain.com.br.yaml``:

.. code-block:: ruby
 
  config_package: 'config.tar.bz2'
  deploy_scripts: true
  scripts_version: 2.0

Exemplo do conteúdo do arquivo ``os/ubuntu.yaml``:

.. code-block:: ruby

  #Apache	
  apache-service: apache2
  
Exemplo do conteúdo do arquivo ``os/redhat.yaml``:

.. code-block:: ruby

  #Apache	
  apache-service: httpd
  
Exemplo do conteúdo do arquivo ``common.yaml``:

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
  deploy_scripts: true
  scripts_version: 1.0

.. raw:: pdf

 PageBreak

Usando o exemplo dado anteriormente, se queremos obter um valor definido para a variável ``apache-service``, o Hiera tentará obter este valor lendo a seguinte sequencia de arquivos e retornará o primeiro valor que encontrar para essa variável.

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
  
  # hiera apache-service

Execute o hiera especificando parâmetros de busca:

::
  
  # hiera apache-service -yaml ubuntu.yaml 

É bem simples fazer a pesquisa e testar se vai retornar o que você está esperando. O Hiera retornará o valor ``nil`` quando não encontrar um valor para a variável especificada na busca.

.. nota::

  |nota| **Mais documentação sobre o Hiera**

  Mais informações sobre o Hiera podem ser encontradas nesta página: https://docs.puppet.com/hiera/3.1/
  
Criando um módulo para usar dados vindos do Hiera
-------------------------------------------------

Com o Hiera os dados ficam fora do arquivo deixando o código mais limpo, coeso, evitando repetição e erros de edição.
