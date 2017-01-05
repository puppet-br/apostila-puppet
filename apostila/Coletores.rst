Coletores de Recursos
======================

Coletores de recursos selecionam um grupo de recursos, pesquisando os atributos de cada recurso no catálogo. Esta pesquisa é independente da ordem de avaliação (ou seja, inclui recursos que ainda não foram declarados no momento em que o coletor é escrito). Os coletores percebem recursos virtuais, podendo ser usados em declarações de encadeamento, e podem substituir atributos de recursos.

Os coletores têm uma sintaxe irregular que permite que eles funcionem como uma declaração e um valor.

Sintaxe
--------

.. code-block:: ruby

  #Coleta um único recurso de usuário que possua o título 'luke'
  User <| title == 'luke' |> 

  #Coleta qualquer recurso de usuario da lista que inclui o grupo 'admin'
  User <| groups == 'admin' |> 

  #Cria um relacionamento com os recursos ``package``
  Yumrepo['custom_packages'] -> Package <| tag == 'custom' |> 

A forma geral de um coletor de recursos é:

* O tipo de recurso, começando com a letra maiúscula. Não pode ser uma classe e não há maneira de coletar classes. 
* <\| - Um sinal de "menor que" ( ``<`` ) e um caractere de pipe ( ``|`` ) .
*  Opcionalmente, uma expressão de pesquisa.
* \|> - Um caractere de pipe e um sinal de "maior que" ( ``>`` ). 

Observe que os coletores de recursos exportados têm uma sintaxe ligeiramente diferente. Veremos isso mais adiante.

Expressões de pesquisa
----------------------

Os coletores podem pesquisar os valores dos títulos e atributos de recursos usando uma sintaxe de expressão especial. Um coletor com uma expressão de pesquisa vazio irá corresponder a todos os recursos do tipo de recurso especificado.

Parênteses podem ser usados para melhorar a legibilidade e para modificar a prioridade, bem como agrupamento de and / or . Você pode criar expressões arbitrariamente complexas usando os quatro operadores a seguir:

* ==  #igual
* !=  #diferente
* and #e 
* or  #ou

Os coletores de recursos podem ser usados como declarações independentes, como o operando de uma declaração de encadeamento ou em um bloco de atributo coletor para alteração de atributos de recursos.

Os colectores não podem ser usados nos seguintes contextos:

* como o valor de um atributo de recurso;
* como o argumento de uma função;
* dentro de um array ou hash;
* como o operando de uma expressão diferente de uma declaração de encadeamento. 

Os coletores de recursos exportados são idênticos aos coletores, exceto por possuírem os sinais ( ``<`` ) e ( ``>`` ) duplicados. Exemplo:

.. code-block:: ruby

  #coleta todos os recursos exportados do tipo ``nagios_service``
  Nagios_service <<| |>>

Coletores de recursos exportados existem apenas para importar recursos que foram publicados por outros nós. Para usá-los, você precisa ter o armazenamento de catálogo e pesquisa (``storeconfigs``) habilitado. Veja o capítulo de `Recursos exportados`_ para mais detalhes. Para habilitar os recursos exportados, siga as instruções de instalação e configuração no capítulo `PuppetDB e Dashboards Web`_.

.. nota::

  |nota| **Mais informações sobre os coletores**
  
   Para obter mais informações sobre os coletores de recursos acesse a página abaixo.

   https://docs.puppet.com/puppet/latest/lang_collectors.html

