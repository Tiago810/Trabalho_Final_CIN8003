-- Consulta 9: Busca os árbitros internacionais pertencentes a países com delegação registrada que possuem escala confirmada e já homologaram pelo menos 10 resultados oficiais.
SELECT ar.nome AS nome_arbitro, ar.nacionalidade_coi AS pais, m.nome_esporte AS modalidade, COUNT(hr.id_resultado) AS total_homologacoes
FROM ARBITRO ar JOIN MODALIDADE m JOIN HOMOLOGACAO_RESULTADO hr
ON ar.id_modalidade = m.id_modalidade AND ar.id_arbitro = hr.id_arbitro
WHERE ar.nivel_certificacao = 'Internacional'
  AND ar.nacionalidade_coi IN (
      SELECT sigla_coi
      FROM DELEGACAO
  )
  AND EXISTS (
      SELECT 1
      FROM ESCALA_ARBITRAGEM ea
      WHERE ea.id_arbitro = ar.id_arbitro
  )
GROUP BY ar.id_arbitro, ar.nome, ar.nacionalidade_coi, m.nome_esporte
HAVING COUNT(hr.id_resultado) >= 10
ORDER BY total_homologacoes DESC;