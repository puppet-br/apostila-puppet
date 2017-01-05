Puppet Tagmail
=========================

No capítulo `PuppetDB e Dashboards Web`_, vimos como instalar o PuppetDB e dois tipos de dashboard. Agora vamos aprender a instalar e configurar o módulo **Tagmail** para permitir que os relatórios de cada execução do puppet-agent também sejam enviados por e-mail, além de serem registrados no PuppetDB.

Os passos de instalação a seguir são executados apenas no host **master.domain.com.br** e é assumido que o ``puppet-agent`` e ``puppetserver`` estão instalados.
 
::

  # puppet module install puppetlabs-tagmail


Ainda no servidor PuppetServer, edite o arquivo ``/etc/puppetlabs/puppet/puppet.conf`` e edite a seguinte linha na seção ``[master]``.

Antes:

.. code-block:: ruby
 
  reports = puppetdb


Depois:

.. code-block:: ruby
 
  reports = puppetdb,tagmail


Crie o arquivo ``/etc/puppetlabs/puppet/tagmail.conf`` com o seguinte conteúdo:

.. code-block:: ruby

  [transport]
  reportfrom = reports@example.org
  smtpserver = smtp.example.org
  smtpport = 25
  smtphelo = example.org

  [tagmap]
  warning,err,alert,emerg,crit: username1@gmail.com,username2@gmail.com
  err,emerg,crit: username1@yahoo.com.br
  warning,alert: username2@gmail.com

Conforme pode ser visto no exemplo acima, na seção ``transport`` ficam os dados do servidor de email que será utilizado para enviar os relatórios por email. O servidor de email pode ser instalado no mesmo host do PuppetServer ou em outro da sua rede. Nesta apostila não explicaremos os detalhes da configuração do servidor de email.

Na seção ``tagmap`` ficam os dados do email das pessoas que receberão os alertas de acordo com os níveis de log. 

Reinicie o PuppetServer com o comando abaixo:

::

  # service puppetserver restart


.. aviso::

  |aviso| **Informações sobre o Tagmail**

  Mais informações sobre a configuração do módulo Tagmail podem ser encontradas em: https://forge.puppet.com/puppetlabs/tagmail


Configurando os Agentes Puppet
------------------------------

Em cada node que executa o Puppet-Agent, adicione no arquivo ``/etc/puppetlabs/puppet/puppet.conf`` o seguinte conteúdo:

.. code-block:: ruby

  [agent]
   report = true
   pluginsync = true

Reinicie o Puppet-Agent com o comando abaixo:

::
  
  # service puppet restart
