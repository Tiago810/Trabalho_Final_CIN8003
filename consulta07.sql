-- Consulta 7: Calcula a média de idade e o total de participantes por prova e categoria, unificando atletas de modalidades individuais e integrantes de equipes coletivas via CTE.
WITH atletas_provas AS (
    SELECT i.id_prova AS id_prova, a.id_atleta AS id_atleta, (STRFTIME('%Y', 'now') - STRFTIME('%Y', a.data_nascimento)) - (STRFTIME('%m-%d', 'now') < STRFTIME('%m-%d', a.data_nascimento)) AS idade
    FROM INSCRICAO i JOIN ATLETA a 
    ON i.id_atleta = a.id_atleta
    UNION ALL
	SELECT i.id_prova AS id_prova, a.id_atleta AS id_atleta, (STRFTIME('%Y', 'now') - STRFTIME('%Y', a.data_nascimento)) - (STRFTIME('%m-%d', 'now') < STRFTIME('%m-%d', a.data_nascimento)) AS idade
    FROM INSCRICAO i JOIN COMPOSICAO_EQUIPE ce JOIN ATLETA a
    ON i.id_equipe = ce.id_equipe AND ce.id_atleta = a.id_atleta
)
SELECT p.nome_prova AS prova, p.genero AS categoria, ROUND(AVG(ap.idade), 1) AS media_idade, COUNT(ap.id_atleta) AS total_participantes
FROM atletas_provas ap JOIN PROVA p
ON ap.id_prova = p.id_prova
GROUP BY p.id_prova, p.nome_prova, p.genero
ORDER BY media_idade DESC;