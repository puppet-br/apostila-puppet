Laboratório 2
=============

1. Criar um módulo chamado ``ssh``, aproveitando o código do laboratório anterior. Sendo o resultado final usar o módulo dessa maneira em um node:

::

  node 'node1.domain.com.br' {
    include ssh
  }


2. Crie um módulo chamado ``masterssh``. Esse módulo deve distribuir uma chave pública ssh que fica no Puppet Master para os nodes. Assim, a partir do Puppet Master, podemos executar comandos nos nodes.

 * Dicas:

  * Gere a chave usando ``ssh-keygen -t rsa``

  * Use o resource ``ssh_authorized_key``

::

  node 'node1.domain.com.br' {
    include masterssh
  }


3. Desenvolva um módulo chamado ``puppet``.

 * Deve distribuir aos nodes o arquivo de configuração ``puppet.conf``.

 * O ``puppet.conf`` deve ser gerenciado no Puppet Master também.

 * Dicas

  * Crie uma template e nela verifique se o node é o Puppet Master para criar um arquivo com o conteúdo relevante.
  * A identificação do Puppet Master pode ser feita usando alguma variável do ``facter`` ou definida por você.

::

  node 'node1.domain.com.br' {
    include puppet
  }

