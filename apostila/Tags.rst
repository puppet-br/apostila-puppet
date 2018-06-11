Tags
=====

Os recursos, as classes e instâncias de tipos definidos podem ter várias tags \
associadas, mas eles recebem algumas tags automaticamente. As tags são úteis para:

* coletar recursos;
* filtrar e analisar relatórios;
* restringir a execução de parte do catálogo.

Nomes de tag
-------------

As tags devem começar com uma letra minúscula, número ou sublinhado, e podem incluir:

* letras minúsculas;
* numeros;
* sublinhados ( _ );
* dois pontos ( : );
* ponto ( . );
* Hifens ( - );

Os nomes das tags devem corresponder à seguinte expressão regular:

::

  \A[a-z0-9_][a-z0-9_:\.\-]*\Z

Atribuição de tags a recursos
-----------------------------

Um recurso pode ter várias tags. Há três maneiras de atribuir uma tag a um recurso. \
Vamos conhecer os detalhes de cada uma delas.

Tag automática
```````````````

Cada recurso recebe automaticamente as seguintes tags:

* seu tipo de recurso;
* o nome completo da classe e/ou tipo definido em que o recurso foi declarado;
* cada ``namespace segment`` (https://docs.puppet.com/puppet/latest/lang_namespaces.html) \
  da classe do recurso e/ou tipo definido.

Por exemplo, um recurso ``file`` na classe ``apache::ssl`` recebe as tags: \
``file``, ``apache::ssl``, ``apache`` e ``ssl``.

As tags de classe são geralmente as mais úteis, especialmente quando você \
configura o módulo `Puppet Tagmail`_ ou está testando manifests refatorados.

O meta-parâmetro ``tag``
`````````````````````````

Você pode usar o meta-parâmetro ``tag`` em uma declaração de recurso para \
adicionar várias tags:

.. code-block:: ruby

  apache::vhost {'docs.puppetlabs.com':
    port => 80,
    tag  => ['us_mirror1', 'us_mirror2'],
  }


O meta-parâmetro ``tag`` pode aceitar uma única tag ou um array de tags. \
Estas tags serão adicionados às tags associadas automaticamente. Além disso, \
esse meta-parâmetro pode ser utilizado com recursos normais, recursos definidos \
e classes.

O exemplo acima atribui as tags ``us_mirror1`` e ``us_mirror2`` para cada recurso \
contido na classe ``Apache::Vhost['docs.puppetlabs.com']``.

A função ``tag``
``````````````````

Você pode usar a função ``tag`` dentro de uma definição de classe ou tipo \
definido para atribuir tags para o recipiente envolvente e todos os recursos que \
ele contém. Exemplo:

.. code-block:: ruby

  class role::public_web {
    tag 'us_mirror1', 'us_mirror2'

    apache::vhost {'docs.puppetlabs.com':
      port => 80,
    }
    ssh::allowgroup {'www-data': }
    @@nagios::website {'docs.puppetlabs.com': }
  }

No exemplo acima, as tags ``us_mirror1`` e ``us_mirror2`` são atribuídas a todos \
os recursos definidos na classe ``role::public_web``, bem como a ela mesma.

Usando as tags
---------------

As tags podem ser usadas como um atributo na expressão de busca de um colector \
de recursos. Isto é útil principalmente para realizar `Recursos Virtuais`_ e \
exportados (https://docs.puppet.com/puppet/latest/lang_exported.html).

Você também pode fazer com que o agente do Puppet aplique o estado desejado em um \
host usando no catálogo apenas a configuração associada a determinadas tags. \
Isso é útil ao refatorar módulos e permite que você aplique somente uma única \
classe em um nó de teste.

As tags de configuração podem ser definidas no arquivo ``puppet.conf`` (para \
restringir permanentemente o catálogo) ou na linha de comando (para restringir \
temporariamente):

::

  puppet agent --test --tags apache,us_mirror1

As tags configuração devem ser separadas por vírgulas (sem espaços entre as tags).

O módulo `Puppet Tagmail`_ pode enviar e-mails para uma lista de pessoas sempre \
que recursos com determinadas tags forem alteradas.

As tags de recurso também estão disponíveis para serem usadas em manipuladores \
de relatórios personalizados. Veja mais detalhes nos links abaixo.

https://docs.puppet.com/puppet/latest/lang_tags.html
https://docs.puppet.com/puppet/latest/reporting_about.html
https://docs.puppet.com/puppet/latest/format_report.html
