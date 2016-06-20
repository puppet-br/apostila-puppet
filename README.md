# Apostila Puppet #

Para contribuir basta fazer um fork e submeter seu pull request para nós.

[Instruções]: #instrucoes
[Ubuntu]: #ubuntu
[Vagrant]: #vagrant

#### Conteúdo

1. [Instruções para compilar a apostila (gerar o PDF)][Instruções]
    - [No Ubuntu Desktop 14.04/16.04][Ubuntu]
    - [Usando uma VM box no Vagrant][Vagrant]


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

* Instale a box `puppetlabs/debian-6.0.10-64-puppet` com o comando abaixo.

```
vagrant box add puppetlabs/debian-6.0.10-64-puppet
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

