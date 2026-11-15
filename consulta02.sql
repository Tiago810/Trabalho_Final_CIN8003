-- Consulta 2: Contabiliza a quantidade de árbitros registrados por continente, garantindo que continentes sem árbitros cadastrados também apareçam com total zero.
SELECT p.continente AS continente, COUNT(a.id_arbitro) AS qtd_arbitros
FROM PAIS p LEFT JOIN ARBITRO a
ON p.sigla_coi = a.nacionalidade_coi 
GROUP BY continente
ORDER BY qtd_arbitros DESC;