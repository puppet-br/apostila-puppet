Templates
=========

Muitas vezes temos um mesmo serviço ativado em diversas máquinas, mas em um conjunto de máquinas esse serviço precisa ser configurado de uma maneira e, no restante das máquinas, de outra. Assim, cada conjunto de máquinas precisaria de um arquivo de configuração específico, mesmo que esse arquivo tivesse uma ou duas linhas de diferença.

Então, quando fosse necessário atualizar uma opção de configuração que é comum aos dois conjuntos de máquinas, seria necessário atualizar dois arquivos de configuração. Além do cuidado extra de garantir que ambos estivessem corretos.

O Puppet tem um recurso de templates, em que podemos usar somente um arquivo de dentro dele. Colocamos uma lógica e valores de variáveis que venham do seu código, tornando a nossa configuração mais robusta.

Vamos usar como exemplo um módulo chamado ``foo``:

::

  # cd /etc/puppetlabs/code/environments/production/modules/
  # mkdir -p foo/manifests
  # mkdir -p foo/templates

Adicione o conteúdo abaixo ao arquivo ``/etc/puppetlabs/code/environments/production/modules/foo/manifests/init.pp``:

.. code-block:: ruby

  # vim /etc/puppetlabs/code/environments/production/modules/foo/manifests/init.pp
  class foo {
    $var1 = '123456'
    $var2 = 'bar'
    file {'/tmp/foo.conf':
      ensure => 'file',
      content => template('foo/foo.conf.erb')
    }
  }


Até aqui nós usávamos o atributo *content* com uma string contendo o que queríamos dentro do arquivo, mas agora estamos usando a função ``template()``, que processa o arquivo ``foo.conf.erb``.

Adicione o conteúdo abaixo ao arquivo ``/etc/puppetlabs/code/environments/production/modules/foo/templates/foo.conf.erb``:

::

  # vim /etc/puppetlabs/code/environments/production/modules/foo/templates/foo.conf.erb
  var1=<%= @var1 %>
  var2=<%= @var2 %>
  
  <% if @osfamily == 'RedHat' %>
  var3=RedHat
  <% else %>
  var3=Outro
  <% end %>

Repare que as variáveis do manifest estão disponíveis dentro da template, inclusive as variáveis do facter.

.. nota::

  |nota| **Localização de uma template no sistema de arquivos**
  
  Note que o caminho que deve ser passado para a função ``template()`` deve conter o nome do módulo, seguido do nome do arquivo de template que usaremos.
  Portanto, ``template('foo/foo.conf.erb')`` significa abrir o arquivo ``/etc/puppetlabs/code/environments/production/modules/foo/templates/foo.conf.erb``.


Usando o módulo ``foo`` em uma máquina CentOS/Red Hat:

::

  # puppet apply -e 'include foo'
  /Stage[main]/Foo/File[/tmp/foo.conf]/ensure: defined content as \
            '{md5}8612fd8d198746b72f6ac0b46d631a2c'
  Finished catalog run in 0.05 seconds
  
  # cat /tmp/foo.conf 
  var1=123456
  var2=bar
  
  var3=RedHat


.. dica::

  |dica| **Concatenando templates**
  
  A função ``template()`` pode concatenar várias templates de uma vez só, possibilitando configurações sofisticadas.
  
  ``template("foo/foo.conf-1.erb", "foo/foo.conf-2.erb")``


Sintaxe ERB
-----------

Um arquivo de template no Puppet usa a sintaxe ERB, que é a linguagem padrão de templates do Ruby. Ela é simples e poderosa.

* Comentário:

::

  <%# isso será ignorado %>

* Extrai o valor de uma variável:

::

  <%= @qualquer_variavel %>

.. raw:: pdf

 PageBreak

* Condições:

::

  <% if @var1 != "foo" %>
  <%= @var1 %> is not foo!
  <% end %>

* Verificar se uma variável existe:

::

  <% if @boardmanufacturer then %>
    Essa maquina é do fabricante type: <%= @boardmanufacturer %>
  <% end %>

* Iteração em um array chamado **frutas**:

::

  <% @frutas.each do |val| %>
  Nome: <%= val %> 
  <% end %>


* Iteração em um array com varias chaves:

Exemplo de como o array é formado:

::

  $rotas = [
        {id => '100', name => 'link1',},
        {id => '200', name => 'link2',},
         ]

Indexando o conteúdo do array num template:

::

  <% rotas.each do |rota| -%>
  <%= rota['id'] %> <%= rota['name'] %>
  <% end -%>

Resultado:

::

  100 link1
  200 link2

.. dica::

  |dica| **Evitando linhas em branco**
  
  Repare que no exemplo do arquivo ``/tmp/foo.conf`` as linhas em que estavam as tags com o ``if`` e ``end`` acabaram saindo em branco no arquivo final.
  
  Caso isso seja um problema, existem dois jeitos de resolvermos.
  
  1. Colocar todo o código em apenas uma linha, assim o arquivo final não conterá linhas em branco:
  
  ``<% if @osfamily == 'RedHat' %>var3=RedHat<% else %>var3=Outro<% end %>``, 

  2. A outra opção é colocar um hífen no final de cada tag, assim o ERB não retornará uma linha em branco:
  
  ``<% if @osfamily == 'RedHat' -%>``
  ``var3=RedHat``
  ``<% else -%>``
  ``var3=Outro``
  ``<% end -%>``


.. dica::

  |dica| **Mais informações sobre a sintaxe ERB**

  Para saber mais detalhes sobre a sintaxe ERB, acesse a página abaixo.
  
  https://docs.puppet.com/puppet/latest/lang_template_erb.html
  
  Para saber mais detalhes sobre o uso de linguagens para manipulação de templates no Puppet, acesse a página abaixo.
  
  https://docs.puppet.com/puppet/latest/lang_template.html
  
  
Prática: usando templates
-------------------------

1. Crie a estrutura básica de um módulo chamado ``motd``:

::

  # cd /etc/puppetlabs/code/environments/production/modules/
  # mkdir -p motd/{manifests,templates}

2. Defina a classe motd em ``motd/manifests/init.pp``, conforme o código abaixo:

.. code-block:: ruby

  class motd {
    $admins = ['Joao j@foo.com', 'Edu e@foo.com', 'Bia b@foo.com']
    file {'/etc/motd':
      ensure  => 'file',
      mode    => '0644',
      content => template("motd/motd.erb"),
    }
  }

3. Crie a template em ``motd/templates/motd.erb`` com o conteúdo abaixo:

::

  Bem vindo a <%= @fqdn -%> - <%= @operatingsystem -%> <%= @operatingsystemrelease %>

  Kernel: <%= @kernel -%> <%= @kernelversion %>

  Em caso de problemas, falar com:
  <% @admins.each do |adm| -%>
  <%= adm %>
  <% end -%>

4. Use o módulo no **node1**, execute o agente e confira o resultado no arquivo ``/etc/motd``.

