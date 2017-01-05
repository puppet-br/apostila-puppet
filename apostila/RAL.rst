Resource Abstraction Layer (RAL)
================================

O que existe em um sistema operacional? Arquivos, pacotes, processos e serviços em execução, programas, contas de usuários, grupos, etc. Para o Puppet, isso são *resources* (recursos).

Os resources têm certas similaridades entre si. Por exemplo, um arquivo tem um caminho e um dono, todo usuário possui um grupo e um número identificador.
Essas características chamamos de *atributos*, e unindo os atributos que sempre estão presentes possibilita a criação de *resource types* (tipos de recursos).

Os atributos mais importantes de um *resource type* geralmente são conceitualmente idênticos em todos os sistemas operacionais, independentemente de como as implementações venham a diferir. A descrição de um resource pode ser separada de como ela é implementada.

Essa combinação de *resources*, *resource types* e atributos formam o *Resource Abstraction Layer* (RAL) do Puppet. O RAL divide resources em tipos (alto nível) e *providers* (provedores, implementações específicas de cada plataforma), e isso nos permite manipular resources (pacotes, usuários, arquivos, etc) de maneira independente de sistema operacional.

.. dica::

  |dica| **Ordens ao invés de passos**

  Através do RAL dizemos somente o que queremos e não precisamos nos preocupar no **como** será feito. Portanto, temos que pensar em ordens como "o pacote X deve estar instalado", ou ainda, "o serviço Z deve estar parado e desativado".


Manipulando resources via RAL
-----------------------------
O comando ``puppet resource`` permite consultar e manipular o sistema operacional via RAL, visualizando a configuração na linguagem do Puppet.

Vamos manipular um pouco o RAL antes de escrevermos código.

Gerenciando usuários
````````````````````
O primeiro argumento que deve ser passado é o *resource type* que será consultado.

::

  # puppet resource user
  user { 'avahi':
    ensure           => 'present',
    comment          => 'Avahi mDNS daemon,,,',
    gid              => '108',
    home             => '/var/run/avahi-daemon',
    shell            => '/bin/false',
    uid              => '105',
  }
  user { 'backup':
    ensure           => 'present',
    comment          => 'backup',
    gid              => '34',
    home             => '/var/backups',
    shell            => '/bin/sh',
    uid              => '34',
  }
  ...

A saída mostra todos os usuários, com atributos como UID, GID e shell já formatados na linguagem do Puppet que estejam presentes no sistema operacional.

Nós podemos ser mais específicos e consultar apenas um *resource*:

::

  # puppet resource user root
  user { 'root':
    ensure           => 'present',
    comment          => 'root',
    gid              => '0',
    home             => '/root',
    shell            => '/bin/bash',
    uid              => '0',
  }

Esse código gerado pode ser utilizado depois, e é funcional.

É possível passarmos alguns atributos para o ``puppet resource``, fazendo com que ele altere o estado de um recurso no sistema.

Tradicionalmente, para criarmos um usuário usamos comandos como ``useradd`` ou o interativo ``adduser``. Ao invés de usar um desses comandos, vamos usar o Puppet:

::

  # puppet resource user joe ensure=present home="/home/joe" managehome=true
  Notice: /User[joe]/ensure: created
  user { 'joe':
    ensure => 'present',
    home   => '/home/joe',
  }

Verifique se o usuario jor foi criado.

::

  # id joe
  uid=500(joe) gid=500(joe) groups=500(joe)

Repare que a linha de comando não necessariamente lê código Puppet. Podemos usar somente argumentos.

.. raw:: pdf

 PageBreak

Gerenciando serviços
````````````````````
Vamos continuar explorando mais *resources*. Outro *resource type* muito útil é o ``service``.

::

  # puppet resource service
  service { 'acpid':
    ensure => 'running',
    enable => 'true',
  }
  service { 'auditd':
    ensure => 'running',
    enable => 'true',
  }
  service { 'crond':
    ensure => 'running',
    enable => 'true',
  }
  ...

O comando acima listou todos os serviços da máquina e seus estados. Podemos manipular os serviços via Puppet, ao invés de utilizarmos os tradicionais comandos ``update-rc.d`` no Debian/Ubuntu ou ``chkconfig`` no CentOS/Red Hat. Além disso, também podemos parar e iniciar serviços.

Parando um serviço que está em execução:

::

  # puppet resource service iptables ensure=stopped
  Notice: /Service[iptables]/ensure: ensure changed 'running' to 'stopped'
  service { 'iptables':
    ensure => 'stopped',
  }
  
  # service iptables status
  iptables is stopped

Inciando um serviço que estava parado:

::

  # service saslauthd status
  saslauthd is stopped
  
  # puppet resource service saslauthd ensure=running
  Notice: /Service[saslauthd]/ensure: ensure changed 'stopped' to 'running'
  service { 'saslauthd':
    ensure => 'running',
  }
  
  # service saslauthd status
  iptables (pid  2731) is running...

Gerenciando pacotes
```````````````````

Além de usuários e serviços, podemos também manipular a instalação de software via RAL do Puppet.

Com um mesmo comando, podemos fazer a instalação, por exemplo, do ``aide``, tanto no Debian quanto no CentOS. Vamos executar ``puppet resource package aide ensure=installed`` em ambos os sistemas.

* No CentOS:

::

  # rpm -qi aide
  package aide is not installed
  
  # puppet resource package aide ensure=installed
  Notice: /Package[aide]/ensure: created
  package { 'aide':
    ensure => '0.14-3.el6_2.2',
  }
  
  # rpm -qi aide

* No Debian:

::

  # dpkg -s aide
  Package `aide' is not installed and no info is available.
  Use dpkg --info (= dpkg-deb --info) to examine archive files,
  and dpkg --contents (= dpkg-deb --contents) to list their contents.
  
  # puppet resource package aide ensure=installed
  Notice: /Package[aide]/ensure: created
  package { 'aide':
    ensure => '0.16~a2.git20130520-3',
  }
    
  # dpkg -s aide

Principais Resource Types
`````````````````````````
O Puppet possui uma série de *resource types* prontos para uso, também chamados de *core resource types*, pois todos são distribuídos por padrão com o Puppet e estão disponíveis em qualquer instalação. Mais *resource types* podem ser adicionados usando módulos.

Os principais são:

* file
* package
* service
* user
* group
* cron
* exec

Podemos dizer também que esses tipos nos fornecem primitivas, com as quais podemos criar soluções de configuração completas e robustas.

Atributos de Resource Types
```````````````````````````

Até agora vimos atributos básicos dos tipos ``user``, ``service`` e ``package``. Porém, esses recursos possuem muito mais atributos do que vimos até agora.

Para sabermos os atributos de um tipo, o próprio comando ``puppet`` nos fornece documentação completa.

::

  # puppet describe -s user
  
  user
  ====
  Manage users.  This type is mostly built to manage system
  users, so it is lacking some features useful for managing normal
  users.
  
  This resource type uses the prescribed native tools for creating
  groups and generally uses POSIX APIs for retrieving information
  about them.  It does not directly modify `/etc/passwd` or anything.
  
  **Autorequires:** If Puppet is managing the user's primary group (as
  provided in the `gid` attribute), the user resource will autorequire
  that group. If Puppet is managing any role accounts corresponding to the
  user's roles, the user resource will autorequire those role accounts.
  
  
  Parameters
  ----------
      allowdupe, attribute_membership, attributes, auth_membership, auths,
      comment, ensure, expiry, forcelocal, gid, groups, home, ia_load_module,
      iterations, key_membership, keys, loginclass, managehome, membership,
      name, password, password_max_age, password_min_age, profile_membership,
      profiles, project, purge_ssh_keys, role_membership, roles, salt, shell,
      system, uid
  
  Providers
  ---------
      aix, directoryservice, hpuxuseradd, ldap, openbsd, pw, user_role_add,
      useradd, windows_adsi

Pronto, agora temos uma lista de parâmetros sobre o tipo ``user``.

.. dica::

  |dica| **Documentação completa**

  O argumento ``-s`` mostra uma versão resumida da documentação. Use o comando ``puppet describe`` sem o ``-s`` para ter acesso à documentação completa do resource type.

Prática: Modificando recursos interativamente
---------------------------------------------

Além de podermos manipular recursos em nosso sistema pelo comando puppet resource, ele fornece um parâmetro interessante: ``--edit``. Com ele, podemos ter um contato direto com a linguagem do Puppet para manipular recursos, ao invés de usarmos apenas a linha de comando.

Vamos adicionar o usuário **joe** aos grupos **adm** e **bin**. Normalmente faríamos isso usando o comando ``usermod`` ou editando manualmente o arquivo ``/etc/group``. Vamos fazer isso no estilo Puppet!

1. Execute o seguinte comando:

::

  # puppet resource user joe --edit

2. O Puppet abrirá o *vim* com o seguinte código:

::

  user { 'joe':
    ensure           => 'present',
    gid              => '1004',
    home             => '/home/joe',
    password         => '!',
    password_max_age => '99999',
    password_min_age => '0',
    shell            => '/bin/bash',
    uid              => '1004',
  }


3. Vamos acrescentar o seguinte código:

::

  user { 'joe':
    ensure           => 'present',
    gid              => '1004',
    groups           => ['bin', 'adm'],  #<-- essa linha é nova!
    home             => '/home/joe',
    password         => '!',
    password_max_age => '99999',
    password_min_age => '0',
    shell            => '/bin/bash',
    uid              => '1004',
  }

4. Basta sair do ``vim``, salvando o arquivo, para que o Puppet aplique a nova configuração. Teremos uma saída parecida com essa:

::

  Info: Applying configuration version '1447253347'
  Notice: /Stage[main]/Main/User[joe]/groups: groups changed '' to 
  ['adm', 'bin']
  Notice: Applied catalog in 0.07 seconds

.. raw:: pdf

 PageBreak

5. Remova o usuário ``joe`` com o comando a seguir.

::

  # puppet resource user joe ensure=absent
 
6. Remova o diretório ``/home/joe`` com o comando a seguir.

::

  # puppet resource file /home/joe ensure=absent force=true
  
7. Instale a última versão do ``nmap``.

::
  
  # puppet resource package nmap ensure=latest     
  
8. Crie o grupo de usuário ``teste``.

::
  
  # puppet resource group teste ensure=present
  
9. Verifique o status do serviço ``ssh``.

::

  # puppet resource service ssh  
  
10. Crie o arquivo ``/tmp/teste`` com o conteúdo "isso é um teste".

::
  
  # puppet resource file /tmp/teste.txt ensure=file content='isso eh um teste'
  
11. Execute um comando de ``ping`` para o Google.com e direcione a saída do comando para um arquivo ``/tmp/ping.txt``.

::

  # puppet resource exec 'ping -c3 google.com > /tmp/ping.txt' \
    path='/bin:/usr/bin'  
