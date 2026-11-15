-- Consulta 3: Exibe a agenda completa dos eventos futuros que ainda estão com status 'Agendado', detalhando data, horário, modalidade, prova, categoria, recinto esportivo e capacidade de público.
SELECT e.data_evento AS data, e.horario_inicio AS hora, m.nome_esporte AS esporte, p.nome_prova AS prova, p.genero AS genero, r.nome_recinto AS local, r.capacidade_publico AS capacidade
FROM EVENTO e JOIN PROVA p JOIN RECINTO r JOIN MODALIDADE m
ON e.id_prova = p.id_prova AND e.id_recinto = r.id_recinto AND p.id_modalidade = m.id_modalidade 
WHERE e.status_evento = 'Agendado';