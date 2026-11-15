-- Transação 1: Simulação de encerramento de evento em andamento e homologação de medalha, utilizando SAVEPOINT e ROLLBACK parcial para desfazer uma atualização indevida no quadro de medalhas antes do COMMIT.
BEGIN TRANSACTION;

UPDATE EVENTO
SET status_evento = 'Concluído'
WHERE id_evento = 22;

SAVEPOINT sp_antes_quadro;

-- Simula um lançamento equivocado de pontuação no quadro de medalhas
UPDATE QUADRO_MEDALHAS
SET total_ouros = total_ouros + 10, pontuacao_acumulada = pontuacao_acumulada + 100
WHERE sigla_coi = 'USA';

-- Reverte apenas o erro posterior ao SAVEPOINT, mantendo a atualização do evento
ROLLBACK TO SAVEPOINT sp_antes_quadro;
RELEASE SAVEPOINT sp_antes_quadro;

COMMIT;

-- Restaura o status original do evento 22 para manter a base em 75% de conclusão
UPDATE EVENTO
SET status_evento = 'Em Andamento'
WHERE id_evento = 22;


-- Transação 2: Simulação de afastamento médico de atleta e ajuste de integrantes da delegação, utilizando SAVEPOINT intermediário e ROLLBACK total para cancelar toda a operação sem alterar o banco.
BEGIN TRANSACTION;

UPDATE ATLETA
SET status_medico = 'Lesionado'
WHERE id_atleta = 1;

SAVEPOINT sp_ajuste_delegacao;

UPDATE DELEGACAO
SET total_integrantes = total_integrantes - 1
WHERE id_delegacao = 2;

-- Desfaz até o ponto de salvamento intermediário e, em seguida, cancela toda a transação
ROLLBACK TO SAVEPOINT sp_ajuste_delegacao;
ROLLBACK;