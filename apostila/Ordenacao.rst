Ordenação
=========

Agora que entendemos os manifests e a declaração de recursos, vamos aprender sobre meta-parâmetros e ordenação de recursos.

Voltemos ao *manifest* ``/root/manifests/arquivo-2.pp``, que criou um arquivo, um diretório e um link simbólico:

.. code-block:: ruby

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

Embora as declarações estejam escritas uma após a outra, o Puppet pode aplicá-las em qualquer ordem.

Ao contrário de uma linguagem procedural, a ordem da escrita de recursos em um manifest não implica na mesma ordem lógica para a aplicação.

Alguns recursos dependem de outros recursos. Então, como dizer ao Puppet qual deve vir primeiro?

Meta-parâmetros e referência a recursos
---------------------------------------

.. code-block:: ruby

  file { '/tmp/teste1.txt':
    ensure  => present,
    content => "Ola!\n",
  }
  
  notify { '/tmp/teste1.txt foi sincronizado.':
    require => File['/tmp/teste1.txt'],
  }


Cada *resource type* tem o seu próprio conjunto de atributos, mas existe outro conjunto de atributos, chamado meta-parâmetros, que pode ser utilizado em qualquer *resource*.

Meta-parâmetros não influenciam no estado final de um *resource*, apenas descrevem como o Puppet deve agir.

Nós temos quatro meta-parâmetros que nos permitem impor ordem aos *resources*: ``before``, ``require``, ``notify`` e ``subscribe``. Todos eles aceitam um *resource reference* (referência a um recurso), ficando assim: ``Tipo['titulo']``.


.. nota::

  |nota| **Maiúsculo ou minúsculo?**
  
  Lembre-se: usamos caixa baixa quando estamos declarando novos resources. Quando queremos referenciar um resource que já existe, usamos letra maiúscula na primeira letra do seu tipo, seguido do título do resource entre colchetes.
  
  ``file{'arquivo': }`` é uma declaração de recurso e ``File['arquivo']`` é uma referência ao *resource* declarado.


Meta-parâmetros before e require
````````````````````````````````

``before`` e ``require`` criam um simples relacionamento entre resources, onde um resource deve ser sincronizado antes que outro.

``before`` é utilizado no *resource* anterior, listando quais *resources* dependem dele.

``require`` é usado no resource posterior, listando de quais resources ele depende.

Esses dois meta-parâmetros são apenas duas maneiras diferentes de escrever a mesma relação, dependendo apenas da sua preferência por um ou outro.

.. code-block:: ruby

  file { '/tmp/teste1.txt':
    ensure  => present,
    content => "Ola!\n",
    before  => Notify['mensagem'],
  }

  notify {'mensagem':
    message => 'O arquivo teste1.txt foi criado!',
  }

No exemplo acima, após ``/tmp/teste1.txt`` ser criado acontece a notificação. O mesmo comportamento pode ser obtido usando o meta-parâmetro ``require``:

.. code-block:: ruby

  file { '/tmp/teste1.txt':
    ensure  => present,
    content => "Ola!\n",
  }

  notify {'mensagem':
    require => File['/tmp/teste1.txt'],
    message => 'O arquivo teste1.txt foi criado!',
  }

Meta-parâmetros notify e subscribe
``````````````````````````````````
Alguns tipos de resources podem ser *refreshed* (refrescados, recarregados), ou seja, devem reagir quando houver mudanças.

Para um resource ``service``, significa reiniciar ou recarregar após um arquivo de configuração modificado.

Para um resource ``exec``, significa ser executado toda vez que o resource for modificado.


.. aviso::

  |aviso| **Quando acontece um refresh?**
  
  *Refreshes* acontecem somente durante a aplicação da configuração pelo Puppet e nunca fora dele.

  O agente do Puppet não monitora alterações nos arquivos.

Os meta-parâmetros *notify* e *subscribe* estabelecem relações de dependência da mesma maneira que *before* e *require*, mas para relações de refresh.

Não só o *resource* anterior será sincronizado, como após a sincronização será gerado um evento ``refresh`` e o *resource* deverá reagir de acordo.

.. nota::

  |nota| **Resources que suportam refresh**
  
  Somente os tipos built-in ``exec``, ``service`` e ``mount`` podem ser *refreshed*.

No exemplo abaixo, toda vez que o arquivo ``/etc/ssh/sshd_config`` divergir de ``/root/manifests/sshd_config``, ele será sincronizado. Caso isso ocorra, ``Service['sshd']`` receberá um refresh e fará com que o serviço ``sshd`` seja recarregado.

.. code-block:: ruby

  file { '/etc/ssh/sshd_config':
    ensure => file,
    mode   => '0600',
    source => '/root/manifests/sshd_config',
    notify => Service['sshd'],
  }

  service { 'sshd':
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
  }


Encadeando relacionamentos
``````````````````````````
Existe um outro jeito de declarar relacionamentos entre os resources: usando setas de ordenação ``->`` e notificação ``~>``. O Puppet chama isso de *channing*.

Essas setas podem apontar para qualquer direção (``<-`` funciona também) e você deve pensar nelas como o fluxo do tempo. O resource de onde parte a seta é sincronizado antes que o recurso para qual a seta aponta.

O exemplo abaixo demonstra o mesmo efeito de ordenação, mas de maneira diferente. Para exemplos pequenos as vantagens de se usar setas podem não ser óbvias, mas com muitos *resources* envolvidos elas podem ser bem mais práticas.

.. code-block:: ruby

  file {'/tmp/teste1.txt':
    ensure  => present,
    content => "Hi.",
  }

  notify {'depois':
    message => '/tmp/teste1.txt foi sincronizado.',
  }

  File['/tmp/teste1.txt'] -> Notify['depois']

.. aviso::

  |aviso| **Meta-parâmetros**
  
  Mais informações sobre outros meta-parâmetros podem ser encontradas em: https://docs.puppet.com/puppet/latest/metaparameter.html


Prática: validando o arquivo ``/etc/sudoers``
---------------------------------------------

Para essa atividade, salve o conteúdo de cada exercício em um arquivo ``.pp`` e aplique-o usando o comando ``puppet apply``.

1. Certifique-se de que o pacote ``sudo`` está instalado. Crie um manifest com o código abaixo e execute-o.

.. code-block:: ruby

  package { 'sudo':
    ensure => 'installed'
  }

2. Agora vamos declarar o controle do arquivo ``/etc/sudoers`` e usar como origem ``/root/manifests/sudoers``. O arquivo depende do pacote ``sudo``, pois sem ele o arquivo não deve existir.

.. raw:: pdf
 
 PageBreak

.. code-block:: ruby

  package { 'sudo':
    ensure => 'installed'
  }
  
  file { '/etc/sudoers':
    ensure  => 'file',
    mode    => '0440',
    owner   => 'root',
    group   => 'root',
    source  => '/root/manifests/sudoers',
    require => Package['sudo']
  }

3. Temos uma limitação, pois, caso exista algum erro no arquivo de origem, o arquivo, sempre será copiado para ``/etc/sudoers``. Façamos uma verificação antes de o arquivo ser copiado.

 * Copie o arquivo ``/etc/sudoers`` para ``/root/manifests/sudoers``. Edite o arquivo ``/root/manifests/sudoers`` de forma a deixá-lo inválido antes de aplicar o *manifest* abaixo.

.. code-block:: ruby

  package { 'sudo':
    ensure => 'installed'
  }
  
  file { '/etc/sudoers':
    ensure  => 'file',
    mode    => '0440',
    owner   => 'root',
    group   => 'root',
    source  => '/root/manifests/sudoers',
    require => [Package['sudo'], Exec['parse_sudoers']],
  }
  
  exec { 'parse_sudoers':
    command => '/usr/sbin/visudo -c -f /root/manifests/sudoers',
    require => Package['sudo'],
  }


4. Ainda temos uma limitação. Toda vez que o *manifest* é aplicado, o resource ``Exec['parse_sudoers']`` é executado. Precisamos de uma condição para que ele só seja executado se necessário.

.. raw:: pdf
 
 PageBreak

.. code-block:: ruby

  package {'sudo':
    ensure => 'installed'
  }
  
  file {'/etc/sudoers':
    ensure  => 'file',
    mode    => 0440,
    owner   => 'root',
    group   => 'root',
    source  => '/root/manifests/sudoers',
    require => [Package['sudo'], Exec['parse_sudoers']],
  }
  
  exec {'parse_sudoers':
    command => '/usr/sbin/visudo -c -f /root/manifests/sudoers',
    unless  => '/usr/bin/diff /root/manifests/sudoers /etc/sudoers',
    require => Package['sudo'],
  } 
  
Ao executar esse manifest, o arquivo ``/etc/sudoers`` não será atualizado porque há um problema de validação de conteúdo do arquivo de origem ``/root/manifests/sudoers``. 

.. nota::

  |nota| **Atributos onlyif e unless do resource exec**
  
  Quando o recurso ``exec`` possuir o atributo ``onlyif`` ou ``unless`` declarado, só será executado se o(s) comando(s) informado(s) nestes atributos for(em) executado(s) sem erros. Ou seja, se retornarem o código 0. Veja mais informações em: http://www.puppetcookbook.com/posts/exec-onlyif.html e https://docs.puppet.com/puppet/latest/reference/types/exec.html
