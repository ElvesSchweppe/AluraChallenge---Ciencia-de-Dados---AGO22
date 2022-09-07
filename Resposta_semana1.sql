## PREPARAÇÃO
/*Os DUMPS foram baixados e importados, estou utilizando o MySQL Workbench*/
/*As verificações, anotações e registros estão sendo submetidas no Trello e serão compartilhadas no GitHub*/

## PASSO 1 - Criei o Banco de dados 
CREATE DATABASE IF NOT EXISTS analise_risco;
USE analise_risco;

## PASSO 2 - importei os DUMPS

## PASSO 3 - Verifiquei superficialmente os dados nas tabelas
SELECT * FROM dados_mutuarios;
SELECT * FROM emprestimos;
SELECT * FROM historicos_banco;
SELECT * FROM id;


## PASSO 4 - Identifiquei o número de linhas de cada tabela
SELECT(
	SELECT COUNT(*) FROM dados_mutuarios) AS mutuario,
    (SELECT COUNT(*) FROM emprestimos) AS emprestimo,
    (SELECT COUNT(*) FROM historicos_banco) AS historico,
    (SELECT COUNT(*) FROM ids) AS ids;


## PASSO 5 - INCONSISTÊNCIAS DIRETAS - Verificando inexistência de dados nas tabelas
## Passo 5.1 - dados_mutuarios
SELECT(
	SELECT COUNT(*) FROM dados_mutuarios WHERE person_id IS NULL) AS ID,
    (SELECT COUNT(*) FROM dados_mutuarios WHERE person_age IS NULL) AS age,
    (SELECT COUNT(*) FROM dados_mutuarios WHERE person_income IS NULL) AS income,
    (SELECT COUNT(*) FROM dados_mutuarios WHERE person_home_ownership IS NULL) AS home,
    (SELECT COUNT(*) FROM dados_mutuarios WHERE person_emp_length IS NULL) AS emp_length;
## Passo 5.2 - emprestimos
SELECT(
	SELECT COUNT(*) FROM emprestimos WHERE loan_id IS NULL) AS ID,
    (SELECT COUNT(*) FROM emprestimos WHERE loan_intent IS NULL) AS intent,
    (SELECT COUNT(*) FROM emprestimos WHERE loan_grade IS NULL) AS grade,
    (SELECT COUNT(*) FROM emprestimos WHERE loan_amnt IS NULL) AS amnt,
    (SELECT COUNT(*) FROM emprestimos WHERE loan_int_rate IS NULL) AS int_rate,
    (SELECT COUNT(*) FROM emprestimos WHERE loan_status IS NULL) AS loan_status,
    (SELECT COUNT(*) FROM emprestimos WHERE loan_percent_income IS NULL) AS percent;
## Passo 5.3 - historicos_banco
SELECT(
	SELECT COUNT(*) FROM historicos_banco WHERE cb_id IS NULL) AS ID,
    (SELECT COUNT(*) FROM historicos_banco WHERE cb_person_default_on_file IS NULL) AS default_on_file,
    (SELECT COUNT(*) FROM historicos_banco WHERE cb_person_cred_hist_length IS NULL) AS cred_hist;

## Passo 5.4 - ids
SELECT(
	SELECT COUNT(*) FROM ids WHERE person_id IS NULL) AS person,
    (SELECT COUNT(*) FROM ids WHERE loan_id IS NULL) AS loan,
    (SELECT COUNT(*) FROM ids WHERE cb_id IS NULL) AS cb;

## PASSO 6 - INCONSISTÊNCIAS INDIRETAS - Verificando a existência de dados inúteis nas tabelas
## Passo 6.1 - dados_mutuarios (procurando ' ')
SELECT(
	SELECT COUNT(*) FROM dados_mutuarios WHERE person_id ='') AS ID,
    (SELECT COUNT(*) FROM dados_mutuarios WHERE person_age ='') AS age,
    (SELECT COUNT(*) FROM dados_mutuarios WHERE person_income ='') AS income,
    (SELECT COUNT(*) FROM dados_mutuarios WHERE person_home_ownership ='') AS home,
    (SELECT COUNT(*) FROM dados_mutuarios WHERE person_emp_length ='') AS emp_length;

## Passo 6.2 - emprestimos
SELECT(
	SELECT COUNT(*) FROM emprestimos WHERE loan_id = '' ) AS ID,
    (SELECT COUNT(*) FROM emprestimos WHERE loan_intent = '') AS intent,
    (SELECT COUNT(*) FROM emprestimos WHERE loan_grade = '') AS grade,
    (SELECT COUNT(*) FROM emprestimos WHERE loan_amnt = '') AS amnt,
    (SELECT COUNT(*) FROM emprestimos WHERE loan_int_rate = '') AS int_rate,
    (SELECT COUNT(*) FROM emprestimos WHERE loan_status = '') AS loan_status,
    (SELECT COUNT(*) FROM emprestimos WHERE loan_percent_income = '') AS percent_income;

## Passo 6.3 - historicos_banco
SELECT(
	SELECT COUNT(*) FROM historicos_banco WHERE cb_id = '') AS ID,
    (SELECT COUNT(*) FROM historicos_banco WHERE cb_person_default_on_file ='') AS default_on_file,
    (SELECT COUNT(*) FROM historicos_banco WHERE cb_person_cred_hist_length = '') AS cred_hist;

## Passo 6.4 - ids
SELECT(
	SELECT COUNT(*) FROM ids WHERE person_id ='') AS person,
    (SELECT COUNT(*) FROM ids WHERE loan_id ='') AS loan,
    (SELECT COUNT(*) FROM ids WHERE cb_id ='') AS cb;

## PASSO 7 - INCONSISTÊNCIAS CONCEITUAIS - Verificando a existência de dados anômalos nas tabelas
## Passo 7.1 - dados_mutuarios
##(Para os dados pessoais crianças ou pessoas muito idosas, ou ainda pessoas que estão empregadas a mais tempo do que tem idade, ou mesmo que começaram a trabalhar enquanto crianças)
##(Utilizei - criança abaixo de 13 anos e idades suspeitas acima de 100)
SELECT(
	SELECT COUNT(*) FROM dados_mutuarios WHERE person_age >100) AS mais_de_100_anos,
    (SELECT COUNT(*) FROM dados_mutuarios WHERE person_age <13) AS criancas,
    (SELECT COUNT(*) FROM dados_mutuarios WHERE ((person_age-person_emp_length)>0 AND (person_age-person_emp_length) < 13)) AS trabalho_infantil,
    (SELECT COUNT(*) FROM dados_mutuarios WHERE (person_age-person_emp_length)<0) AS servico_acima_idade;

## Passo 7.2 - emprestimos
##(Para os dados de emprestimos podem ser anômalos empréstimos com valor 'zerado' ou 'sem taxa de juros' o que já foi verificado como Inconsistencia Indireta no passo 6.2) 
##(A coluna 'loan_percent_income'  também pode trazer distorções se for permitida a edição ou inserção dos dados de renda, valor emprestado e comprometimento em separado e se não for gerida por uma fórmula)
SELECT tab_unica.* FROM
(SELECT 
ids.person_id,
dados_mutuarios.person_income,
emprestimos.loan_amnt,
emprestimos.loan_percent_income,
ROUND(emprestimos.loan_amnt / dados_mutuarios.person_income,2) as loan_percent_calculado

FROM
/*Tabelas Unificadas*/
((ids 
INNER JOIN 
dados_mutuarios
ON
ids.person_id = dados_mutuarios.person_id)
INNER JOIN
emprestimos
ON
ids.loan_id = emprestimos.loan_id)) tab_unica
WHERE (person_id <> '' AND loan_percent_calculado <> loan_percent_income );

## Passo 7.3 - historicos_banco
##(Para os históricos podemos considerar anômalos distorções, se for permitida a edição ou inserção dos dados de idade e tempo de crédito em separado, podemos ter históricos de crédito maiores que a idade)
SELECT tab_unica.* FROM
(SELECT 
ids.person_id,
dados_mutuarios.person_age,
historicos_banco.cb_person_cred_hist_length,
(dados_mutuarios.person_age - historicos_banco.cb_person_cred_hist_length) as idade_primeiro_credito

FROM
/*Tabelas Unificadas*/
((ids 
INNER JOIN 
dados_mutuarios
ON
ids.person_id = dados_mutuarios.person_id)
INNER JOIN
historicos_banco
ON
ids.cb_id = historicos_banco.cb_id)) tab_unica
WHERE (person_age - cb_person_cred_hist_length <13);


##PASSO 8 - CORREÇÃO DAS INCONSISTÊNCIAS -- Abordagem 1
## Como não havia uma orientação inicial do que seria a "correção dos dados" optei por não eliminar nada, num primeiro momento, criei duas colunas adicionais uma traz a informação se existe algum campo nulo no cadastro, a outra traz a informação se existe algum ponto a ser observado;
## A unica exceção são as quatro chaves vazias em 'ids.person_id' que ao se cruzarem com a 'dados_mutuarios' no 'inner join' causam 12 resultados adicionais;
## Aproveitei para gerar a exibição que será exportada com o nomes das colunas traduzidos;

DELETE FROM ids where ids.person_id = ''; /*removidas as 4 chaves*/

## Para facilitar o processo criei uma função que vai associar os campos a serem observados na presença de dados 'estranhos'
DELIMITER $$
CREATE FUNCTION observar(numero INT) RETURNS TEXT
BEGIN
	DECLARE passo INT DEFAULT 3;
    DECLARE subtrator INT DEFAULT numero;
    DECLARE resposta TEXT DEFAULT '';
    WHILE passo >=0 DO
		CASE WHEN (subtrator-POWER(10,passo)>=0) THEN
			SET subtrator = subtrator - POWER(10,passo);
			SET resposta = CONCAT(resposta,
				CASE WHEN passo = 3 THEN 'Idade maior que 100 ou menor que 13; '
					WHEN passo = 2 THEN 'Tempo de serviço incompatível com a idade; '
                    WHEN passo = 1 THEN 'Cálculo do comprometimento da renda diferente do apontado; '
                    WHEN passo = 0 THEN 'Histórico de crédito incompatível com a idade;'
                ELSE
                    'nenhuma'
				END
                );
			SET passo = passo - 1;
		ELSE
			SET passo = passo - 1;
        END CASE;
	END WHILE;
    RETURN resposta;
END $$
DELIMITER ;

## UNIÃO DAS TABELAS PARA EXPORTAR
SELECT tab_unica.person_age AS IDADE,
	tab_unica.person_income AS RENDA_ANUAL,
    tab_unica.person_home_ownership AS MORADIA,
    tab_unica.person_emp_length AS TEMPO_DE_SERVICO,
    tab_unica.loan_intent AS MOTIVO_EMPRESTIMO,
    tab_unica.loan_grade AS SCORE_CREDITO,
    tab_unica.loan_amnt AS VALOR_EMPRESTIMO,
    tab_unica.loan_int_rate AS TAXA_DE_JUROS,
    tab_unica.loan_status AS SITUACAO_INADIMPLENCIA,
    tab_unica.loan_percent_income AS COMPROMETIMENTO_DA_RENDA,
    tab_unica.cb_person_default_on_file AS HISTORICO_DE_INADIMPLENCIA,
    tab_unica.cb_person_cred_hist_length AS HISTORICO_DE_CREDITO,
    
(CASE WHEN
/*condição dos dados pessoais*/
tab_unica.person_id = "" or
tab_unica.person_age is null or
tab_unica.person_income is null or
tab_unica.person_home_ownership = "" or
tab_unica.person_emp_length is null or

/*Condição para os dados de emprestimos*/
tab_unica.loan_intent = "" or
tab_unica.loan_grade = "" or
tab_unica.loan_amnt is null or
tab_unica.loan_int_rate is null or
tab_unica.loan_status is null or
tab_unica.loan_percent_income = "" or
tab_unica.loan_percent_income is null or

/*condição dos dados de histórico*/
tab_unica.cb_person_default_on_file="" or
tab_unica.cb_person_cred_hist_length is null

THEN
'não'
ELSE
'sim'
END)

AS  CADASTRO_COMPLETO,

observar(
1000*(CASE WHEN (tab_unica.person_age>100 OR tab_unica.person_age<13) THEN 1 ELSE 0 END)+
100*(CASE WHEN (tab_unica.person_age - tab_unica.person_emp_length<13) THEN 1 ELSE 0 END)+
10*(CASE WHEN (ROUND((tab_unica.loan_amnt/tab_unica.person_income),2)<>tab_unica.loan_percent_income) THEN 1 ELSE 0 END)+
(CASE WHEN (tab_unica.person_age - tab_unica.cb_person_cred_hist_length<13)THEN 1 ELSE 0 END)
)
AS OBSERVACOES

FROM
(SELECT 
dados_mutuarios.person_id, dados_mutuarios.person_age,
dados_mutuarios.person_income, dados_mutuarios.person_home_ownership,
dados_mutuarios.person_emp_length,
emprestimos.loan_id, emprestimos.loan_intent,
emprestimos.loan_grade, emprestimos.loan_amnt,
emprestimos.loan_int_rate, emprestimos.loan_status,
emprestimos.loan_percent_income,
historicos_banco.cb_id, historicos_banco.cb_person_default_on_file,
historicos_banco.cb_person_cred_hist_length
FROM
/*Tabelas Unificadas*/
(((ids 
INNER JOIN 
dados_mutuarios
ON
ids.person_id = dados_mutuarios.person_id)
INNER JOIN
emprestimos
ON
ids.loan_id = emprestimos.loan_id)
INNER JOIN
historicos_banco
ON
ids.cb_id = historicos_banco.cb_id)) tab_unica
;


## PASSO 9 - TRADUÇÃO DOS DADOS
UPDATE dados_mutuarios SET
	person_home_ownership = REPLACE(person_home_ownership, "Rent", "alugada"),
	person_home_ownership = REPLACE(person_home_ownership, "Own", "propria"),
	person_home_ownership = REPLACE(person_home_ownership, "Mortgage", "hipoteca"),
	person_home_ownership = REPLACE(person_home_ownership, "Other", "outro");

UPDATE emprestimos SET
	loan_intent = REPLACE(loan_intent, "Personal", "uso_pessoal"),
    loan_intent = REPLACE(loan_intent, "Homeimprovement", "reforma"),
    loan_intent = REPLACE(loan_intent, "Venture", "empreendimento"),
    loan_intent = REPLACE(loan_intent, "Education", "educacao"),
    loan_intent = REPLACE(loan_intent, "Medical", "saude"),
    loan_intent = REPLACE(loan_intent, "Debtconsolidation", "quitacao_debitos");
    
UPDATE historicos_banco SET
	cb_person_default_on_file = REPLACE(cb_person_default_on_file,'Y', 's'),
    cb_person_default_on_file = REPLACE(cb_person_default_on_file,'N', 'n');

## PASSO 10 - EXPORT CSV
## Após as traduções executei as linhas de comando do "PASSO 8" novamente
## Exportei através do botão de atalho do MySQL Workbench


##PASSO 11 - CORREÇÃO DAS INCONSISTÊNCIAS -- Abordagem 2 

## Após a reunião de retorno onde apresentamos algumas soluções foi orientado que as linhas que possuem campos nulos podem ser excluidas
## no processo de unir as tabelas, assim ajustei as linhas de execução do "PASSO 8" para a exclusão desses campos.


## UNIÃO DAS TABELAS PARA EXPORTAR - excluindo campos nulos
SELECT tab_unica.person_age AS IDADE,
	tab_unica.person_income AS RENDA_ANUAL,
    tab_unica.person_home_ownership AS MORADIA,
    tab_unica.person_emp_length AS TEMPO_DE_SERVICO,
    tab_unica.loan_intent AS MOTIVO_EMPRESTIMO,
    tab_unica.loan_grade AS SCORE_CREDITO,
    tab_unica.loan_amnt AS VALOR_EMPRESTIMO,
    tab_unica.loan_int_rate AS TAXA_DE_JUROS,
    tab_unica.loan_status AS SITUACAO_INADIMPLENCIA,
    tab_unica.loan_percent_income AS COMPROMETIMENTO_DA_RENDA,
    tab_unica.cb_person_default_on_file AS HISTORICO_DE_INADIMPLENCIA,
    tab_unica.cb_person_cred_hist_length AS HISTORICO_DE_CREDITO

FROM
(SELECT 
dados_mutuarios.person_id, dados_mutuarios.person_age,
dados_mutuarios.person_income, dados_mutuarios.person_home_ownership,
dados_mutuarios.person_emp_length,
emprestimos.loan_id, emprestimos.loan_intent,
emprestimos.loan_grade, emprestimos.loan_amnt,
emprestimos.loan_int_rate, emprestimos.loan_status,
emprestimos.loan_percent_income,
historicos_banco.cb_id, historicos_banco.cb_person_default_on_file,
historicos_banco.cb_person_cred_hist_length
FROM
/*Tabelas Unificadas*/
(((ids 
INNER JOIN 
dados_mutuarios
ON
ids.person_id = dados_mutuarios.person_id)
INNER JOIN
emprestimos
ON
ids.loan_id = emprestimos.loan_id)
INNER JOIN
historicos_banco
ON
ids.cb_id = historicos_banco.cb_id)) tab_unica
    
WHERE NOT(
/*condição dos dados pessoais*/
tab_unica.person_age is null or
tab_unica.person_income is null or
tab_unica.person_home_ownership = "" or
tab_unica.person_emp_length is null or

/*Condição para os dados de emprestimos*/
tab_unica.loan_intent = "" or
tab_unica.loan_grade = "" or
tab_unica.loan_amnt is null or
tab_unica.loan_int_rate is null or
tab_unica.loan_status is null or
tab_unica.loan_percent_income = "" or
tab_unica.loan_percent_income is null or

/*condição dos dados de histórico*/
tab_unica.cb_person_default_on_file="" or
tab_unica.cb_person_cred_hist_length is null);

## PASSO 12 - EXPORT CSV
## Exportei através do botão de atalho do MySQL Workbench