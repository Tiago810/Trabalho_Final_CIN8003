-- Consulta 8: Lista os países com pelo menos 5 resultados homologados cuja média de pontos por resultado supera a média geral de pontos de toda a competição.
SELECT d.sigla_coi AS pais, p.nome_oficial AS nome_pais, COUNT(r.id_resultado) AS qtd_resultados, ROUND(AVG(r.pontos_gerados), 2) AS media_pontos
FROM RESULTADO r JOIN INSCRICAO i JOIN ATLETA a JOIN DELEGACAO d JOIN PAIS p
ON r.id_inscricao = i.id_inscricao AND i.id_atleta = a.id_atleta AND a.id_delegacao = d.id_delegacao AND d.sigla_coi = p.sigla_coi
WHERE r.status_homologacao = 'Homologado'
GROUP BY d.sigla_coi, p.nome_oficial
HAVING COUNT(r.id_resultado) >= 5 AND AVG(r.pontos_gerados) > (
    SELECT AVG(pontos_gerados)
    FROM RESULTADO
    WHERE status_homologacao = 'Homologado'
)
ORDER BY media_pontos DESC;