Instalação
==========

Diversas distribuições empacotam o Puppet, mas as versões empacotadas e a \
qualidade desses pacotes variam muito, portanto a melhor maneira de instalá-lo \
é utilizando os pacotes oficiais da Companhia Puppet (antiga Puppet Labs, empresa \
que mantém o software). Os pacotes oficiais são extensivamente testatos e \
extremamente confiáveis.

Existem duas versões do Puppet distribuídas pela Puppet: *Puppet Open Source* e \
o *Puppet Enterprise*. O Puppet Enterprise é distribuído gratuitamente para o \
gerenciamento de até 10 nodes, possui suporte oficial e vem acompanhado de uma \
versátil interface web para administração.

Para uma comparação mais detalhada sobre as diferenças entre a versão Open Source \
e a Enterprise, visite as páginas abaixo:

* https://puppet.com/product/puppet-enterprise-and-open-source-puppet
* https://puppet.com/product/faq

.. aviso::

  |aviso| **Instalação a partir do código fonte**

  O Puppet é um projeto grande e complexo que possui muitas dependências, e \
  instalá-lo a partir do código fonte não é recomendado. A própria Puppet não \
  recomenda a instalação a partir do código fonte. É muito mais confiável e \
  conveniente utilizar pacotes já homologados e testados.

.. dica::

  |dica| **Turbinando o Vim**

  Utilize os plugins disponíveis em https://github.com/rodjek/vim-puppet para \
  facilitar a edição de código no Vim.

Debian e Ubuntu
---------------

1. Adicione o repositório da Puppet:

* Debian 8 (Jessie)

::

  sudo cd /tmp
  sudo wget http://apt.puppetlabs.com/puppetlabs-release-pc1-jessie.deb
  sudo dpkg -i  puppetlabs-release-pc1-jessie.deb
  sudo apt-get update

.. raw:: pdf

 PageBreak

* Ubuntu 14.04 LTS (Trusty)

::

  sudo cd /tmp
  sudo wget http://apt.puppetlabs.com/puppetlabs-release-pc1-trusty.deb
  sudo dpkg -i puppetlabs-release-pc1-trusty.deb
  sudo apt-get update

* Ubuntu 16.04 LTS (Xenial)

::

  sudo cd /tmp
  sudo wget http://apt.puppetlabs.com/puppetlabs-release-pc1-xenial.deb
  sudo dpkg -i puppetlabs-release-pc1-xenial.deb
  sudo apt-get update

Você também pode acessar a página http://apt.puppetlabs.com e localizar o pacote \
adequado para outras versões do Debian ou Ubuntu.

2. Instale o pacote ``puppet-agent``:

::

  sudo apt-get -y install puppet-agent

3. Torne os comandos do pacote ``puppet-agent`` disponíveis no *path* do sistema:

::

  sudo export PATH=/opt/puppetlabs/bin:$PATH
  sudo echo "PATH=/opt/puppetlabs/bin:$PATH" >> /etc/bash.bashrc
  sudo echo "export PATH" >> /etc/bash.bashrc

CentOS e Red Hat
----------------

1. Adicione o repositório da Puppet:

* CentOS/Red Hat 6

::

  sudo yum install -y https://yum.puppetlabs.com/puppetlabs-release-pc1-el-6.noarch.rpm


* CentOS/Red Hat 7

::

  sudo yum install -y http://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm

Você também pode acessar a página http://yum.puppetlabs.com e localizar o pacote \
adequado de outras versões e distribuições da família Red Hat.

2. Instale o pacote ``puppet-agent``:

::

  sudo yum -y install puppet-agent

.. raw:: pdf

 PageBreak

3. Torne os comandos do pacote ``puppet-agent`` disponíveis no *path* do sistema:

::

  sudo export PATH=/opt/puppetlabs/bin:$PATH
  sudo echo "PATH=/opt/puppetlabs/bin:$PATH" >> /etc/bashrc
  sudo echo "export PATH" >> /etc/bashrc

4. Obtenha a versão do puppet-agent

::

  puppet --version
