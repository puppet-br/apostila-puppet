Funções e Lambda
============================

Funções
--------

As funções são plugins escritos em Ruby, que você pode chamar durante a \
compilação de um catálogo. Uma chamada para qualquer função é uma expressão \
que resolve um valor.

A maioria das funções recebe um ou mais valores como argumentos e, em seguida, \
retorna algum outro valor resultante. O código Ruby na função pode fazer \
diversas coisas para produzir o valor resultante, tais como: avaliação de \
modelos, cálculos matemáticos e busca por valores em uma fonte externa.

As funções também podem:

* causar efeitos colaterais que modificam o catálogo;
* avaliar um bloco de código Puppet, possivelmente usando os argumentos da \
  função para modificar esse código ou controlar como ele é executado.

A linguagem Puppet inclui várias funções internas, e muitas estão disponíveis \
em módulos no Puppet Forge, que será mostrado no capítulo sobre `Puppet Forge`_. \
Um destes módulos é o ``puppetlabs-stdlib`` (https://forge.puppet.com/puppetlabs/stdlib). \
Você também pode escrever funções personalizadas e colocá-las em seus próprios \
módulos.

Localização
````````````

Como qualquer expressão, uma chamada de função pode ser usada em qualquer lugar \
no qual seja permitido retornar o valor resultante.

As chamadas de função também podem ficar por conta própria, o que fará com que o \
valor resultante seja ignorado. (Quaisquer efeitos colaterais ainda ocorrerão.)

Sintaxe
````````

A maioria das funções tem nomes curtos, contendo apenas uma palavra. No entanto, \
a moderna API de função do Puppet também permite nomes de funções qualificadas como: \
``mymodule::foo``.

As funções devem sempre ser chamadas pelos seus nomes completos. Você não pode \
encurtar um nome de uma função qualificada.

Há duas maneiras de chamar funções na linguagem Puppet:

* a forma clássica é chamada por prefixo. Exemplo:

.. code-block:: ruby

  template("ntp/ntp.conf.erb")

* a outra forma é a chamada encadeada. Exemplo:

.. code-block:: ruby

  "ntp/ntp.conf.erb".template

Essas duas formas de chamada possuem as mesmas capacidades, portanto você pode \
escolher a que for mais legível. Em geral, os critérios de escolha são:

* Para funções que usam muitos argumentos, são chamadas de prefixo e são mais \
  fáceis de ler.
* Para funções que recebem um argumento normal e um ``lambda`` (será visto mais \
  adiante), são chamadas encadeadas e são mais fáceis de ler.
* Para uma série de funções onde cada uma leva o resultado da anterior como seu \
  argumento, também são chamadas encadeadas e são mais fáceis de ler.

Vamos conhecer um pouco mais destes dois tipos de chamadas.

Chamadas de função por prefixo
```````````````````````````````

Você pode chamar uma função escrevendo seu nome e fornecendo uma lista de \
argumentos entre parênteses.

.. code-block:: ruby

  file {"/etc/ntp.conf":
    ensure  => file,
    content => template("ntp/ntp.conf.erb"), #chamada de funcao; retorna uma string
  }

  include apache #chamada de funcao; modifica o catálogo

  $binaries = [
    "facter",
    "hiera",
    "mco",
    "puppet",
    "puppetserver",
  ]

  #chamada de funcao com lambda; executa um bloco de código algumas vezes
  each($binaries) |$binary| {
    file {"/usr/bin/$binary":
      ensure => link,
      target => "/opt/puppetlabs/bin/$binary",
    }
  }

Nos exemplos acima, ``template``, ``include`` e ``each`` são todas funções. \
A função ``template`` é usada para retornar um valor, a ``include`` adiciona \
uma classe ao catálogo, e ``each`` executa um bloco de código várias vezes \
com valores diferentes.

A forma geral de uma chamada de função por prefixo é:

.. code-block:: ruby

  name(argument, argument, ...) |$parameter, $parameter, ...| { code block }

Assim temos:

* O nome completo da função, sem aspas.
* Um parênteses de abertura para a passagem de argumentos ( ``(`` ). Parênteses \
  são opcionais ao chamar uma função interna como no caso do ``include``. Eles são \
  obrigatórios em todos os outros casos.
* Zero ou mais argumentos, todos separados por vírgula. Os argumentos podem ser \
  qualquer expressão que resolve um valor. Veja a documentação de cada função para \
  obter o número de argumentos e seus tipos de dados: https://docs.puppet.com/puppet/latest/function.html.
* Um parênteses de fechamento ( ``)`` ), caso tenha sido utilizado um parênteses \
  de abertura.
* Opcionalmente, um lambda e um bloco de código, se a função aceitar.

Chamadas de função encadeadas
```````````````````````````````

Você também pode chamar uma função escrevendo seu primeiro argumento, um ponto \
e o nome da função. Exemplo:

.. code-block:: ruby

  file {"/etc/ntp.conf":
    ensure  => file,
    content => "ntp/ntp.conf.erb".template, #chamada de funcao; retorna uma string
  }

  apache.include #chamada de funcao; modifica um catalogo

  $binaries = [
    "facter",
    "hiera",
    "mco",
    "puppet",
    "puppetserver",
  ]

  #chamada de funcao com lambda; executa um bloco de código algumas vezes.
  $binaries.each |$binary| {
    file {"/usr/bin/$binary":
      ensure => link,
      target => "/opt/puppetlabs/bin/$binary",
    }
  }

Nos exemplos acima, ``template``, ``include`` e ``each`` são todas funções e \
executam o mesmo trabalho explicado na seção anterior.

A forma geral de uma chamada de função encadeada é:

.. code-block:: ruby

  argument.name(argument, ...) |$parameter, $parameter, ...| { code block }

* O primeiro argumento da função, que pode ser qualquer expressão que resolve um \
  valor.
* Um ponto ( ``.`` ).
* O nome completo da função, sem aspas.
* Opcionalmente, os parênteses que contém uma lista de argumentos separados por \
  vírgula, começando com o segundo argumento da função, pois o primeiro argumento \
  já foi citado no começo da chamada.
* Opcionalmente, um lambda e um bloco de código, se a função aceitar.

Comportamento
``````````````

Uma chamada de função (incluindo o nome, argumentos e lambda) constitui uma \
expressão. Ela irá retornar um único valor, e pode ser usada em qualquer lugar \
em que esse valor retornado é aceito.

Uma chamada de função também pode resultar em algum efeito colateral, além de \
retornar um valor.

Todas as funções são executadas durante a compilação, o que significa que elas \
só acessam o código e dados disponíveis no Puppet Master. Para fazer alterações \
em um nó agente, você deve usar um ``resource`` (https://docs.puppet.com/puppet/latest/lang_resources.html). \
Para coletar dados de um nó agente use um fato customizado (https://docs.puppet.com/facter/3.5/custom_facts.html).

Funções de instrução embutidas
```````````````````````````````

São um grupo de funções internas que são usadas apenas para causar efeitos \
colaterais. O Puppet 4 só reconhece as declarações embutidas da própria liguagem. \
Ele não permite adicionar novas funções de instruções como plugins.

A única diferença real entre as funções de instrução e as outras funções é que \
você pode omitir os parênteses ao chamar uma função de declaração com pelo menos \
um argumento (por exemplo, ``include apache``).

Funções como a ``include`` retornam um valor como qualquer outra função, mas \
sempre retornarão um valor indefinido ``undef``.

.. aviso::

  |aviso| **Saiba mais sobre as funções**

  Para obter mais informações sobre as funções acesse a página: https://docs.puppet.com/puppet/latest/lang_functions.html


Prática: Usando as funções
--------------------------------

1) Escreva um manifest para montar diversos diretórios remotos compartilhados \
via NFS em diversos diretórios locais.

.. code-block:: ruby

  $storage_base      = "/home/storage/"
  $storage_dir       = ["${storage_base}/01", "${storage_base}/02",]
  $storage_device_fs = ["192.168.100.13:/home/m2", "192.168.100.13:/home/m3",]

  case $::operatingsystem {
    centos,redhat: { $nfsclient = ["nfs-utils","nfs-utils-lib"] }
    debian,ubuntu: { $nfsclient = ["nfs-common"] }
    # fail é uma função
    default: {
      fail("sistema operacional desconhecido")
    }
  }

  package { $nfsclient:
    ensure => 'latest',
  }

.. raw:: pdf

 PageBreak

.. code-block:: ruby

  file { $storage_base:
    ensure  => 'directory',
    mode    => '755',
    owner   => root,
    group   => root,
    recurse => true,
  }

  file { $storage_dir:
    ensure  => 'directory',
    mode    => '755',
    owner   => root,
    group   => root,
    recurse => true,
    require => File[$storage_base],
  }

  each( $storage_device_fs) | Integer $index, String $value| {
    mount { $storage_dir[$index]:
      device  => $value,
      fstype  => 'nfs',
      ensure  => 'mounted',
      options => 'rw',
      atboot  => true,
      require => File[$storage_dir],
    }
    notice( "Device ${value} mounted in ${storage_dir[$index]}" )
  }

.. aviso::

  |aviso| **Configurar pontos de montagem via NFS**

  Para realizar este exercício, será necessário que você configure o NFSv3 num \
  host remoto e compartilhe dois diretórios, com permissão de leitura e escrita \
  para a montagem de diretório remoto.
  Na Internet você encontra vários tutoriais explicando como fazer isso. \
  Abaixo estão alguns deles.

  Ubuntu: https://www.digitalocean.com/community/tutorials/how-to-set-up-an-nfs-mount-on-ubuntu-16-04

  CentOS/Red Hat 7: https://goo.gl/3NqOs2

Lambdas
-------

São blocos de código Puppet que podem ser passados para funções. Quando uma \
função recebe um lambda, ela pode fornecer valores para os parâmetros do lambda \
e avaliar seu código.

Se você usou outras linguagens de programação, você pode pensar em lambdas como \
simples funções anônimas, que podem ser passadas para outras funções.

Localização
````````````

Lambdas só podem ser usados em chamadas de função. Enquanto qualquer função pode \
aceitar um lambda, apenas algumas funções farão qualquer coisa com eles. Veja \
na página de interação e loops da linguagem Puppet, a lista de funções que são \
mais úteis no uso de lambda (https://docs.puppet.com/puppet/latest/lang_iteration.html).

Lambdas não são válidos em nenhum outro lugar na linguagem Puppet, e não podem \
ser atribuídos a variáveis.

Sintaxe
````````

Lambdas são escritos como uma lista de parâmetros cercados por pipe ( ``|`` ), \
seguido por um bloco de código arbitrário em Puppet. Eles devem ser utilizados \
como parte de uma chamada de função. Exemplo:

.. code-block:: ruby

  $binaries = ["facter", "hiera", "mco", "puppet", "puppetserver"]

  #chamada de funcao com lambda:
  $binaries.each |String $binary| {
    file {"/usr/bin/$binary":
      ensure => link,
      target => "/opt/puppetlabs/bin/$binary",
    }
  }

A forma geral de um lambda é:

.. code-block:: ruby

  |Type data optional $variable|

* A lista de parâmetros é obrigatória, mas pode estar vazia.
* Isso consiste em: uma barra vertical de abertura ( | ) e uma lista separada \
  por vírgulas de zero ou mais parâmetros (por exemplo: String $myparam = "default value" ).
* Cada parâmetro é composto por um tipo de dados opcional, o que restringe os \
  valores que ela permite. O padrão é ``any`` (qualquer). Também faz parte do \
  parâmetro o nome da variável que o representa, incluindo o prefixo ( $ ). \
  Opcionalmente pode passar o sinal de igual ( = ).
* Opcionalmente, pode passar outra vírgula e argumentos extras \
  (por exemplo: String $others = ["default one", "default two"] ), que consiste em:
   * Um tipo de dados opcional, o que restringe os valores permitidos para argumentos \
     extra (padrão ``any``).
   * Um asterisco ( * ).
   * O nome da variável para representar o parâmetro, incluindo o prefixo ( $ ).
   * Um sinal de igual opcional ( = ) e o valor padrão, que pode ser: o valor \
     que corresponde ao tipo de dados especificado ou uma matriz de valores que \
     coincidem com o tipo de dados.
   * Uma vírgula opcional após o último parâmetro.
   * Uma barra vertical fechamento ( | ).
   * Uma chave de abertura ( { ).
   * Um bloco de código de Puppet arbitrário.
   * Uma chave de fechamento ( } ).

Parâmetros e variáveis
````````````````````````

Um lambda pode incluir uma lista de parâmetros e as funções podem definir valores \
para si quando chamam o lambda. Dentro do bloco de código do lambda você pode usar \
cada parâmetro como uma variável.

Funções passam parâmetros lambda por posição, da mesma forma que passa argumentos \
em uma chamada de função. Isto significa que a ordem dos parâmetros é importante, \
mas os seus nomes podem ser qualquer coisa (ao contrário dos parâmetros de classe \
ou de tipo definido, onde os nomes são a interface principal para os usuários).

Cada função decide quantos parâmetros passaram para um lambda e em que ordem. \
Consulte a documentação da função para obter os detalhes https://docs.puppet.com/puppet/latest/function.html.

Na lista de parâmetros, cada parâmetro pode ser precedido por um tipo de dados \
opcional. Se você incluir um, o Puppet verificará o valor do parâmetro no tempo \
de execução para certificar-se de que tem o tipo de dados certo, e exibirá um erro \
se o valor for ilegal. Se nenhum tipo de dados for fornecido, o parâmetro aceitará \
valores de qualquer tipo de dados.

.. aviso::

  |aviso| **Saiba mais sobre os lambdas**

  Para obter mais informações sobre os lambdas e uso nas funções acesse a página: https://docs.puppet.com/puppet/latest/lang_lambdas.html


Prática: Usando funções com lambdas
------------------------------------

1) Escreva um manifest para criar vários links que apontarão para vários alvos \
diferentes, sendo um link para cada alvo.

.. raw:: pdf

 PageBreak

.. code-block:: ruby

  $binaries = ['facter', 'hiera', 'mco', 'puppet']

  #Função com lambda:
  $binaries.each | Integer $index, String $binary| {
    file {"/tmp/${binary}":
      ensure => link,
      target => "/opt/puppetlabs/bin/${binary}",
    }
   notice( "Link $index: nome do link: /tmp/${binary} => \
	   alvo: /opt/puppetlabs/bin/${binary}" )
  }
