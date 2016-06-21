Instalação
==========
Diversas distribuições empacotam o Puppet, mas as versões empacotadas e a qualidade desses pacotes variam muito, portanto a melhor maneira de instalá-lo é utilizando os pacotes oficiais da PuppetLabs. Os pacotes oficiais são extensivamente testatos e extremamente confiáveis.

Existem duas versões do Puppet distribuídas pela PuppetLabs: *Puppet Open Source* e o *Puppet Enterprise*. O Puppet Enterprise é distribuído gratuitamente para o gerenciamento de até 10 nodes, possui suporte oficial e vem acompanhado de uma versátil interface web para administração.

Para uma comparação mais detalhada sobre as diferenças entre a versão Open Source e a Enterprise, visite as páginas abaixo:

* https://puppet.com/product/puppet-enterprise-and-open-source-puppet
* https://puppet.com/product/faq

.. aviso::

  |aviso| **Instalação a partir do código fonte**
  
  O Puppet é um projeto grande e complexo que possui muitas dependências, e instalá-lo a partir do código fonte não é recomendado. A própria Puppet Labs não recomenda a instalação a partir do código
  fonte. É muito mais confiável e conveniente utilizar pacotes já homologados e testados.

.. dica::

  |dica| **Turbinando o Vim**

  Utilize os plugins disponíveis em https://github.com/rodjek/vim-puppet para facilitar a edição de código no Vim.

Debian e Ubuntu
---------------

1. Adicione o repositório da Puppet Labs:

* Debian 8 (Jessie)

::

  # cd /tmp
  # wget http://apt.puppetlabs.com/puppetlabs-release-pc1-jessie.deb
  # dpkg -i  puppetlabs-release-pc1-jessie.deb
  # apt-get update

* Ubuntu 14.04 LTS (Trusty)

::

  # cd /tmp
  # wget http://apt.puppetlabs.com/puppetlabs-release-pc1-trusty.deb
  # dpkg -i puppetlabs-release-pc1-trusty.deb
  # apt-get update

* Ubuntu 16.04 LTS (Xenial)

::

  # cd /tmp
  # wget http://apt.puppetlabs.com/puppetlabs-release-pc1-xenial.deb
  # dpkg -i puppetlabs-release-pc1-xenial.deb
  # apt-get update

Você também pode acessar a página http://apt.puppetlabs.com e localizar o pacote adequado para outras versões do Debian ou Ubuntu.

2. Instale o pacote ``puppet-agent``:

::

  # apt-get -y install puppet-agent

3. Torne os comandos do pacote ``puppet-agent`` disponíveis no *path* do sistema:

::

  # echo "PATH=/opt/puppetlabs/bin:$PATH" >> /etc/bash.bashrc
  # echo "export PATH" >> /etc/bash.bashrc
  # export PATH=/opt/puppetlabs/bin:$PATH

CentOS e Red Hat
----------------

1. Adicione o repositório da Puppet Labs:

* CentOS/Red Hat 6

::

  # yum install -y https://yum.puppetlabs.com/puppetlabs-release-pc1-el-6.noarch.rpm


* CentOS/Red Hat 7

::

  # yum install -y http://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm

Você também pode acessar a página http://yum.puppetlabs.com e localizar o pacote adequado de outras versões e distribuições da família Red Hat.

2. Instale o pacote ``puppet-agent``:

::

  # yum -y install puppet-agent

3. Torne os comandos do pacote ``puppet-agent`` disponíveis no *path* do sistema:

::

  # echo "PATH=/opt/puppetlabs/bin:$PATH" >> /etc/bashrc
  # echo "export PATH" >> /etc/bashrc
  # export PATH=/opt/puppetlabs/bin:$PATH
