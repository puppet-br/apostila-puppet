Puppet no Windows
=================

O suporte a Windows no Puppet vem melhorando a cada nova versão. Mas não é possível hospedar o Puppet Server no Windows, sendo somente o agente suportado.

Praticamente onde é possível criar compatibilidade, os resources do Puppet suportam Windows normalmente. Em alguns casos são necessários certos cuidados devido as diferenças semânticas entre sistemas Unix-like e Windows.

Prática: Instalação
-------------------

Para a realização dessa prática é necessário você instalar uma terceira máquina com o Windows 8 e aqui chamaremos de **win8.domain.com.br**. Também precisaremos usar a máquina **master.domain.com.br**.

1. Faça login na máquina **win8.domain.com.br**.

2. Aparecerá a tela abaixo perguntando qual é o servidor master, preencha com **master.domain.com.br**.

.. image:: images/windows-puppet-install.png
  :scale: 80%

3. (Opcional) É possível fazer a instalação de maneira automatizada:

::

  msiexec /qn /i puppet.msi PUPPET_MASTER_SERVER=master.domain.com.br


4. Pare o serviço **Puppet**, pois realizaremos manualmente nossas atividades:

::

  sc stop puppet

.. raw:: pdf

  PageBreak

5. Após a instalação, como o serviço **Puppet**  estava em execução, um certificado já foi solicitado ao master. Como de praxe, assine o certificado:

::

  # puppet cert list
    "win8.domain.com.br" (SHA256) EE:58:97:E3:6F:64:15:DF:68:A4:21:DA:A3:E2:81:43:3F: ...
  
  # puppet cert sign win8.domain.com.br
  Signed certificate request for win8.domain.com.br
  Removing file Puppet::SSL::CertificateRequest win8.domain.com.br at \
            '/var/lib/puppet/ssl/ca/requests/win8.domain.com.br.pem'

6. Abra um prompt de comando como Administrador, conforme ilustra a figura abaixo:

.. image:: images/windows-run-as-admin.png

7. Execute o agente da mesma maneira que no Linux.

::

  puppet agent -t

.. nota::

  |nota| **Privilégios**
  
  No Windows, o Puppet precisa de privilégios elevados para funcionar corretamente, afinal ele precisa configurar o sistema.
  
  O serviço do Puppet é executado com privilégio **LocalSystem**, ou seja, sempre com privilégios elevados.
  
  Quando usar a linha de comando, é sempre necessário utilizar o Puppet com privilégios elevados.


Prática: resources para Windows
-------------------------------

Essa prática é realizada em **win8.domain.com.br** e **master.domain.com.br**.

1. Na máquina win8.domain.com.br já temos baixado um pacote MSI que usaremos de exemplo para realizar a instalação. Declarar o seguinte no ``site.pp``:

::

  package {'7-Zip 9.20':
    ensure => 'installed',
    source => 'c:\Users\Puppet\Downloads\7z920.msi',
    install_options => ['/q', { 'INSTALLDIR' => 'C:\Program Files\7-Zip' } ],
  }

2. Aplique o agente (lembre-se de usar um prompt com privilégios elevados)

::

  puppet agent -t


.. dica::

  |dica| **Título do resource package**
  
  O título do resource package precisa ser igual a propriedade *DisplayName* utilizada no registro do Windows para instalação de um pacote MSI. Caso o título seja diferente, o Puppet executará a instalação em todas as execuções.

3. Veja que o 7-Zip foi instalado:

.. image:: images/windows-7zip.png

.. raw:: pdf

  PageBreak

4. Agora vamos configurar um serviço. Declare o seguinte no ``site.pp``:

::

  service {'Audiosrv':
    ensure => 'stopped',
    enable => false,
  }


5. Note que o serviço está em execução (terminal com privilégio regular):

::

  C:\Users\Puppet> sc query audiosrv
   
  SERVICE_NAME: audiosrv
          TYPE               : 20  WIN32_SHARE_PROCESS
          STATE              : 4  RUNNING
                                  (STOPPABLE, NOT_PAUSABLE, IGNORES_SHUTDOWN)
          WIN32_EXIT_CODE    : 0  (0x0)
          SERVICE_EXIT_CODE  : 0  (0x0)
          CHECKPOINT         : 0x0
          WAIT_HINT          : 0x0

6. Aplique o agente (lembre-se de usar um prompt com privilégios elevados)

::

  puppet agent -t


7. Veja que o serviço Windows Audio foi parado e desativado.

::

  C:\Users\Puppet>sc query audiosrv
   
  SERVICE_NAME: audiosrv
          TYPE               : 20  WIN32_SHARE_PROCESS
          STATE              : 1  STOPPED
          WIN32_EXIT_CODE    : 0  (0x0)
          SERVICE_EXIT_CODE  : 0  (0x0)
          CHECKPOINT         : 0x0
          WAIT_HINT          : 0x0


Para mais detalhes sobre as diferenças na declaração dos resources no Windows: http://docs.puppetlabs.com/windows/writing.html

.. raw:: pdf

  PageBreak

Prática: manipulando o registro
-------------------------------

Essa prática é realizada em **win8.domain.com.br** e **master.domain.com.br**.

1. Instalando o módulo **puppetlabs-registry** em **master.domain.com.br**:

::

  # puppet module install puppetlabs/registry
  Preparing to install into /etc/puppetlabs/code/environments/production/modules ...
  Downloading from https://forge.puppetlabs.com ...
  Installing -- do not interrupt ...
  /etc/puppetlabs/code/environments/production/modules
  |-- puppetlabs-registry (v0.1.1)


2. Execute o agente no Windows para instalação do módulo **puppetlabs-registry** (lembre-se de abrir o terminal do Puppet como *Administrator*):

::

  # puppet agent -t

3. Declare uma chave de registro no nosso manifest:

::

  node 'win8.domain.com.br' {
    registry::value { 'Adware':
      key   => 'HKLM\Software\Microsoft\Windows\CurrentVersion\Run',
      value => 'Adware',
      data  => 'c:\adware\adware.exe'
    }
  }


4. Execute o agente no Windows para que a chave no registro seja criada (lembre-se de abrir o terminal do Puppet como *Administrator*):

::

  # puppet agent -t


5. A chave foi criada.

.. image:: images/windows-regedit.png
  :scale: 80%

