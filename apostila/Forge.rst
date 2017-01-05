Puppet Forge
============

Ao longo da história da computação, programadores desenvolveram diversas técnicas para evitar retrabalho. Estão disponíveis aos programadores bibliotecas de código que implementam diversas funcionalidades prontas para uso. Além disso, ao desenvolver um software, certamente um programador competente concentra rotinas repetidas ou parecidas em bibliotecas que podem ser reutilizadas no seu projeto.

Infelizmente, no mundo da administração de sistemas, aproveitar soluções de problemas que já foram resolvidos por outro administrador é muito raro. SysAdmins de diferentes organizações estão resolvendo os mesmos problemas todos os dias. Configurando e instalando servidores web, banco de dados, fazendo ajustes de segurança e etc.

Não seria incrível se os SysAdmins pudessem aproveitar o trabalho uns dos outros? Para isso o Puppet Forge foi criado (https://forge.puppet.com)!

Puppet Forge é um repositório de módulos escritos pela comunidade para o Puppet Open Source e Puppet Enterprise. Nele encontramos diversos módulos prontos para uso, e que com pouquíssimas linhas em um manifest podemos poupar horas e horas de trabalho aproveitando módulos úteis desenvolvidos por SysAdmins ao redor do mundo.

Prática: módulo para sysctl do Puppet Forge
-------------------------------------------

Um dos itens comumente configurados em sistemas operacionais são os parâmetros de kernel, usando o comando ``sysctl``.

Poderíamos criar um módulo para que essas configurações fossem gerenciadas via Puppet, mas felizmente alguém já deve ter resolvido esse problema.

1. Faça uma busca por **sysctl** em https://forge.puppet.com

2. Já existem vários módulos para tratar esse problema. Vamos instalar um deles (já testado anteriormente, por isso a escolha):

::

  # puppet module install trlinkin/sysctl
  Notice: Preparing to install into \
    /etc/puppetlabs/code/environments/production/modules ...
  Notice: Downloading from https://forgeapi.puppetlabs.com ...
  Notice: Installing -- do not interrupt ...
  /etc/puppetlabs/code/environments/production/modules
  |--- trlinkin-sysctl (v0.0.2)

3. Use o módulo, via linha de comando.

::

  # puppet apply -e "sysctl { 'net.ipv4.ip_forward': value => '1', enable=>true }"

.. raw:: pdf
 
 PageBreak
 
4. Declare um valor para um dos nossos nodes no Puppet Master editando o arquivo ``/etc/puppetlabs/code/environments/production/manifests/site.pp``.

.. code-block:: ruby

  node 'node1.domain.com.br' {
    sysctl { 'net.ipv4.ip_forward':
      value   => '1',
      enable  => true,
    }
  } 

5. Aplique essa regra no **node1**.

::

  # puppet agent -t
  Info: Retrieving plugin
  ...
  Info: Caching catalog for node1.puppet
  Info: Applying configuration version '1353001737'
  /Stage[main]//Node[node1.puppet]/Sysctl[net.ipv4.ip_forward]/value: \
  value changed '0' to '1'
  /Stage[main]//Node[node1.puppet]/Sysctl[net.ipv4.ip_forward]/enable: modified \
            running value of 'net.ipv4.ip_forward' from '0' to '1'
  Info: FileBucket adding {md5}228c966fd2676164a120f5230fe0b0e1
  Finished catalog run in 0.17 seconds

Prática: módulo para autofsck do Puppet Forge
---------------------------------------------

1. Instale o módulo ``jhoblitt/autofsck``.

::

  # puppet module install jhoblitt/autofsck
  Notice: Preparing to install into \
   /etc/puppetlabs/code/environments/production/modules ...
  Notice: Downloading from https://forgeapi.puppetlabs.com ...
  Notice: Installing -- do not interrupt ...
  /etc/puppetlabs/code/environments/production/modules
  |--| jhoblitt-autofsck (v1.1.0)
  |--- puppetlabs-stdlib (v4.12.0)

2. Declare o módulo ``autofsck`` na configuração de **node1**:

.. code-block:: ruby

  node 'node1.domain.com.br' {
    include autofsck
  }

3. Execute o agente em **node1**:

::

  # puppet agent -t
