External Node Classifier
========================

Um ENC (External Node Classifier) é uma fonte externa que o Puppet pode utilizar \
para dar classes a nodes, podendo substituir ou funcionar em conjunto com as \
definições de nodes no arquivo ``site.pp``. Caso um ENC e o arquivo ``site.pp`` \
precisem coexistir, as classes declaradas em cada um serão mescladas.

Um ENC é um executável que pode ser chamado pelo master e pode ser escrito em \
qualquer linguagem. Ele recebe como argumento o nome do node a ser classificado, \
e retorna um documento YAML descrevendo as classes para o node.

A construção de um ENC pode ser uma forma poderosa de estender o Puppet, usando \
uma fonte de dados já presente na sua infraestrutura. Dentro do ENC, você pode \
fazer referência a qualquer fonte de dados que desejar. O Puppet só passa o nome \
de um node e recebe de volta as classes, parâmetros e o environment para o node.

Formato YAML
------------

YAML (YAML Ain't Markup Language) é uma linguagem para representação de dados de \
fácil leitura para humanos, também de fácil análise para programas, e utiliza \
uma notação baseada em identação. O Puppet utiliza o formato YAML para receber \
as informações de classificação de node de um ENC.

O YAML retornado pelo ENC deverá seguir as seguintes regras:

* Conter um hash com as chaves ``classes``, ``parameters`` e ``environment``.
* Possuir pelo menos a chave ``classes`` ou ``parameters``.
* Ao sair, retornar código 0 (zero).
* Se retornar diferente de 0, a compilação do catálogo falhará.

Exemplo de um YAML válido para o Puppet:

::

  ---
  classes:
      base:
      puppet:
      zabbix:
          zabbix_server: zabbix.domino.com
  parameters:
      ntp_servers:
          - 0.pool.ntp.org
          - ntp.on.br
      backup: true
  environment: production


Prática: Shell Script como ENC
------------------------------

Os comandos abaixo serão executados no host **master.domain.com.br** e \
aplicaremos a configuração no **node1**.

1. Crie um shell script com o seguinte conteúdo em ``/etc/puppet/enc.sh``:

::

  #!/bin/sh
  cat <<"END"
  ---
  classes:
      motd:
      autofsck:
  parameters:
    puppetserver: master.domain.com.br
  END
  exit 0


2. Ajuste as permissões para execução:

::

  sudo chmod +x /etc/puppet/enc.sh


3. Acrescente o conteúdo abaixo ao arquivo ``puppet.conf`` na seção ``[master]``:

::

  [master]
  node_terminus = exec
  external_nodes = /etc/puppet/enc.sh


4. Reinicie o Puppet Server com o comando abaixo.

::

  sudo service puppetserver restart


5. Certifique-se de que no arquivo ``/etc/puppetlabs/code/environments/production/manifests/site.pp`` \
o node1 **não** tenha as classes ``motd`` e ``autofsck`` declaradas.

6. Execute o agente e veja que as classes foram aplicadas, vindo do ENC.

::

  sudo puppet agent -t


Nesse caso, o ENC está fazendo o equivalente a esse código no arquivo ``site.pp``:

.. code-block:: ruby

  node 'node1.domain.com.br' {
    include motd
    include autofsck
    $puppetserver = 'master.domain.com.br'
  }

.. aviso::

  |aviso| **ENC como ponto único de falha**

  Fazendo o Puppet Master depender de um ENC pode comprometer a disponibilidade \
  de seu serviço. Se o ENC estiver fora do ar, o Puppet Server abortará o envio \
  de configuração para os nodes. Portanto, o ENC pode ser um ponto único de falha.

  Para obter mais informações sobre o ENC acesse a página:
  https://docs.puppet.com/guides/external_nodes.html
