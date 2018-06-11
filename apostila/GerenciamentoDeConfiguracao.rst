Introdução ao Gerenciamento de Configuração
===========================================
Os desafios no gerenciamento de infraestrutura e serviços
---------------------------------------------------------
A quantidade de servidores e serviços computacionais existentes nos mais variados \
setores de atividades têm crescido constantemente na última década, e não há \
sinais de que vá diminuir. Administrar, configurar, atualizar e documentar esses \
crescentes ambientes computacionais torna-se cada vez mais desafiador. E, por isso, \
garantir que dezenas, ou até mesmo centenas de sistemas estejam configurados \
corretamente torna-se cada vez mais inviável.

As alterações necessárias na configuração de um grande parque de servidores, \
sejam para melhorias ou para correção de problemas são maçantes, consomem muito \
tempo e podem causar mais problemas do que solucioná-los, devido a erros \
operacionais e muitas vezes também a inviabilidade de revertê-los.

Diante desse cenário, é fundamental utilizar uma ferramenta robusta, que não \
utilize scripts que apenas executam comandos sequencialmente. É importante \
também que essa ferramenta certifique-se da corretude da configuração do ambiente, \
sem se basear em documentação que pode estar desatualizada ou, muitas vezes, \
incorreta.

O que é gerenciamento de configuração?
``````````````````````````````````````
Grande parte de problemas de disponibilidade em serviços de missão crítica na \
área de TI são causados por falhas humanas e gestão de processos. Parte \
significativa desses problemas poderia ser evitada se fosse feita uma melhor \
coordenação na gerência de mudanças e de configuração.

Muitas organizações de TI utilizam processos manuais, scripts customizados, \
imagens de sistema e outras técnicas rudimentares para execução de tarefas \
repetitivas. Em grandes ambientes ou nos que possuem diversas equipes, esses \
métodos rudimentares não são escaláveis, são difíceis de manter e podem causar \
diversos problemas, como: divergências entre a configuração de fato e a \
documentação, não cumprimento de normas e perda de produtividade e agilidade.

Diante disso, gerenciamento de configuração é o processo de absorção controlada \
de mudanças, padronizando a aplicação de configurações em infraestrutura \
de TI de uma forma automatizada e ágil, sendo fundamental para o sucesso de \
diversos processos, como provisionamento de novos sistemas, aplicação de patches e \
cumprimento de normas de segurança.

Questões sobre a cultura estabelecida na administração de sistemas
------------------------------------------------------------------

Diversos setores de Tecnologia da Informação têm uma visão relativamente negativa \
dos Administradores de Sistemas (''System Administrator'' ou simplesmente ''SysAdmin'') \
e profissionais que trabalham em atividades correlatas. Esses profissionais \
geralmente são sobrecarregados e estão sob constante pressão, pois as organizações \
precisam que suas redes, sistemas e serviços estejam sempre disponíveis.

A visão negativa do SysAdmin tem um certo fundamento, pois existem algumas \
características nele que são muito comuns.

* Aversão a mudanças

Por ter que garantir que tudo esteja sempre funcionando, o SysAdmin é muito \
conservador quando analisa qualquer tipo de mudança no ambiente, por menor que \
seja. Ele sabe que, muitas vezes, alterações a princípio simples e inocentes \
podem causar sérias consequências. Os mais precavidos não fazem nenhuma alteração \
antes de se montar um plano para que, em caso de qualquer imprevisto, mesmo que \
manualmente, as alterações possam ser revertidas.

* Lentidão na entrega de novos serviços

Por estar sempre sob pressão para garantir a disponibilidade e qualidade dos \
serviços que já estão na rede, novos serviços ou a atualização dos já em \
funcionamento geralmente não são prioridade. As empresas, muitas vezes por \
questões de certificação com padrões de qualidade, cobram do SysAdmin uma \
extensa carga de atividades extras na entrega de um novo serviço, como \
documentação, treinamento de usuários, operadores e etc.

* Compartilhamento de informações é tabu

Em organizações onde existe mais de um SysAdmin, é muito comum encontrar \
rachas dentro da equipe do tipo: Fulano cuida das máquinas A, B e C, Ciclano \
cuida das máquinas X, Y e Z e Beltrano de M, N e O. E nenhum deles se ajuda ou \
sabe claramente o quê ou como o outro configurou. E, pior ainda, quando Fulano \
precisa intervir nas máquinas de Ciclano, sobram críticas do tipo "Lógico que \
deu problema, olha como ele fez!" ou "Onde está a documentação disso?" e, ainda \
por cima, "A documentação dele está toda errada!".

* Permissões de acesso são vistas como troféu

Nada como ter plenos poderes. Para muitos SysAdmins, infelizmente, conseguir \
acesso a servidores que anteriormente ele não tinha é uma conquista. Mais por \
questões sociais do que técnicas. Afinal, muitos encaram isso como a derrota do \
colega que anteriormente tinha acesso exclusivo a um determinado servidor e agora \
perdeu esse "privilégio".

As organizações fazem o que podem para solucionar esses problemas, mas não é uma \
tarefa fácil. Muitos acreditam que o principal método para solucionar essas \
questões é a criação de uma boa documentação sobre o ambiente. Porém, o próprio \
SysAdmin geralmente é extremamente cético sobre a eficácia dele documentar suas \
atividades, configurações e planos.

Das diversas soluções que existem para documentação, talvez a menos pior seja a \
equipe utilizar uma wiki. Utilizando qualquer wiki, de graça vem o \
versionamento e mecanismo de busca. Porém, mesmo utilizando a wiki, ao longo do \
tempo a documentação apresentará diversas limitações.

* Validação da documentação.

Como testar se todos os comandos e arquivos registrados na wiki estão corretos? \
Provavelmente não houve má fé do SysAdmin quando ele registrou **o como** se \
chegou ao estado de um servidor com Apache, PHP e PostgreSQL, mas basta que \
apenas um dos passos seja deixado de lado para que ninguém mais consiga repetir \
com sucesso a instalação e configuração. O que um gerente deve fazer? Ordenar \
que outro SysAdmin valide tudo o que o colega fez? Não é nada divertido de se \
fazer, mas muitas vezes é um mal necessário.

* A documentação ficará desatualizada.

É natural que, ao longo do dia-a-dia da área de TI, emergências surjam e \
sejam necessárias intervenções imediatas no ambiente. Ajustes como limites de \
conexões, espaço alocado, etc. A questão é, depois da emergência, alguém se \
lembrará de atualizar a documentação com as mudanças? Provavelmente não.

Dentro do ambiente de servidores, geralmente as equipes não utilizam nenhum \
tipo de controle mais rígido no acesso e controle de alterações na configuração. \
Certamente, quando feitas, essas perguntas são difíceis de serem respondidas:

* Quando foi configurado?
* Quem configurou?
* Mudou por quê?
* Quem mandou?

Uma ferramenta de sistema de chamados combinada com muita disciplina da equipe \
podem ajudar na resposta dessas perguntas, mas os reflexos dessa burocracia no \
SysAdmin fazem com que ele se torne menos motivado. Além do mais, alterações \
incorretas em configurações que estavam funcionando são piores do que deixar de \
configurar, já que antes funcionava. E, ainda por cima, como garantir que tudo \
estará configurado corretamente semana que vem?

O resultado disso tudo é que, apenas com o uso desses mecanismos, manter \
documentação consistente ao longo do tempo requer um grande esforço e disciplina, \
tornando o sucesso do trabalho do SysAdmin muito improvável.

O ciclo vicioso de necessidade constante de manutenção e documentação leva um \
imenso gasto de tempo que deveria ser dedicado a atividades mais nobres e \
estimulantes para o trabalho. E, sem dúvida, quanto mais aplicações, serviços, \
sistemas, máquinas e etc, maior é o risco de problemas.

Limitações das soluções comuns de automação
-------------------------------------------
É aceito de praxe pelo mercado que um bom SysAdmin é aquele que faz suas \
próprias ferramentas e automatiza ao máximo seu trabalho.

Por outro lado, as práticas da maioria dos SysAdmins, até as dos mais \
experientes, têm certos limites de viabilidade em ambientes mais complexos \
ou com equipes multidisciplinares. É comum copiar arquivos de configuração de \
uma máquina "que funciona" para uma máquina nova. Muitas vezes, quando são \
necessárias alterações em muitas máquinas, fazer SSH em um laço com uma lista \
de IPs ou nomes de máquinas também é comum.

O que para muitos é magia negra, para o SysAdmin é a solução: shell script. \
Longos scripts com comandos encadeados e conectados com pipes e saídas filtradas \
com expressões regulares, que resultam na entrada de outro comando que ordena \
e depois corta e recorta a saída final.

Shell Script é excelente para atividades repetitivas e cotidianas, mas bom \
apenas para soluções *ad-hoc* e pontuais. É de difícil leitura, principalmente \
para quem não é o autor. É comum SysAdmins que descartam todos os scripts de um \
antecessor na empresa, pois é mais fácil fazer um novo do que tentar entender \
o que já existe.

Além disso, quando estamos desenvolvendo um Shell Script, nos desprendemos de \
diversas amarras das linguagens de programação. Mas isso tem um preço. Sejamos \
honestos, scripts sempre são:

* Protegidos quanto à concorrência? Você está checando se tem acesso exclusivo \
  à máquina ou aos arquivos e diretórios que está manipulando?
* Testáveis? É possível simular a execução de um script?
* Reversíveis? Os comandos dados pelo script podem ser revertidos naturalmente?
* Legíveis? Não existem convenções para estilo.
* Geram bons logs? É possível saber o que está acontecendo, em diferentes \
  níveis de prioridade?
* Portáveis? O mesmo script funciona em todos os sistemas do seu ambiente? \
  (Você tem muita sorte se todos os seus sistemas são idênticos)

Diante de todos esses problemas, é necessário evoluir. Para isso, precisamos \
quebrar paradigmas.
