O que é o Puppet
================
Puppet é uma ferramenta e **plataforma Open Source** para automação \
e gerenciamento de configuração de servidores e infraestrutura. Foi \
desenvolvido para ajudar a comunidade SysAdmin na construção e \
compartilhamento de ferramentas maduras e que evitem a duplicação \
de esforços na solução de problemas repetidos. O Puppet é distribuído \
sob a Licença Apache 2.0.

* Possui grande biblioteca com funcionalidades prontas para uso, \
  fornecendo uma plataforma poderosa para simplificar as tarefas \
  executadas por SysAdmins.
* É composto de uma linguagem de configuração declarativa utilizada para \
  expressar a configuração do sistema. O trabalho do SysAdmin é escrito como \
  código na linguagem do Puppet, que é compartilhável tal como qualquer outro \
  código e é possível escrever avançados aplicativos de automação de maneira \
  simples, com apenas algumas linhas de código.
* Utiliza uma arquitetura cliente/servidor para a distribuição da configuração \
  para clientes, que possuem um agente que sempre valida e corrige quaisquer \
  problemas encontrados.
* Extensível via módulos e plugins, permite adicionar funcionalidades sob \
  demanda e compartilhar suas soluções com outros SysAdmins, tornando seu \
  trabalho  mais ágil.

Tradicionalmente, a gestão das configurações de um grande conjunto de \
computadores é feita de práticas imperativas e comandos sequenciais, \
ou seja, simplesmente executando comandos via SSH em um loop. Essa \
abordagem simples de executar comandos sequencialmente melhorou ao longo \
do tempo, mas ainda carrega fundamentais limitações, como vistas no \
capítulo anterior.

O Puppet tem uma abordagem diferente: cada sistema recebe um catálogo de \
*resources* (recursos) e relacionamentos, compara com o estado atual do \
sistema e faz as alterações necessárias para colocar o sistema em \
conformidade com o catálogo.

Os benefícios dessa metodologia vão além de apenas resolver questões de \
divergência de configuração de máquinas: modelar sistemas como dados \
permite ao Puppet:

* Simular mudanças de configuração.
* Acompanhar o histórico de um sistema através de seu ciclo de vida.
* Provar que um código refatorado ainda produz o mesmo estado do sistema.

Como o Puppet funciona?
-----------------------
O Puppet é geralmente (mas nem sempre) usado como cliente/servidor. \
O ciclo de operação nesses casos é o seguinte:

1. Os clientes (chamados de nó, ou *node*) possuem um agente instalado que \
permanece em execução e se conecta a um servidor central (chamado \
tipicamente de *master*) periodicamente (a cada 30 minutos, por padrão).

2. O node solicita a sua configuração, que é copilada e enviada pelo master.

3. Essa configuração "compilada" é chamada de catálogo.

4. O agente aplica o catálogo no node.

5. O resultado da aplicação do catálogo é reportado ao master, havendo \
divergências ou não.

Outra maneira comum de implantação do Puppet é a ausência de um agente em \
execução nos nodes. A aquisição e aplicação do catálogo é agendada na \
``crontab`` ou é disparada via Mcollective. Geralmente, a configuração \
do ambiente codificada na linguagem do Puppet está armazenada em um \
sistema de controle de versão, como Subversion ou Git.

As funcionalidades do Puppet são separadas basicamente em três camadas, \
sendo cada uma responsável por uma parte do sistema como um todo.

Linguagem de configuração
`````````````````````````
O fato de possuir uma linguagem própria de configuração é um dos maiores \
diferenciais do Puppet em relação a outras soluções. Isso pode ser ao \
mesmo tempo um ponto forte ou um ponto fraco, vai depender do que está \
sendo procurado.

Esse questionamento é natural. Afinal, por que não usar algum formato \
de arquivo ou dados já existente, como XML ou YAML? Ou ainda, por que não \
usar Ruby como linguagem, já que o Puppet é desenvolvido em Ruby?

A linguagem declarativa de configuração do Puppet é como se fosse a \
interface com um humano. XML e YAML, sendo formatos desenvolvidos para \
intercâmbio de dados  e para facilitar o processamento por computadores, \
não são boas interfaces para humanos. Algumas pessoas podem ter facilidade \
para ler e escrever nesses formatos, mas há uma razão por que usamos os \
navegadores ao invés de apenas ler documentos HTML diretamente. \
Além disso, usar XML ou YAML limitaria qualquer garantia de que a \
interface fosse declarativa, pois um processo poderia tratar uma \
configuração XML diferentemente de outro.

Camada de transação
```````````````````
A camada de transação é o motor do Puppet. Nela é realizada a configuração \
de cada node, seguindo essas etapas:

1. Interpretar e compilar a configuração

2. Enviar ao agente a configuração compilada.

3. Aplicar a configuração no node.

4. Reportar os resultados para o master.

O Puppet analisa a sua configuração e calcula como aplicá-la no agente. \
Para isso, é criado um grafo que contém todos os resources e suas relações \
uns com os outros. Isso permite ao Puppet decidir a melhor ordem para \
aplicação da configuração com base em relacionamentos criados pelo SysAdmin.

Os resources são compilados no que chamamos de catálogo, que é enviado aos \
nodes e aplicado pelos agentes, que devolvem ao master um relatório sobre \
o que foi feito. Isso não faz o Puppet ser totalmente transacional, como \
um tradicional banco de dados onde alterações podem ser revertidas. Porém, \
é possível modelar sua configuração com um modo "noop" (*no operation*, \
sem operação), onde é possível testar a execução de sua configuração sem \
realmente aplicá-la.

Uma das consequências do modo de operação do Puppet é a idempotência, \
ou seja, as configurações podem ser aplicadas repetidas vezes de maneira \
segura. O Puppet vai alterar somente o que está em divergência com o \
declarado.

Camada de abstração de recursos
```````````````````````````````
A *Resource Abstraction Layer (RAL)* do Puppet é o que garante a \
simplificação das dores de cabeça de um SysAdmin por ter que lidar \
com diversos sistemas operacionais diferentes. Nomes, argumentos e \
localização de comandos, formatos de arquivos, controle de serviços e \
outras tantas diferenças que existem, e muitas vezes não fazem sentido, \
são abstraídas na linguagem de configuração do Puppet.

Para cada resource, existe um *provider* (provedor). O provider é \
responsável pelo "como" fazer para gerenciar um resource, por exemplo, \
a instalação de pacotes. Uma vez que você declara que quer o pacote \
``sudo`` instalado, não será mais necessário se preocupar se a plataforma \
utiliza ``apt`` ou ``yum``.
