# AluraChallenge - Ciência de Dados - AGO22
 Repositório com as atividades do Alura Challenge de Ciência de Dados (AGO/22)

Ao longo do desenvolvimento procurei utilizar uma técnica mais pedagógica de anotações, inspirada no 5w2h, se baseia em registrar antes de cada ação "O QUE?" será feito e "POR QUE?será feito" eu chamo de "OQPQ" - opcionalmente podemos registrar o "COMO?" será feito;

## SOBRE O CHALENGE

**Boas-vindas!**

Você foi contratado(a) como pessoa cientista de dados para trabalhar em um banco digital internacional chamado **Alura Cash**. Na primeira reunião do seu novo trabalho, a diretoria financeira informa que, recorrentemente, estão surgindo pessoas inadimplentes após a liberação de créditos. Portanto, é solicitada uma solução para que seja possível diminuir as perdas financeiras por conta de pessoas mutuarias que não quitam suas dívidas.

Como cientista de dados, você sugere um estudo das informações financeiras e de solicitação de empréstimo para encontrar padrões que possam indicar uma possível inadimplência.

Desse modo, você solicita um conjunto de dados que contenha as informações de clientes, da solicitação de empréstimo, do histórico de crédito, bem como se a pessoa mutuaria é inadimplente ou não. Com esses dados, você sabe que consegue modelar um classificador capaz de encontrar potenciais clientes inadimplentes e solucionar o problema do Alura Cash.

Por fim, você vai utilizar o **GitHub** e desenvolver um **portfólio** focado em Data Science, Data Analytics e Machine Learning.

## SEMANA 1 - TRATAMENTO DOS DADOS
A semana 1 foi focada no tratamento das informações através de SQL
A pasta SEM_1 contem os 'DUMPS' que foram dados como ponto de partida.
Após fazer a importação no MySQL e realizar as tratativas foram gerados 3 arquivos (um tipo SQL com o raciocínio utilizados e dois arquivos csv para uso posterior)

#### PASSO 1 - Criei o Banco de dados 
#### PASSO 2 - importei os DUMPS
#### PASSO 3 - Verifiquei superficialmente os dados nas tabelas
#### PASSO 4 - Identifiquei o número de linhas de cada tabela
#### PASSO 5 - INCONSISTÊNCIAS DIRETAS - Verificando inexistência de dados nas tabelas
#### PASSO 6 - INCONSISTÊNCIAS INDIRETAS - Verificando a existência de dados inúteis nas tabelas
#### PASSO 7 - INCONSISTÊNCIAS CONCEITUAIS - Verificando a existência de dados anômalos nas tabelas
#### PASSO 8 - CORREÇÃO DAS INCONSISTÊNCIAS -- Abordagem 1
#### PASSO 9 - TRADUÇÃO DOS DADOS
#### PASSO 10 - EXPORT CSV (produziu um arquivo CSV 'TABELA_UNIFICADA_V1.csv')
#### PASSO 11 - CORREÇÃO DAS INCONSISTÊNCIAS -- Abordagem 2 
#### PASSO 12 - EXPORT CSV (produziu um arquivo CSV 'TABELA_UNIFICADA_V2.csv')


## SEMANA 2 - PREPARAÇÃO DOS DADOS E DEFINIÇÃO DO MODELO DE MACHINE LEARNING
Na semana 2 utilizei o 'VS Code' e técnicas do Pyton para Analise, Tratamento e Machine Learning. Foram gerados: 1 arquivo notebook do Jupyter, um CSV com o banco de dados finalizado e tratado (sem outliers e dados inconsistentes)  e os três arquivos de Processos (escalar, encoder e classificador)
#### Aprendizado 01 - Remoção de dados imprecisos e de outliers
#### Aprendizado 02 - Encoding de Variáveis Categoricas
#### Aprendizado 03 - Teste de modelos preditivos - Machine Learning
#### Aprendizado 04 - Replicar os melhores modelos com técnicas de Balanceamento
#### Aprendizado 05 - "Ajuste fino" do modelo através de definição dos Hiperparâmetros
#### Aprendizado 06 - Definição do modelo treino com o Banco de dados inteiro e gravação dos processos - Smote, Scale e Fit do Modelo para uso na API;
