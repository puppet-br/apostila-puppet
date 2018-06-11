Environments
============

O Puppet permite você dividir os seus sistemas em diferentes conjuntos de hosts, \
chamados *environments*.

Cada environment pode servir um conjunto diferente de módulos. Isso é usado \
geralmente para gerenciar versões de módulos, usando-os em sistemas destinados a \
testes.

O uso de environments introduz uma série de outras possibilidades, como separar \
um ambiente em DMZ, dividir tarefas entre administradores de sistemas ou dividir \
o seu parque por tipo de hardware.

O environment de um node é especificado no arquivo ``puppet.conf``. Sempre que \
um node faz um pedido de configuração ao Puppet Master, o environment do node é \
utilizado para determinar a qual configuração e quais módulos serão fornecidos.

Por padrão, o agente envia ao Puppet Master um environment chamado *production*.

Prática: configurando environments
----------------------------------

Os comandos abaixo são executados no **master.domain.com.br** e no **node1.domain.com.br**

1. No Puppet Master faça uma cópia do ambiente **production** para **desenv**:

::

  cd /etc/puppetlabs/code/environments/
  cp -a production desenv

2. No arquivo ``/etc/puppetlabs/puppet/puppet.conf`` do ``node1.domain.com.br`` \
acrescente o environment:

::

  [main]
  environment = desenv

.. dica::

  |dica| **Enviroment em linha de comando**

  Opcionalmente, podemos chamar o agente passando o environment pela linha de \
  comando: ``puppet agent -t --environment desenv``.


3. No Puppet Master, vamos modificar a template do módulo ``motd`` no environment \
**desenv**, apenas acrescentando uma linha ao final:

::

  cd /etc/puppetlabs/code/environments/desenv/modules/motd/templates
  echo "Puppet versão <%= @puppetversion -%>" >> motd.erb


4. Execute o agente Puppet no ``node1.domain.com.br`` (certifique-se de que o \
``node1.domain.com.br`` está declarado no arquivo ``/etc/puppetlabs/code/environments/desenv/manifests/site.pp`` \
e possui a classe **motd** declarada):

::

  puppet agent -t


5. Agora temos dois módulos ``motd``, um para cada environment. Uma vez que o \
módulo no environment **desenv** esteja aprovado, ele pode ser copiado para o \
environment **production** com o comando a seguir.

::

  rsync -a /etc/puppetlabs/code/environments/desenv/modules/motd/ \
   /etc/puppetlabs/code/environments/production/modules/motd/


6. Nos nodes que são do environment **production**, a nova versão do módulo \
**motd** será utilizada a partir de agora.
