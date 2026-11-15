-- Consulta 1: Lista todos os atletas escalados em equipes coletivas, exibindo o país representado, a função de titularidade (Titular ou Reserva) e o código identificador da equipe.
SELECT a.nome AS nome_atleta, d.sigla_coi AS pais, ce.funcao_titularidade AS funcao, e.nome_codigo AS codigo_equipe
FROM DELEGACAO d JOIN EQUIPE e JOIN COMPOSICAO_EQUIPE ce JOIN ATLETA a 
ON d.id_delegacao = e.id_delegacao AND e.id_equipe = ce.id_equipe AND ce.id_atleta = a.id_atleta 
ORDER BY e.id_equipe;