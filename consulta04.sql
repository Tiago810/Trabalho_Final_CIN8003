-- Consulta 4: Calcula a média de tempo e o total de participações válidas por país na prova de 100m Rasos Masculino, desconsiderando casos de W.O. e resultados anulados por doping.
SELECT d.sigla_coi AS pais, ROUND(AVG(r.marca_tempo_placar), 2) AS media_tempo, COUNT(i.id_atleta) AS qtd_atletas
FROM RESULTADO r JOIN EVENTO e JOIN INSCRICAO i JOIN PROVA p JOIN ATLETA a JOIN DELEGACAO d  
ON r.id_evento = e.id_evento AND r.id_inscricao = i.id_inscricao AND e.id_prova = p.id_prova AND i.id_atleta = a.id_atleta AND a.id_delegacao = d.id_delegacao 
WHERE p.id_prova = 1 AND r.indicador_wo = 'Não' AND r.status_doping = 'Limpo'
GROUP BY d.sigla_coi 
ORDER BY media_tempo;