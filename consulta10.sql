-- Consulta 10: Relatório de auditoria sobre ocorrências especiais (W.O., doping positivo ou substituições por lesão), tratando valores nulos de laudos médicos e marcas anuladas.
SELECT m.nome_esporte AS modalidade, p.nome_prova AS prova, COALESCE(a.nome, eq.nome_codigo) AS participante, COALESCE(i.laudo_medico_lesao, 'Sem laudo médico') AS laudo, COALESCE(r.marca_tempo_placar, 'Marca anulada / W.O.') AS marca_registrada, r.status_doping AS doping
FROM INSCRICAO i
JOIN PROVA p ON i.id_prova = p.id_prova
JOIN MODALIDADE m ON p.id_modalidade = m.id_modalidade
JOIN RESULTADO r ON i.id_inscricao = r.id_inscricao
LEFT JOIN ATLETA a ON i.id_atleta = a.id_atleta
LEFT JOIN EQUIPE eq ON i.id_equipe = eq.id_equipe
WHERE i.laudo_medico_lesao IS NOT NULL OR r.indicador_wo = 'Sim' OR r.status_doping != 'Limpo'
ORDER BY m.nome_esporte ASC;