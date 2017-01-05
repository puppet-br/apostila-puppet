Iteração e Loop
============================

A linguagem Puppet possui recursos de loop e iteração, que podem ajudá-lo a escrever códigos mais sucintos e usar dados de forma mais eficaz.

Noções básicas
---------------
       
Em Puppet, características de iteração são implementadas como funções que aceitam blocos de código ( lambdas ), visto no capítulo sobre `Funções`_ .

Ou seja, você escreve um bloco de código (lambda) que requer algum tipo de informação extra, então passa para uma função que pode fornecer essa informação para avaliar e executar o código, possivelmente várias vezes.

Isso difere de algumas outras linguagens em que as construções em loop são palavras-chave especiais; Em Puppet, eles são apenas funções.

Lista de funções de iteração
`````````````````````````````

As seguintes funções podem aceitar um bloco de código e executá-lo de alguma maneira especial. Consulte a documentação de cada função para obter mais detalhes https://docs.puppet.com/puppet/latest/function.html.

* **each** - Repete um bloco de código qualquer por determinado número de vezes, utilizando um conjunto de valores para fornecer diferentes parâmetros de cada vez.
* **slice** - Repete um bloco de código qualquer por determinado número de vezes, utilizando grupos de valores de uma coleção como parâmetros.
* **filter** - Usa um bloco de código para transformar alguma estrutura de dados através da remoção de elementos não relacionados.
* **map** - Usa um bloco de código para transformar todos os valores em alguma estrutura de dados.
* **reduce** - Usa um bloco de código para criar um novo valor ou estrutura de dados através da combinação de valores a partir de uma estrutura de dados fornecida.
* **with** - Avalia um bloco de código uma vez, isolando-o em seu próprio escopo local. Não itera, mas tem uma semelhança familiar com as funções de iteração. 

Sintaxe
```````

Veja o capítulo sobre `Funções`_ para conhecer a sintaxe de chamadas de função e para conhecer a sintaxe de blocos de código que pode ser passado às funções. 

Em geral, as funções de iteração recebem uma matriz ou um hash como seu principal argumento para, em seguida, iterar sobre seus valores.

Argumentos comuns lambda
`````````````````````````

As funções ``each``, ``filter`` e ``map`` podem aceitar um lambda com um ou dois parâmetros. Os valores que passam para um lambda variam, dependendo do número de parâmetros e do tipo de estrutura de dados que você está iterando:

+--------------------+---------------------------------------------+-------------------------+
| Tipo de dados      | Parâmetro Único                             |   Dois parâmetros       |
+====================+=============================================+=========================+
| Array              | <VALUE>                                     | <INDEX>,                |
+--------------------+---------------------------------------------+-------------------------+
| Hash               | [<KEY>, <VALUE>] (two-element array)        | <KEY>, <VALUE>          |
+--------------------+---------------------------------------------+-------------------------+

Por exemplo:

.. code-block:: ruby

  ['a','b','c'].each |Integer $index, String $value| { notice("${index} = ${value}") }

Isso resultará em:

.. code-block:: ruby

  Notice: Scope(Class[main]): 0 = a
  Notice: Scope(Class[main]): 1 = b
  Notice: Scope(Class[main]): 2 = c

As funções ``slice`` e ``reduce`` lidam com parâmetros de forma diferente. Consulte a documentação oficial para obter detalhes.

Exemplos na declaração de recursos
```````````````````````````````````

Uma vez que o foco da linguagem Puppet é declarar recursos, a maioria das pessoas vai querer usar a iteração para declarar muitos recursos semelhantes de uma vez:

.. code-block:: ruby

  $binaries = ['facter', 'hiera', 'mco', 'puppet', 'puppetserver']

  # function call with lambda:
  $binaries.each |String $binary| {
    file {"/usr/bin/${binary}":
      ensure => link,
      target => "/opt/puppetlabs/bin/${binary}",
    }
  }

Neste exemplo, temos uma matriz de nomes de comandos que queremos usar no caminho e no destino de cada link simbólico. A função ``each`` faz isso muito fácil e sucinta.

Usando iteração para transformar dados
```````````````````````````````````````

Você também pode usar a iteração para transformar dados em formulários mais úteis. Por exemplo:

Exemplo 1:

.. code-block:: ruby

  $filtered_array = [1,20,3].filter |$value| { $value < 10 }
  # retorna [1,3]

Exemplo 2:

.. code-block:: ruby

  $sum = reduce([1,2,3]) |$result, $value|  { $result + $value }
  # retorna 6

.. raw:: pdf

 PageBreak

Exemplo 3:

.. code-block:: ruby

  $hash_as_array = ['key1', 'first value',
                 'key2', 'second value',
                 'key3', 'third value']

  $real_hash = $hash_as_array.slice(2).reduce( {} ) |Hash $memo, Array $pair| {
    $memo + $pair
  }
  # retorna {"key1"=>"first value", "key2"=>"second value", "key3"=>"third value"}

Prática: Usando funções de loop e iteração
-------------------------------------------

1) Escreva um manifest, no qual dado um hash retorne todos os valores que contém o trecho "berry"

.. code-block:: ruby

  $data = { "orange" => 0, "blueberry" => 1, "raspberry" => 2 }
  $filtered_data = $data.filter |$items| { $items[0] =~ /berry$/ }
  notice( "Resultado: $filtered_data" )

2) Escreva outro manifest, no qual dado um hash retorne todos os valores que contém o trecho "berry" e valor igual a 1.

.. code-block:: ruby

  $data = { "orange" => 0, "blueberry" => 1, "raspberry" => 2 }
  $filtered_data = $data.filter |$keys, $values| { $keys =~ /berry$/ and $values <= 1 }
  notice( "Resultado: $filtered_data" )

3) Escreva outro manifest, no qual dado um hash retorne a soma de todos os valores e todas as strings concatenadas.

.. code-block:: ruby

  $data = {a => 1, b => 2, c => 3}
  $combine = $data.reduce |$memo, $value| {
    $string = "${memo[0]}${value[0]}"
    $number = $memo[1] + $value[1]
    [$string, $number]
  }
  notice( "Resultado: $combine" )

4) Escreva outro manifest, no qual dado um array de números retorne-os organizados em pares.

.. code-block:: ruby

  $result = slice([1,2,3,4,5,6], 2) 
  notice( "Resultado: $result" )

5) Escreva outro manifest, no qual dado uma array de caracteres retorne-os organizados em pares.

.. code-block:: ruby

  $result = slice('puppet',2) 
  notice( "Resultado: $result" )
