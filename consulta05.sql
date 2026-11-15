-- Consulta 5: Identifica o menor (melhor) e o maior tempo registrado em cada prova cronometrada em segundos, filtrando apenas resultados limpos e sem ocorrência de W.O.
SELECT p.nome_prova AS prova, p.genero AS categoria, TRIM(MIN(PRINTF('%50s',r.marca_tempo_placar))) AS menor_tempo, TRIM(MAX(PRINTF('%20s',r.marca_tempo_placar))) AS maior_tempo
FROM RESULTADO r JOIN EVENTO e JOIN PROVA p
ON r.id_evento = e.id_evento AND e.id_prova = p.id_prova
WHERE p.unidade_medida = 'Tempo_Segundos' AND r.status_doping = 'Limpo' AND r.indicador_wo = 'Não'
GROUP BY p.id_prova;