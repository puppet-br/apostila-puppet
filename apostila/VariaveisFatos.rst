Variáveis, fatos e condições
============================

Variáveis
---------

A linguagem declarativa do Puppet pode usar variáveis, como no exemplo abaixo:

.. code-block:: ruby

  $dns1     = '8.8.8.8'
  $dns2     = '8.8.4.4'
  $arquivo  = '/etc/resolv.conf'
  $conteudo = "nameserver ${dns1}\nnameserver ${dns2}"
  
  file { $arquivo:
    ensure  => 'present',
    content => $conteudo,
  }


Mais alguns detalhes sobre variáveis:

* Variáveis começam com o símbolo de cifrão (``$``).
* Variáveis podem ser usadas para dar nomes em resources e atributos.
* Para interpolar variáveis, a string deve estar entre aspas duplas e a variável deve estar entre chaves: ``${var}``.
* Variáveis do topo do escopo (algo como global) podem ser acessadas assim: ``$::variavel_global``.
* Uma variável só pode ter seu valor atribuído uma vez.

Fatos
-----

Antes de gerar a configuração, o Puppet executa o ``facter``.

O ``facter`` é uma ferramenta fundamental do ecossistema do Puppet, que gera uma lista de variáveis chamadas de fatos, que contém diversas informações sobre o sistema operacional.

Exemplo de saída da execução do comando ``facter``:

::

  # facter
  dmi => {
    bios => {
      release_date => "12/01/2006",
      vendor => "innotek GmbH",
      version => "VirtualBox"
    },
    board => {
      manufacturer => "Oracle Corporation",
      product => "VirtualBox",
      serial_number => "0"
    },
    manufacturer => "innotek GmbH",
    product => {
      name => "VirtualBox",
      serial_number => "0",
      uuid => "95E9353C-948D-4D93-A004-536701C2C673"
    }
  }
  memory => {
    swap => {
      available => "880.00 MiB",
      available_bytes => 922742784,
      capacity => "0%",
      total => "880.00 MiB",
      total_bytes => 922742784,
      used => "0 bytes",
      used_bytes => 0
    },
    system => {
      available => "670.50 MiB",
      available_bytes => 703074304,
      capacity => "11.04%",
      total => "753.68 MiB",
      total_bytes => 790290432,
      used => "83.18 MiB",
      used_bytes => 87216128
    }
  }
  os => {
    architecture => "i386",
    family => "Debian",
    hardware => "i686",
    name => "Debian",
    release => {
      full => "8.2",
      major => "8",
      minor => "2"
    },
    selinux => {
      enabled => false
    }
  }
  system_uptime => {
    days => 0,
    hours => 2,
    seconds => 8416,
    uptime => "2:20 hours"
  }
  timezone => BRST
  virtual => virtualbox


Todas essas variáveis estão disponíveis para uso dentro de qualquer manifest e dizemos que estão no escopo do topo (*top scope*).

O manifest ``facter.pp`` a seguir usa algumas das variáveis geradas pelo ``facter``:

.. code-block:: ruby

  notify {'kernel':
    message => "O sistema operacional é ${::kernel} versão ${::kernelversion}."
  }
  
  notify {'distro':
    message => "A distribuição GNU/Linux é ${::operatingsystem} versão ${::operatingsystemrelease}."
  }

E teremos a seguinte saída:

::

  # puppet apply facter.pp
  Notice: O sistema operacional é Linux versão 3.16.0
  Notice: /Stage[main]/Main/Notify[kernel]/message: defined 'message' as \
     'O sistema operacional é Linux versão 3.16.0'
  Notice: A distribuição é Debian e versão 8.2
  Notice: /Stage[main]/Main/Notify[distro]/message: defined 'message' as \
     'A distribuição é Debian versão 8.2'
  Notice: Applied catalog in 0.03 second

.. nota::

  |nota| **Sistemas operacionais diferentes**
  
  Alguns fatos podem variar de um sistema operacional para outro. Além disso, é possível estender as variáveis do ``facter``.

Prática: facter
```````````````

1. Execute o facter:
 
::
 
   # facter
 
2. Veja que é possível extrair fatos específicos:
 
::
 
   # facter ipaddress
   
   # facter ipaddress_eth0
 
3. É possível extrair os fatos em formatos como YAML e JSON.
 
::
 
  # facter --json
   
  # facter --yaml

Condicionais
------------

A linguagem declarativa do Puppet possui mecanismos de condição que funcionam de maneira parecida em relação às linguagens de programação. Mas existem algumas diferenças.

if
``

Exemplo de um bloco de condição ``if``:

.. code-block:: ruby

  if expressao {
    bloco de codigo
  }
  elsif expressao {
    bloco de codigo
  }
  else {
    bloco de codigo
  }


O ``else`` e o ``elsif`` são opcionais.

Outro exemplo, usando uma variável do ``facter``:

.. code-block:: ruby

  if $::is_virtual == true {
    notify {'Estamos em uma maquina virtual': }
  }
  else {
    notify {'Estamos em uma maquina real': }
  }

Os blocos podem conter qualquer qualquer tipo de definição de configuração, mais alguns exemplos:

.. code-block:: ruby

  if $::osfamily == 'RedHat' {
    service {'sshd':
      ensure => 'running',
      enable => true,
    }
  }
  elsif $::osfamily == 'Debian' {
    service {'ssh':
      ensure => 'running',
      enable => true,
    }
  }
  
.. raw:: pdf

 PageBreak

Expressões
``````````

Comparação
**********

* ``==`` (igualdade, sendo que comparação de strings é **case-insensitive**)
* ``!=`` (diferente)
* ``<`` (menor que)
* ``>`` (maior que)
* ``<=`` (menor ou igual)
* ``>=`` (maior ou igual)
* ``=~`` (casamento de regex)
* ``!~`` (não casamento de regex)
* ``in`` (contém, sendo que comparação de strings é **case-insensitive**)

Exemplo do operador ``in``:

.. code-block:: ruby

      'bat' in 'batata' # TRUE
      'Bat' in 'batata' # TRUE
      'bat' in ['bat', 'ate', 'logo'] # TRUE
      'bat' in { 'bat' => 'feira', 'ate' => 'fruta'} # TRUE
      'bat' in { 'feira' => 'bat', 'fruta' => 'ate' } # FALSE

Operadores booleanos
********************

* ``and``
* ``or``
* ``!`` (negação)

Case
````

Além do ``if``, o Puppet fornece a diretiva ``case``.

.. code-block:: ruby

  case $::operatingsystem {
    centos: { $apache = "httpd" }
    redhat: { $apache = "httpd" }
    debian: { $apache = "apache2" }
    ubuntu: { $apache = "apache2" }
    # fail é uma função
    default: { 
      fail("sistema operacional desconhecido") 
    }
  }
  package {'apache':
    name   => $apache,
    ensure => 'latest',
  }


Ao invés de testar uma única condição, o ``case`` testa a variável em diversos valores. O valor ``default`` é especial, e é auto-explicativo.

O ``case`` pode tentar casar com strings, expressões regulares ou uma lista de ambos.

O casamento de strings é *case-insensitive* como o operador de comparação ``==``.

Expressões regulares devem ser escritas entre barras e são *case sensitive*.

O exemplo anterior pode ser reescrito assim:

.. code-block:: ruby

  case $::operatingsystem {
    centos, redhat: { $apache = "httpd" }
    debian, ubuntu: { $apache = "apache2" }
    default: { fail("sistema operacional desconhecido") }
  }
  package {'apache':
    name   => $apache,
    ensure => 'latest',
  }

Exemplo usando uma expressão regular:

.. code-block:: ruby

  case $ipaddress_eth0 {
    /^127[\d.]+$/: { 
      notify {'erro': 
        message => "Configuração estranha!",
      } 
    }
  }

Selectors
`````````

Ao invés de escolher a partir de um bloco, um ``selector`` escolhe seu valor a partir de um grupo de valores. ``Selectors`` são usados para atribuir valor a variáveis.


.. code-block:: ruby

  $apache = $::operatingsystem ? {
    centos          => 'httpd',
    redhat          => 'httpd',
    /Ubuntu|Debian/ => 'apache2',
    default         => undef,
  }


O ponto de interrogação assinala ``$operatingsystem`` como o pivô do ``selector``, e o valor final que é atribuído a ``$apache`` é determinado pelo valor corresponde de ``$::operatingsystem``.

Pode parecer um pouco estranho, mas há muitas situações em que é a forma mais concisa de se obter um valor.

Prática: melhor uso de variáveis
--------------------------------

Reescreva o código do exemplo a seguir usando uma variável para armazenar o nome do serviço e usando somente um resource ``service`` no seu código.

.. code-block:: ruby

  package {'ntp':
    ensure => 'installed',
  }

  if $::osfamily == 'RedHat' {
    service {'ntpd':
      ensure => 'running',
      enable => 'true',
    }
  }
  elsif $::osfamily == 'Debian' {
    service {'ntp':
      ensure => 'running',
      enable => 'true',
    }
  }
