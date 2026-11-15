-- Consulta 6: Soma o total de integrantes das delegações e a pontuação acumulada no quadro de medalhas agrupados por continente.
SELECT p.continente AS continente, SUM(d.total_integrantes) AS total_integrantes_continente, SUM(qm.pontuacao_acumulada) AS total_pontos_continente
FROM DELEGACAO d JOIN PAIS p JOIN QUADRO_MEDALHAS qm 
ON d.sigla_coi = p.sigla_coi AND p.sigla_coi = qm.sigla_coi 
GROUP BY continente
ORDER BY total_integrantes_continente;