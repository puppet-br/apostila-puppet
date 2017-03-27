Master / Agent
==============

O Puppet pode ser utilizado com a arquitetura *Master / Agent*. O ciclo de operação nesses casos é o seguinte:

1. Os clientes (chamados de *node*) possuem um agente instalado que permanece em execução e se conecta ao servidor central (chamado tipicamente de *Master*) periodicamente (a cada 30 minutos, por padrão).
2. O node solicita a sua configuração, que é compilada e enviada pelo Master.
3. Essa configuração é chamada de catálogo.
4. O agente aplica o catálogo no node.
5. O resultado da aplicação do catálogo é reportado ao Master, havendo divergências ou não.

Outra maneira comum de implantação do Puppet é a ausência de um agente em execução nos nodes. A aquisição e aplicação do catálogo é agendada na crontab.

.. aviso::

  |aviso| **Catálogo e Relatórios**
  
  Mais detalhes sobre a compilação do catálogo e envio dos relatórios podem ser encontradas, respectivamente, nas seguintes páginas: 
  https://docs.puppet.com/puppet/latest/subsystem_catalog_compilation.html
  https://docs.puppet.com/puppet/latest/reporting_about.html
  https://docs.puppet.com/puppet/latest/report.html
  https://docs.puppet.com/puppet/latest/format_report.html

Resolução de nomes
------------------

A configuração de nome e domínio do sistema operacional, além da resolução de nomes, é uma boa prática para o funcionamento do Puppet, devido ao uso de certificados ``SSL-Secure Socket Layer`` para a autenticação de agentes e o servidor Master.

Para verificar a configuração de seu sistema, utilize o comando ``hostname``. A saída desse comando nos mostra se o sistema está configurado corretamente.

::

  # hostname
  node1
  
  # hostname --domain
  domain.com.br
  
  # hostname --fqdn
  node1.domain.com.br

.. dica::

  |dica| **Configuração de hostname no CentOS/Red Hat e Debian/Ubuntu**
  
  Para resolução de nomes, configure corretamente o arquivo ``/etc/resolv.conf`` com os parâmetros: ``nameserver``, ``domain`` e ``search``. Esses parâmetros devem conter a informação do(s) servidor(es) DNS e do domínio de sua rede.
  
  O arquivo ``/etc/hosts`` deve possuir pelo menos o nome do próprio host em que o agente está instalado. Neste arquivo deve possuir um entrada que informe o seu IP, FQDN e depois o hostname. Exemplo: ``192.168.1.10 node1.domain.com.br node1``.
  
  No Debian/Ubuntu, o ``hostname`` é cadastrado no arquivo ``/etc/hostname``.
  
  No CentOS/Red Hat, o ``hostname`` é cadastrado na variável ``HOSTNAME`` do arquivo ``/etc/sysconfig/network``.

É uma boa prática que sua rede possua a resolução de nomes configurada via DNS. Neste caso, o hostname e domínio de cada sistema operacional devem resolver corretamente para o seu respectivo IP e o IP deve possuir o respectivo nome reverso. 

Porém tecnicamente, a resolução de nomes dos agentes via DNS, não é requisito para o funcionamento do Puppet. Em termos de DNS, o único requisito de fato é que o host consiga resolver o nome do servidor Puppet Master. Por padrão, o agente vai usar o FQDN do host como o ``CN-Common Name`` para indentificá-lo durante a criação do certificado SSL. Entretanto, é possível usar o Puppet em situações que seja necessário que o CN do certificado não possua nenhuma relação com o DNS.


Segurança e autenticação
------------------------

As conexões entre agente e servidor Puppet são realizadas usando o protocolo SSL e, através de certificados, ambos se validam.
Assim, o agente sabe que está falando com o servidor correto e o servidor sabe que está falando com um agente conhecido.

Um servidor Master do Puppet é um CA (Certificate Authority) e implementa diversas funcionalidades como gerar, assinar, revogar e remover certificados para os agentes.

Os agentes precisam de um certificado assinado pelo Master para receber o catálogo com as configurações.

Quando um agente e Master são executados pela primeira vez, um certificado é gerado automaticamente pelo Puppet, usando o FQDN do sistema operacional no certificado.

Prática Master / Agent
----------------------

Instalação do Master
````````````````````
1. O pacote ``puppetserver`` deverá ser instalado no host que atuará como Master. Certifique-se de que o hostname está correto:

::

  # hostname --fqdn
  master.domain.com.br

Assumindo que os passos do capítulo `Instalação`_ foram executados anteriormente, instale o PuppetServer com o comando abaixo.

::

  # puppet resource package puppetserver ensure=latest

Teremos a seguinte estrutura em ``/etc/puppetlabs``:

::

  # tree -F --dirsfirst /etc/puppetlabs/
  /etc/puppetlabs/
  |-- code/
  |   |-- environments/
  |   |   |-- production/
  |   |       |-- hieradata/
  |   |       |-- manifests/
  |   |       |-- modules/
  |   |       |-- environment.conf
  |   |-- modules/
  |   |-- hiera.yaml
  |-- mcollective/
  |   |-- client.cfg
  |   |-- data-help.erb
  |   |-- discovery-help.erb
  |   |-- facts.yaml
  |   |-- metadata-help.erb
  |   |-- rpc-help.erb
  |   |-- server.cfg
  |-- puppet/
  |   |-- ssl/
  |   |-- auth.conf
  |   |-- puppet.conf
  |-- puppetserver/
  |-- |-- conf.d/  
  |   |   |-- auth.conf
  |   |   |-- global.conf
  |   |   |-- puppetserver.conf
  |   |   |-- web-routes.conf
  |   |   |-- webserver.conf
  |   |-- services.d/
  |   |   |-- ca.cfg
  |   |-- logback.xml
  |   |-- request-logging.xml

* Os arquivos e diretórios de configuração mais importantes são:

 * ``auth.conf``: regras de acesso a API REST do Puppet.

 * ``code/environments/production/manifests/``: Armazena a configuração que será compilada e servida para os agentes que executam no ambiente de *production* (padrão).

 * ``code/environments/production/modules/``: Armazena módulos com classes, arquivos, plugins e mais configurações para serem usadas nos manifests para o ambiente de *production* (padrão).

 * ``puppet.conf``: Arquivo de configuração usado pelo Master assim como o Agent.


.. dica::

  |dica| **Sobre os arquivos de configuração**
  
  Nas páginas abaixo você encontra mais detalhes sobre os arquivos de configuração do Puppet:
  
  https://docs.puppet.com/puppet/latest/config_important_settings.html
  https://docs.puppet.com/puppet/latest/dirs_confdir.html
  https://docs.puppet.com/puppet/latest/config_about_settings.html
  https://docs.puppet.com/puppet/latest/config_file_main.html
  https://docs.puppet.com/puppet/latest/configuration.html


.. nota::

  |nota| **Sobre os binários do Puppet**
  
  A instalação do Puppet 4 e todos seus componentes fica em ``/opt/puppetlabs``.

  Os arquivos de configuração ficam em ``/etc/puppetlabs``.

2. Configurando o serviço:

Altere as configurações de memória da JVM que é utilizada pelo Puppet Server para
adequá-las a quantidade de memória disponível.

No CentOS/Red Hat edite o arquivo ``/etc/sysconfig/puppetserver`` e no Debian/Ubuntu edite o arquivo ``/etc/default/puppetserver``:

::
  
  JAVA_ARGS="-Xms256m -Xmx512m"

Reinicie o serviço com o comando abaixo.

::
  
  # service puppetserver restart

Com esta configuração será alocado 512 MB para uso da JVM usada pelo Puppet Server. Por padrão, são alocados 2 GB de memória para uso da JVM.

3. No host PuppetServer, gere um certificado e inicie os serviço com os comandos abaixo.

::

  # puppet cert generate master.domain.com.br
  
  # puppet resource service puppetserver ensure=running enable=true
 
.. nota::

  |nota| **Configuração de firewall e NTP**

  Mantenha a hora corretamente configurada utilizando NTP para evitar problemas na assinatura de certificados.

  A porta ``8140/TCP`` do servidor Puppet Server precisa estar acessível para os demais hosts que possuem o Puppet Agent instalado.

As solicitações de assinatura de certificados no Puppet-Server ficam em: **/etc/puppetlabs/puppet/ssl/ca/requests/**

Os logs do PuppetServer ficam em:

* ``/var/log/puppetlabs/puppetserver/puppetserver.log``
* ``/var/log/puppetlabs/puppetserver/puppetserver-daemon.log`` 

Instalação do agente em node1
`````````````````````````````

Assumindo que os passos do capítulo `Instalação`_ foram executados anteriormente no host ``node1``. O Puppet Agent já está instalado. Configure o Puppet Agent com os passos a seguir.

1. Certifique-se de que o nome e domínio do sistema estejam corretos:

::

  # hostname --fqdn
  node1.domain.com.br

2. Em um host em que o agente está instalado, precisamos configurá-lo para que ela saiba quem é o Master.

No arquivo ``/etc/puppetlabs/puppet/puppet.conf``, adicione as linhas abaixo:

::

  [main]
  certname = node1.domain.com.br
  server = master.domain.com.br
  environment = production
  
  [agent]
  report = true

.. nota::

  |nota| **Conectividade**
  
  Certifique-se de que o servidor Master na porta ``8140/TCP`` está acessível para os nodes.

3. Conecte-se ao Master e solicite assinatura de certificado:

::

  # puppet agent -t
  Info: Creating a new SSL key for node1.puppet
  Info: Caching certificate for ca
  Info: Creating a new SSL certificate request for node1.domain.com.br
  Info: Certificate Request fingerprint (SHA256): 6C:7E:E6:3E:EC:A4:15:56: ...

4. No servidor Master aparecerá a solicitação de assinatura para o host ``node1.domain.com.br``. Assine-a.

 * Os comandos abaixo devem ser executados em **master.domain.com.br**.
 
::

  # puppet cert list
  "node1.domain.com.br" (SHA256) 6C:7E:E6:15:56:49:C3:1E:A5:E4:7F:58:B8: ...

::
  
  # puppet cert sign node1.domain.com.br
  Signed certificate request for node1.domain.com.br
  Removing file Puppet::SSL::CertificateRequest node1.domain.com.br at 
  '/var/lib/puppet/ssl/ca/requests/node1.domain.com.br.pem'

Para listar todos os certificados que já foram assinados pelo Puppet Server, use o comando abaixo:

::
  
  # puppet cert list -a

5. Execute o agente novamente e estaremos prontos para distribuir a configuração.

 * O comando abaixo deve ser executado em **node1.domain.com.br**.

::

  # puppet agent -t
  Info: Caching certificate for node1.domain.com.br
  Info: Caching certificate_revocation_list for ca
  Info: Retrieving plugin
  Info: Caching catalog for node1.domain.com.br
  Info: Applying configuration version '1352824182'
  Info: Creating state file /var/lib/puppet/state/state.yaml
  Finished catalog run in 0.05 seconds

Agora execute os comandos abaixo para iniciar o agente do Puppet como serviço e habilitá-lo para ser executado após o boot do sistema operacional:

::
  
  # puppet resource service puppet ensure=running enable=true

No Puppet-Agent, os certificados assinados ficam em: **/etc/puppetlabs/puppet/ssl/**

Se precisar refazer a assinatura de certificados do host puppet-agent é só parar o serviço ``puppet-agent`` com o comando abaixo e depois apagar os arquivos e sub-diretórios que ficam em: **/etc/puppetlabs/puppet/ssl/**.

::

  # puppet resource service puppet ensure=stop
  
Os logs do puppet-agent ficam em:

* ``/var/log/messages`` (no Debian/Ubuntu)
* ``/var/log/syslog`` (no CentOS/Red Hat).
* ``/var/log/puppetlabs/puppet``

.. dica::

  |dica| **Possíveis problemas com certificados SSL**
  
  É importante que os horários do Master e dos nodes estejam sincronizados.

  Conexões SSL confiam no relógio e, se estiverem incorretos, então sua conexão pode falhar com um erro indicando que os certificados não são confiáveis. 
  
  Procure manter os relógios corretamente configurados utilizando NTP.
  
  Você também pode consultar esta página https://docs.puppet.com/puppet/latest/ssl_regenerate_certificates.html para saber como reconfigurar os certificados no Agente e Master.

  http://www.linuxnix.com/puppet-how-to-remove-puppet-client-from-master/

.. nota::

  |nota| **Recriando certificados para o node**

  Se por algum motivo importante, for necessário recriar o certificado do Puppet Agent de um node, execute o seguintes passos:

1) Removendo o certificado do node no Puppet Server.

::

  # puppet cert clean <name_certificate_hostname>

Exemplo:

::

  # puppet cert clean node1.domain.com.br

.. raw:: pdf
 
 PageBreak

2) Removendo o certificado do node nele mesmo.

::

  # sudo puppet resource service puppet ensure=stopped
  # sudo rm -r /etc/puppetlabs/puppet/ssl
  # sudo puppet cert list -a

Feito isso é só assinar a solicitação do novo certificado no Puppet Server, conforme mostrado neste capítulo. 
Veja mais detalhes em: https://docs.puppet.com/puppet/latest/ssl_regenerate_certificates.html

.. nota::

  |nota| **Removendo solicitações indesejadas de assinaturas de certificado**

  Se no Puppet Master houver solicitações de assinatura de certificados para nodes desconhecidos, basta removê-las executando o comando abaixo no Puppet Server:

::

  # puppet ca destroy <name_certificate_hostname>

Exemplo:

::

  # puppet ca destroy node4.domain.com.br

