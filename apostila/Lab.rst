Laboratório
===========
O padrão mais comum na utilização do Puppet é a tríade pacote, arquivo de configuração e serviço.

Codifique um manifest que declare o seguinte:

1. O pacote ``openssh-server`` deve estar instalado.

2. O arquivo de configuração ``/etc/ssh/sshd_config`` depende do pacote ``openssh-server`` e tem como fonte o caminho ``/root/manifests/sshd_config``.

.. dica::

  |dica| **Sobre o exercício**

  Faça uma cópia do arquivo ``/etc/ssh/sshd_config`` para ``/root/manifests``.

3. O serviço ``sshd`` deve ser recarregado quando o arquivo de configuração ``sshd_config`` for modificado.

4. Seu manifest deve tratar qual é o sistema operacional em relação ao serviço. Se for RedHat/CentOS o serviço será ``sshd``, se for Debian/Ubuntu será apenas ``ssh``.

