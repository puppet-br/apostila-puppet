Manifests
=========
As declarações de configuração são chamadas de *manifests* (manifestos) e são salvas em arquivos com a extensão ``.pp``.

A principal utilidade da linguagem do Puppet é a declaração de *resources*, representando um estado desejado.

Nos manifests também podemos ter condições, agrupar resources, gerar texto com funções, utilizar e referenciar código em outros manifests e muitas outras coisas. Mas o principal é garantir que resources sejam declarados e gerenciados de maneira correta.

Declarando resources
--------------------

Para manipular diversos aspectos de nosso sistema, devemos estar logados como ``root``. Para melhor organização, vamos colocar nosso código em ``/root/manifests``.

1. Vamos criar nosso primeiro resource, nesse caso, um arquivo:

::

  # mkdir /root/manifests
  # vim /root/manifests/arquivo-1.pp
  file { 'teste':
    path    => '/tmp/teste.txt',
    ensure  => present,
    mode    => '0640',
    content => "Conteudo de teste!\n",
  }

2. Com o manifest criado, é hora de aplicá-lo ao sistema:

::

  # puppet apply /root/manifests/arquivo-1.pp 
  Notice: /Stage[main]/Main/File[teste]/ensure: \
    defined content as '{md5}14c8346a185a9b0dd3f44c22248340f7'
  Notice: Applied catalog in 0.05 seconds

  # cat /tmp/teste.txt 
  Conteudo de teste!
  
  # ls -l /tmp/teste.txt
  -rw-r----- 1 root root 19 Nov 11 13:21 /tmp/teste.txt

* Temos um *resource type*, nesse caso, ``file``, seguido por um par de colchetes que englobam todo o restante das informações sobre o resource.
* Dentro dos colchetes, temos:

 * O *título* do recurso seguido de dois pontos.

 * E uma sequência de ``atributo => valor`` que serve para descrever como deve ser o recurso. Vários valores devem ser separados por vírgula.

Além disso, algumas regras são fundamentais sobre a sintaxe:

* Esquecer de separar atributos usando a vírgula é um erro muito comum, tenha cuidado. O último par ``atributo => valor`` pode ser seguido de vírgula também.

* Letras maiúsculas e minúsculas fazem diferença! Na declaração de recursos, ``File {'teste':...`` significa outra coisa que veremos mais adiante.

* Colocar aspas nos valores faz diferença! Valores e palavras reservadas da linguagem, como ``present``, não precisam estar entre aspas, apenas strings.

* Aspas simples são para valores literais e o único escape é para a própria aspa (``'``) e a barra invertida (``\``).

* Aspas duplas servem para interpolar variáveis e podem incluir um ``\n`` (nova linha).

.. dica::

  |dica| **Teste antes de executar**

  O Puppet fornece algumas funcionalidades que nos permitem testar o código antes de executá-lo.

  Primeiramente podemos validar se existe algum erro de sintaxe, usando o comando ``puppet parser validate arquivo.pp``.

  O comando ``puppet parser validate`` apenas verifica se o manifest está correto.
  
  Para simularmos as alterações que serão ou não feitas, usamos ``puppet apply --noop arquivo.pp``.

Mais exemplos:

.. code-block:: ruby

  # vim /root/manifests/arquivo-2.pp
  file { '/tmp/teste1.txt':
    ensure  => present,
    content => "Ola!\n",
  }
  
  file { '/tmp/teste2':
   ensure => directory,
   mode   => '0644',
  }
  
  file { '/tmp/teste3.txt':
    ensure => link,
    target => '/tmp/teste1.txt',
  }
  
  notify {"Gerando uma notificação!":}
  
  notify {"Outra notificação":}
  
.. raw:: pdf

 PageBreak
 
E, finalmente, vamos aplicar:

::

  # puppet apply /root/manifests/arquivo-2.pp
  Notice: /Stage[main]/Main/File[/tmp/teste1.txt]/ensure: \
    defined content as '{md5}50c32e08ab3f0df064af1a8c98d1b6ce'
  Notice: /Stage[main]/Main/File[/tmp/teste2]/ensure: created
  Notice: /Stage[main]/Main/File[/tmp/teste3.txt]/ensure: created
  Notice: Gerando uma notificação!
  Notice: /Stage[main]/Main/Notify[Gerando uma notificação!]/message: \
    defined 'message' as 'Gerando uma notificação!'
  Notice: Outra notificação
  Notice: /Stage[main]/Main/Notify[Outra notificação]/message: \
    defined 'message' as 'Outra notificação'
  Notice: Applied catalog in 0.05 seconds

  # ls -la /tmp/teste*
  -rw-r--r-- 1 root root    5 Nov 11 13:28 /tmp/teste1.txt
  lrwxrwxrwx 1 root root   15 Nov 11 13:28 /tmp/teste3.txt -> /tmp/teste1.txt
  -rw-r----- 1 root root   19 Nov 11 13:21 /tmp/teste.txt

  /tmp/teste2:
  total 8
  drwxr-xr-x 2 root root 4096 Nov 11 13:28 .
  drwxrwxrwt 8 root root 4096 Nov 11 13:28 ..
  
  # cat /tmp/teste3.txt 
  Ola!

Repare que deixamos de fora alguns atributos, como ``path``, e ainda assim tudo funcionou. Quase todos os *resourse types* possuem algum atributo que assume como valor padrão o título de *resource*. Para o *resource* ``file``, é o atributo ``path``. Para o recurso ``notify``, é ``message``. Em muitos outros casos, como ``user``, ``group``, ``package`` e outros, é simplesmente o atributo ``name``.

No jargão do Puppet, o atributo que recebe como valor padrão o título de um recurso é chamado de ``namevar``. Esse valor é sempre utilizado em um atributo que deve ser capaz de dar uma identidade ao recurso, que deve sempre ser único.

Utilizar o valor do título do *resource* é conveniente, mas algumas vezes pode ser desajeitado.
Em certas ocasiões é melhor dar um título curto que simbolize e identifique o *resource* e atribuir um valor diretamente ao ``namevar`` como um atributo. Isso é prático principalmente se o nome de um recurso é longo.

.. code-block:: ruby

  notify {'grandenotificacao':
    message => "Essa é uma grande notificação! Ela é tão grande que é
                melhor utilizar um nome pequeno como título do resource.",
  }


Não é possível declarar o mesmo *resource* mais de uma vez. O Puppet não permite que *resources* com o mesmo título sejam criados e, em vários casos, também não vai permitir que recursos diferentes tenham o mesmo valor de ``namevar``.

.. raw:: pdf

 PageBreak
 
::

  # vim /root/manifests/conflito.pp 
  file {'arquivo':
  	path => '/tmp/arquivo.txt',
  	ensure => present,
  }
  
  file {'outroarquivo':
  	path => '/tmp/arquivo.txt',
  	ensure => present,
  }
  
  # puppet apply /root/manifests/conflito.pp
  Error: Evaluation Error: Error while evaluating a Resource Statement, \
     Cannot alias File[outroarquivo] to ["/tmp/arquivo.txt"] at \
     /root/manifests/conflito.pp:6; resource ["File", "/tmp/arquivo.txt"] \
     already declared at /root/manifests/conflito.pp:1 at
     /root/manifests/conflito.pp:6:3

Observações sobre o resource file
`````````````````````````````````

Nós declaramos que ``/tmp/teste2/`` teria permissões 0644, porém, o ``ls -lah`` mostrou o comum ``0755``. Isso acontece porque o Puppet ativa o bit de leitura e acesso de diretórios, pois isso é geralmente o que queremos. A ideia é que se possa gerenciar recursivamente arquivos em diretórios com permissão ``0644`` sem tornar os arquivos executáveis.

O tipo ``file`` tem diversos valores para o atributo ``ensure``: ``present``, ``absent``, ``file``, ``directory`` e ``link``. Para saber mais, leia a referência do tipo ``file``.

::

  # puppet describe file

Prática: conhecendo os resources
--------------------------------

Salve o conteúdo de cada exercício em um arquivo ``.pp`` e aplique-o usando o comando ``puppet apply``.

1. Crie uma entrada no arquivo ``/etc/hosts``:

.. code-block:: ruby

  host { 'teste.puppet':
    ensure       => 'present',
    host_aliases => ['teste'],
    ip           => '192.168.56.99',
  }
  
2. Crie um usuário chamado elvis com shell padrão ``/bin/sh`` e grupo ``adm``:

.. code-block:: ruby

  user {'elvis':
    shell      => '/bin/sh',
    gid        => 'adm',
    managehome => true,
  }

.. raw:: pdf

 PageBreak

3. Crie um grupo chamado ``super``:

.. code-block:: ruby

  group {'super':
    gid => 777,
  }

4. Desfaça as alterações anteriores:

.. code-block:: ruby

  file{ 'remove_dir':
    path   => '/home/elvis',
    ensure => absent,
    force  => true,
  }

  user{ 'remove_user':
    name   => elvis,
    ensure => absent,
  }

  group{ 'remove_group':
    name   => super,
    ensure => absent,
  }
  
