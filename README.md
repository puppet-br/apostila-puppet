# Apostila Puppet #

Acesse o site da apostila em: https://puppet-br.github.io/apostila-puppet

As versões estáveis da apostila, podem ser obtidas em: https://github.com/puppet-br/apostila-puppet/releases

A equipe da Instruct havia produzido uma apostila sobre o básico do Puppet (usando a versão 3.x). A versão 1.0 desta apostila está aqui: http://instruct.com.br/lancamento-apostila-puppet-basico/

Em Junho de 2016, os responsáveis pela Instruct cederam os direitos autorais da apostila para a comunidade Puppet-BR gerenciar o conteúdo.

Para contribuir basta fazer um fork e submeter seu pull request para nós.

Seguem alguns links que explicam como fazer um fork e o pull request.

* https://help.github.com/articles/fork-a-repo/
* https://guides.github.com/activities/forking/
* https://help.github.com/articles/using-pull-requests/
* https://gist.github.com/piscisaureus/3342247

[Editando arquivos RST]: #editando-arquivos-rst
[Instruções para compilar a apostila (gerar o PDF)]: #instruções-para-compilar-a-apostila-gerar-o-pdf
[No Ubuntu Desktop 14.04/16.04]: #no-ubuntu-desktop-14041604
[Usando uma VM box no Vagrant]: #usando-uma-vm-box-no-vagrant

#### Conteúdo

1. [Editando arquivos RST][Editando arquivos RST]
2. [Instruções para compilar a apostila (gerar o PDF)][Instruções para compilar a apostila (gerar o PDF)]
    - [No Ubuntu Desktop 14.04/16.04][No Ubuntu Desktop 14.04/16.04]
    - [Usando uma VM box no Vagrant][Usando uma VM box no Vagrant]

# Editando arquivos RST

O conteúdo da apostila está distribuído em vários arquivos RST.
Para saber o que é um arquivo no formato RST acesse esta página: http://www.reviversoft.com/pt/file-extensions/rst

Para editar os arquivos, use o editor de texto de sua preferência (Exemplo.: vim, gedit, nano, etc...).

# Instruções para compilar a apostila (gerar o PDF)

## No Ubuntu Desktop 14.04/16.04

* O `LibreOffice` é um requisito para a compilação e edição de alguns arquivos da apostila. 
Ele já vem instalado por padrão no Ubuntu 14.04/16.04.

* Instale o pacote `rst2pdf` com o comando abaixo.

```
sudo apt-get install rst2pdf
```

* Clone o repositório da apostila com o comando abaixo:

```
git clone https://github.com/puppet-br/apostila-puppet.git
```

Acesse o diretório no qual você baixou os arquivos fontes da apostila:

```
cd apostila-puppet/
```

Devem existir os arquivos e diretórios abaixo:

```
    apostila
    environments
    README.md
    Vagrantfile
```

Copie o arquivo `apostila-puppet/environments/production/modules/rst2pdf/files/pt_br.py` para `/usr/lib/python2.*/dist-packages/docutils/parsers/rst/languages/pt_br.py`.

O ambiente de compilação da apostila está pronto.

* Acesse os arquivos do diretório `apostila-puppet/apostila` e comece a editá-los.

* Para gerar a apostila no formato PDF, execute a sequência de comandos abaixo.

```
cd apostila-puppet/apostila
chmod +x compila.sh
./compila.sh
```

A apostila será gerada e armazenada em `apostila-puppet/apostla/apostila-puppet.pdf`.

## Usando uma VM box no Vagrant

* Instale o VirtualBox disponibilizado em: https://www.virtualbox.org

* Instale o Vagrant dispobilizado em: https://www.vagrantup.com/downloads.html

* Instale a box `puppetlabs/ubuntu-16.04-64-puppet` com o comando abaixo.

```
vagrant box add puppetlabs/ubuntu-16.04-64-puppet
```

* Clone o repositório da apostila com o comando abaixo:

```
git clone https://github.com/puppet-br/apostila-puppet.git
```

Acesse o diretório no qual você baixou os arquivos fontes da apostila:

```
cd apostila-puppet/
```

Devem existir os arquivos e diretórios abaixo:

```
    apostila
    environments
    README.md
    Vagrantfile
```

* De dentro do diretório onde está o arquivo `Vagrantfile` execute o comando abaixo

```
cd apostila-puppet/
vagrant up
```

O ambiente de compilação da apostila estará pronto em alguns minutos.

Copie o arquivo `apostila-puppet/environments/production/modules/rst2pdf/files/pt_br.py` para `/usr/lib/python2.*/dist-packages/docutils/parsers/rst/languages/pt_br.py`.

* Acesse os arquivos do diretório `apostila-puppet/apostila` e comece a editá-los.

* Para gerar a apostila no formato PDF é necessário estar dentro da VM. 

Execute a sequência de comandos abaixo para gerar o PDF:

```
cd apostila-puppet/
vagrant ssh
cd /vagrant/apostila
chmod +x compila.sh
./compila.sh
```

A apostila será gerada e armazenada em `/vagrant/apostila/apostila-puppet.pdf` e 
também estará acessível em sua máquina dentro do diretório: `apostila-puppet/apostla/apostila-puppet.pdf`.

A VM é necessária apenas para gerar o PDF a partir dos arquivos fontes.

