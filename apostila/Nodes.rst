Nodes
=====

O Puppet começa a compilação da configuração de um catálogo pelo arquivo \
``/etc/puppetlabs/code/environments/production/manifests/site.pp``. O ``site.pp`` \
é o ponto de entrada do master para identificar a configuração que será enviada a um agente.

Para saber qual configuração deve ser enviada a um agente, precisamos declarar o \
hostname do agente, utilizando a diretiva ``node``. Diretivas ``node`` casam \
sempre com o nome do agente. Por padrão, o nome do agente é o valor de ``certname`` \
presente no certificado de um agente (por padrão, o FQDN).

Declarando nodes
----------------

Sintaxe para se declarar um node:

.. code-block:: ruby

  # vim /etc/puppetlabs/code/environments/production/manifests/site.pp

  node 'node1.domain.com.br' {
    package {'nano':
      ensure => 'present',
    }
  }

  node 'node2.domain.com.br' {
    package {'vim':
      ensure => 'present',
    }
  }

No exemplo acima, o agente que se identificar como ``node1.domain.com.br`` \
receberá a ordem de instalar o pacote ``nano``, enquanto  ``node2.domain.com.br`` \
deverá instalar o pacote ``vim``.

.. nota::

  |nota| **Classificação de nodes**

  O Puppet fornece um recurso chamado *External Node Classifier* (ENC), que tem \
  a finalidade de delegar o registro de nodes para uma entidade externa, \
  evitando a configuração de longos manifests.

  A documentação oficial está em: https://docs.puppet.com/guides/external_nodes.html

Nomes
-----

A diretiva *node* casa com agentes por nome. O nome de um node é um \
identificador único, que por padrão é valor de **certname**.

.. raw:: pdf

 PageBreak

É possível casar nomes de nodes usando expressões regulares:

.. code-block:: ruby

  Para: www1, www13, www999, a declaracao pode ser:
  node /^www\d+$/ {

  }

  Para: foo.domain.com.br ou bar.domain.com.br, a declaração pode ser:
  node /^(foo|bar)\.domain\.com\.br$/ {

  }

Também podemos aproveitar uma configuração em comum usando uma lista de nomes \
na declaração de um node.

.. code-block:: ruby

  node 'www1.domain.com.br', 'www2.domain.com.br', 'www3.domain.com.br' {

  }

O node default
--------------

Caso o Puppet Master não encontre nenhuma declaração de ``node`` explícita para \
um agente, em última instância pode-se criar um node simplesmente chamado \
``default``, que casará apenas para os agentes que não encontraram uma definição \
de ``node``.

.. code-block:: ruby

  node default {

  }

Prática
-------

1. Declare o host **node1.domain.com.br** no arquivo \
``/etc/puppetlabs/code/environments/production/manifests/site.pp`` do master.

2. Declare o pacote ``tcpdump`` como instalado para **node1.domain.com.br**.

3. Execute o comando ``puppet agent -t`` no ``node1``, certifique-se de que o \
pacote ``tcpdump`` foi instalado.

.. dica::

  |dica| **Simulando a configuração**

  Para simularmos as alterações que serão ou não realizadas no host cliente,\
  usamos o comando ``puppet agent -t --noop``.
