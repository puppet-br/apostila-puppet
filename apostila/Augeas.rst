Augeas
======

Muitas vezes precisamos manipular arquivos de configuração e, geralmente, \
recorremos a soluções simples usando grep, sed, awk ou alguma linguagem de script.

Com isso, tem-se muito trabalho para manipular esses arquivos e o resultado final \
nunca é flexível ou muito confiável.

O Augeas é uma ferramenta para edição segura de arquivos de configuração, que analisa \
arquivos de configuração em seus formatos nativos e os transforma em uma árvore. \
As alterações são feitas manipulando essa árvore e salvando-a de volta ao formato \
nativo do arquivo de configuração. Usando o Augeas ficamos livres de problemas \
como tratar linhas em branco ou com comentários.

Para dar suporte a diversos formatos de arquivos de configuração, o Augeas usa o \
que ele chama de *Lenses* (lentes). Uma lense é um registro de como um arquivo de \
configuração deve ser suportado pelo Augeas, e atualmente são suportados mais de \
100 formatos diferentes.

Usando o Augeas
---------------

O comando ``augtool`` é um pequeno interpretador de comandos e, através dele, \
podemos manipular de diversas formas arquivos de configuração.

O pacote ``puppet-agent`` já traz o ``augtool`` em ``/opt/puppetlabs/puppet/bin``.

Vejamos como o arquivo ``/etc/resolv.conf`` está configurado:

::

  cat /etc/resolv.conf

  domain domain.com.br
  search domain.com.br
  nameserver 8.8.8.8
  nameserver 8.8.4.4


Como o Augeas o representa:

::

  /opt/puppetlabs/puppet/bin/augtool print /files/etc/resolv.conf

  /files/etc/resolv.conf
  /files/etc/resolv.conf/domain = "domain.com.br"
  /files/etc/resolv.conf/search
  /files/etc/resolv.conf/search/domain = "domain.com.br"
  /files/etc/resolv.conf/nameserver[1] = "8.8.8.8"
  /files/etc/resolv.conf/nameserver[2] = "8.8.4.4"


O Augeas monta uma estrutura hierárquica da configuração.

Usando um caminho completo da configuração, podemos manipular os arquivos sem \
recorrer a edição manual.

Vamos trocar o valor da opção ``domain`` do ``resolv.conf`` (a opção ``-s`` diz \
ao ``augtool`` para salvar a alteração):

.. raw:: pdf

 PageBreak

::

  sudo /opt/puppetlabs/puppet/bin/augtool -s set \
     /files/etc/resolv.conf/domain outrodominio

  Saved 1 file(s)

  cat /etc/resolv.conf

  domain outrodominio
  search domain.com.br
  nameserver 8.8.8.8
  nameserver 8.8.4.4


Em um arquivo ``resolv.conf`` a opção ``nameserver`` pode aparecer mais de uma \
vez, pois podemos configurar vários servidores de nomes em nosso sistema. \
Devido a isso, o Augeas trata a opção ``nameserver`` como um vetor, então \
*nameserver[1]* é ``8.8.8.8`` e *nameserver[2]* é ``8.8.4.4``.

Podemos incluir e remover valores no vetor. Por exemplo, adicionar um terceiro \
nameserver e depois removê-lo:

::

  sudo /opt/puppetlabs/puppet/bin/augtool -s set \
      /files/etc/resolv.conf/nameserver[3] 1.1.1.1

  Saved 1 file(s)

  cat /etc/resolv.conf

  domain outrodominio
  search domain.com.br
  nameserver 8.8.8.8
  nameserver 8.8.4.4
  nameserver 1.1.1.1

  sudo /opt/puppetlabs/puppet/bin/augtool -s rm \
     /files/etc/resolv.conf/nameserver[3]

  rm : /files/etc/resolv.conf/nameserver[3] 1
  Saved 1 file(s)

  cat /etc/resolv.conf

  domain outrodominio
  search domain.com.br
  nameserver 8.8.8.8
  nameserver 8.8.4.4


Prática: manipulando o arquivo /etc/hosts
`````````````````````````````````````````
Os comandos abaixo podem ser executados no host **node1.domain.com.br**.

1. Agora vamos utilizar o interpretador de comandos do Augeas, simplesmente \
executando o ``augtool``:

::

  sudo /opt/puppetlabs/puppet/bin/augtool
  augtool>

2. Dentro do interpretador, os comandos ``print``, ``set``, ``rm`` funcionam \
como na linha de comando. Podemos associar o caminho no sistema de arquivos \
com uma opção de configuração:

.. raw:: pdf

 PageBreak

::

  augtool> ls /files/etc/resolv.conf

  domain = outrodominio
  search/ = (none)
  nameserver[1] = 8.8.8.8
  nameserver[2] = 8.8.4.4

3. Use o comando ``print`` no arquivo ``/etc/hosts``. Identifique qual é o número do registro do host **node1.domain.com.br**.

::

  augtool> print /files/etc/hosts


4. De posse do número do registro do host **node1.domain.com.br**, crie um novo alias para o host:

::

  augtool> set /files/etc/hosts/NUMERO_DO_HOST/alias[2] node1
  augtool> save
  Saved 1 file(s)
  augtool> quit

5. Verifique se **node1** está presente no ``/etc/hosts``

Augeas e Puppet
---------------

O Puppet fornece um *resource* para que os poderosos recursos de edição do Augeas possam ser usados nos manifests.

Manipulando o ``/etc/resolv.conf``, porém agora com um manifest:

.. code-block:: ruby

  augeas {'resolv.conf':
    context => '/files/etc/resolv.conf',
    changes => ['set nameserver[1] 8.8.8.8',
                'set nameserver[2] 8.8.4.4', ],
  }


Outro exemplo, que garante a configuração correta de ``/etc/ssh/sshd_config``:

.. code-block:: ruby

  augeas { "sshd_config":
    context => "/files/etc/ssh/sshd_config",
      changes => [
      "set PermitRootLogin no",
      "set RSAAuthentication yes",
      "set PubkeyAuthentication yes",
      "set PasswordAuthentication no",
      "set Port 22221",
    ],
   }


Garante que o servidor esteja sempre no runlevel correto:

.. code-block:: ruby

  augeas { "runlevel":
    context => "/files/etc/inittab",
    changes => [
      "set id/runlevels 3",
    ],
  }
