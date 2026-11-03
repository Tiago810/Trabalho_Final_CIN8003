-- ============================================================================
-- UNIVERSIDADE FEDERAL DE SANTA CATARINA (UFSC)
-- CIN 8003 - Bancos de Dados e Aplicações | Prof. Dr. Moisés Lima Dutra
-- Estudante: Tiago Campos Costa
-- Etapa: Projeto Final (Parte 2) - Tarefa 4a: Script DDL (SQLite)
-- Cenário: Sistema de Gestão para Jogos Poliesportivos Internacionais
-- ============================================================================

PRAGMA foreign_keys = ON;

-- Limpeza prévia (ordem reversa de dependência referencial)
DROP TABLE IF EXISTS HOMOLOGACAO_RESULTADO;
DROP TABLE IF EXISTS RESULTADO;
DROP TABLE IF EXISTS ESCALA_ARBITRAGEM;
DROP TABLE IF EXISTS EVENTO;
DROP TABLE IF EXISTS INSCRICAO;
DROP TABLE IF EXISTS COMPOSICAO_EQUIPE;
DROP TABLE IF EXISTS EQUIPE;
DROP TABLE IF EXISTS ARBITRO;
DROP TABLE IF EXISTS PROVA;
DROP TABLE IF EXISTS MODALIDADE;
DROP TABLE IF EXISTS RECINTO;
DROP TABLE IF EXISTS ATLETA;
DROP TABLE IF EXISTS QUADRO_MEDALHAS;
DROP TABLE IF EXISTS DELEGACAO;
DROP TABLE IF EXISTS PAIS;

-- ----------------------------------------------------------------------------
-- 1. Tabela PAIS
-- ----------------------------------------------------------------------------

CREATE TABLE PAIS (
    sigla_coi CHAR(3) PRIMARY KEY,
    nome_oficial VARCHAR(100) NOT NULL UNIQUE,
    continente VARCHAR(20) NOT NULL,
    CONSTRAINT chk_pais_sigla CHECK (LENGHT(sigla_coi) = 3),
    CONSTRAINT chk_continente CHECK (continente IN ('América', 'Europa', 'Ásia', 'África', 'Oceania'))
);

-- ----------------------------------------------------------------------------
-- 2. Tabela DELEGACAO
-- ----------------------------------------------------------------------------

CREATE TABLE DELEGACAO (
    id_delegacao INTEGER PRIMARY KEY AUTOINCREMENT,
    sigla_coi CHAR(3) NO NULL UNIQUE,
    chefe_delegacao VARCHAR(120) NOT NULL,
    ano_edicao INTEGER NOT NULL DEFAULT 2026,
    total_integrantes INTEGER NOT NULL DEFAULT 1,
    CONSTRAINT fk_delegacao_pais FOREIGN KEY (sigla_coi)
        REFERENCES PAIS(sigla_coi) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_delegacao_ano CHECK (ano_edicao >= 1896),
    CONSTRAINT chk_delegacao_integrantes CHECK (total_integrantes >= 1)
);

-- ----------------------------------------------------------------------------
-- 3. Tabela ATLETA
-- ----------------------------------------------------------------------------

CREATE TABLE ATLETA (
    id_atleta INTEGER PRIMARY KEY AUTOINCREMENT,
    id_delegacao INTEGER NOT NULL,
    nome VARCHAR(120) NOT NULL,
    data_nascimento DATE NOT NULL,
    sexo_categoria CHAR(1) NOT NULL,
    status_medico VARCHAR(20) NOT NULL DEFAULT 'Apto',
    status_antidoping VARCHAR(20) NOT NULL DEFAULT 'Negativo',
    CONSTRAINT fk_atleta_delegacao FOREIGN KEY (id_delegacao)
        REFERENCES DELEGACAO(id_delegacao) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_atleta_sexo CHECK (sexo_categoria IN ('M', 'F')),
    CONSTRAINT chk_atleta_medico CHECK (status_medico IN ('Apto', 'Lesionado', 'Suspenso')),
    CONSTRAINT chk_atleta_doping CHECK (status_antidoping IN ('Pendente', 'Negativo', 'Positivo'))
);

-- ----------------------------------------------------------------------------
-- 4. Tabela MODALIDADE
-- ----------------------------------------------------------------------------

CREATE TABLE MODALIDADE (
    id_modalidade INTEGER PRIMARY KEY AUTOINCREMENT,
    nome_esporte VARCHAR(80) NOT NULL UNIQUE,
    tipo VARCHAR(15) NOT NULL,
    idade_minima INTEGER NOT NULL DEFAULT 14,
    regras_gerais TEXT NOT NULL,
    CONSTRAINT chk_modalidade_tipo CHECK (tipo IN ('Individual', 'Coletivo'))
    CONSTRAINT chk_modalidade_idade CHECK (idade_minima >= 0 AND idade_minima <= 50)
);

-- ----------------------------------------------------------------------------
-- 5. Tabela PROVA
-- ----------------------------------------------------------------------------

CREATE TABLE PROVA (
    id_prova INTEGER PRIMARY KEY AUTOINCREMENT,
    id_modalidade INTEGER NOT NULL,
    nome_prova VARCHAR(100) NOT NULL,
    genero VARCHAR(15) NOT NULL,
    limite_vagas_delegacao INTEGER NOT NULL DEFAULT 2,
    indice_classificatorio DECIMAL(10,2),
    unidade_medida VARCHAR(20) NOT NULL,
    CONSTRAINT fk_prova_modalidade FOREIGN KEY (id_modalidade)
        REFERENCES MODALIDADE(id_modalidade) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT uq_prova_modalidade_genero UNIQUE (id_prova, id_modalidade, genero),
    CONSTRAINT chk_prova_genero CHECK (genero IN ('Masculino', 'Feminino', 'Misto')),
    CONSTRAINT chk_prova_limite CHECK (limite_vagas_delegacao > 0),
    CONSTRAINT chk_prova_unidade CHECK (unidade_medida IN ('Tempo_Segundos', 'Distancia_Metros', 'Pontos', 'Gols', 'Sets'))

);

-- ----------------------------------------------------------------------------
-- 6. Tabela EQUIPE
-- ----------------------------------------------------------------------------

CREATE TABLE EQUIPE (
    id_equipe INTEGER PRIMARY KEY AUTOINCREMENT,
    id_delegacao INTEGER NOT NULL,
    id_prova INTEGER NOT NULL,
    nome_codigo VARCHAR(50) NOT NULL,
    CONSTRAINT fk_equipe_delegacao FOREIGN key (id_delegacao)
        REFERENCES DELEGACAO(id_delegacao) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_equipe_prova FOREIGN key (id_prova)
        REFERENCES PROVA(id_prova) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT un_equipe_delegacao_prova UNIQUE (id_delegacao, id_prova, nome_codigo)
);

-- ----------------------------------------------------------------------------
-- 7. Tabela Associativa COMPOSICAO_EQUIPE
-- ----------------------------------------------------------------------------

CREATE TABLE COMPOSICAO_EQUIPE (
    id_equipe INTEGER NOT NULL,
    id_atleta INTEGER NOT NULL UNIQUE,
    funcao_titularidade VARCHAR(15) DEFAULT 'Titular',
    PRIMARY KEY (id_equipe, id_atleta),
    CONSTRAINT fk_comp_equipe FOREIGN key (id_equipe)
        REFERENCES EQUIPE(id_equipe) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_comp_atleta FOREIGN key (id_atleta)
        REFERENCES ATLETA(id_atleta) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_comp_titularidade CHECK (funcao_titularidade IN ('Titular', 'Reserva'))
);

-- ----------------------------------------------------------------------------
-- 8. Tabela INSCRICAO
-- ----------------------------------------------------------------------------

CREATE TABLE INSCRICAO (
    id_inscricao INTEGER PRIMARY KEY AUTOINCREMENT,
    id_prova INTEGER NOT NULL,
    id_atleta INTEGER,
    id_equipe INTEGER,
    data_hora_registro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status_inscricao VARCHAR(30) NOT NULL DEFAULT 'Confirmada',
    historico_substituicao TEXT,
    laudo_medico_lesao VARCHAR(150),
    CONSTRAINT fk_inscricao_prova FOREIGN KEY (id_prova)
        REFERENCES PROVA(id_prova) ON DELETE RESTRICT ON UPDATE CASCADE
    CONSTRAINT fk_inscricao_atleta FOREIGN KEY (id_atleta)
        REFERENCES ATLETA(id_atleta) ON DELETE CASCADE ON UPDATE CASCADE
    CONSTRAINT fk_inscricao_equipe FOREIGN KEY (id_equipe)
        REFERENCES EQUIPE(id_equipe) ON DELETE CASCADE ON UPDATE CASCADE
    CONSTRAINT uq_inscricao_prova_atleta UNIQUE (id_prova, id_atleta),
    CONSTRAINT uq_inscricao_prova_equipe UNIQUE (id_prova, id_equipe),
    CONSTRAINT chk_inscricao_xor CHECK (
        (id_atleta IS NOT NULL AND id_equipe IS NULL) OR
        (id_atleta IS NULL AND id_equipe IS NOT NULL)
    ),
    CONSTRAINT chk_inscricao_status CHECK (status_inscricao IN ('Confirmada', 'Substituído por Lesão', 'Cancelada'))
);

-- ----------------------------------------------------------------------------
-- 9. Tabela RECINTO
-- ----------------------------------------------------------------------------

CREATE TABLE RECINTO (
    id_recinto INTEGER PRIMARY KEY AUTOINCREMENT,
    nome_recinto VARCHAR(100) NOT NULL UNIQUE,
    tipo_instalacao VARCHAR(30) NOT NULL,
    capacidade_publico INTEGER NOT NULL DEFAULT 1000,
    localizacao VARCHAR(150) NOT NULL,
    CONSTRAINT chk_recinto_tipo CHECK (tipo_instalacao IN ('Arena', 'Estádio', 'Pavilhão', 'Pista', 'Centro Aquático')),
    CONSTRAINT chk_recinto_capacidade CHECK(capacidade_publico > 0)
);

-- ----------------------------------------------------------------------------
-- 10. Tabela EVENTO
-- ----------------------------------------------------------------------------

CREATE TABLE EVENTO (
    id_evento INTEGER PRIMARY KEY AUTOINCREMENT,
    id_prova INTEGER NOT NULL,
    id_recinto INTEGER NOT NULL,
    fase VARCHAR(20) NOT NULL,
    data_evento DATE NOT NULL,
    horario_inicio TIME NOT NULL,
    horario_termino TIME NOT NULL,
    status_evento VARCHAR(20) NOT NULL DEFAULT 'Agendado',
    CONSTRAINT fk_evento_prova FOREIGN KEY (id_prova)
        REFERENCES PROVA(id_prova) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_evento_recinto FOREIGN KEY (id_recinto)
        REFERENCES RECINTO(id_recinto) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT uq_evento_recinto_horario UNIQUE (id_recinto, data_evento, horario_inicio),
    CONSTRAINT chk_evento_fase CHECK (fase IN ('Eliminatória', 'Oitavas', 'Quartas', 'Semifinal', 'Final')),
    CONSTRAINT chk_evento_status CHECK (status_evento IN ('Agendado', 'Em Andamento', 'Concluído', 'Cancelado')),
    CONSTRAINT chk_evento_intervalo CHECK (horario_termino > horario_inicio)
);

-- ----------------------------------------------------------------------------
-- 11. Tabela ARBITRO
-- ----------------------------------------------------------------------------

CREATE TABLE ARBITRO (
    id_arbitro INTEGER PRIMARY KEY AUTOINCREMENT,
    nacionalidade_coi CHAR(3) NOT NULL,
    id_modalidade INTEGER NOT NULL,
    nome VARCHAR(120) NOT NULL,
    nivel_certificacao VARCHAR(30) NOT NULL DEFAULT 'Internacional',
    CONSTRAINT fk_arbitro_nacionalidade FOREIGN KEY (nacionalidade_coi)
        REFERENCES PAIS(sigla_coi) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_arbitro_modalidade FOREIGN KEY (id_modalidade)
        REFERENCES MODALIDADE(id_modalidade) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_arbitro_certificacao CHECK (nivel_certificacao IN ('Nacional', 'Continental', 'Internacional'))
);

-- ----------------------------------------------------------------------------
-- 12. Tabela Associativa ESCALA_ARBITRAGEM
-- ----------------------------------------------------------------------------

CREATE TABLE ESCALA_ARBITRAGEM (
    id_evento INTEGER NOT NULL,
    id_arbitro INTEGER NOT NULL,
    funcao_no_evento VARCHAR(30) NOT NULL DEFAULT 'Árbitro Principal',
    PRIMARY KEY (id_evento, id_arbitro),
    CONSTRAINT fk_arbitragem_evento FOREIGN KEY (id_evento)
        REFERENCES EVENTO(id_evento) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_arbitragem_arbitro FOREIGN KEY (id_arbitro)
        REFERENCES ARBITRO(id_arbitro) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_arbitragem_funcao CHECK (funcao_no_evento IN ('Árbitro Principal', 'Árbitro Assistente', 'Juiz de Linha', 'Cronometrista', 'Chefe de Arbitragem'))
);

-- ----------------------------------------------------------------------------
-- 13. Tabela RESULTADO
-- ----------------------------------------------------------------------------

CREATE TABLE RESULTADO (
    id_resultado INTEGER PRIMARY KEY AUTOINCREMENT,
    id_evento INTEGER NOT NULL,
    id_inscricao INTEGER NOT NULL,
    marca_tempo_placar VARCHAR(40),
    colocacao INTEGER,
    indicador_wo CHAR(3) NOT NULL DEFAULT 'Não',
    status_doping VARCHAR(25) NOT NULL DEFAULT 'Limpo',
    status_homologacao VARCHAR(20) NOT NULL DEFAULT 'Pendente',
    medalha_atribuida VARCHAR(15) NOT NULL DEFAULT 'Nenhuma',
    pontos_gerados INTEGER NOT NULL DEFAULT 0,
    CONSTRAINT fk_resultado_evento FOREIGN KEY (id_evento)
        REFERENCES EVENTO(id_evento) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_resultado_inscricao FOREIGN KEY (id_inscricao)
        REFERENCES INSCRICAO(id_inscricao) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT uq_resultado_evento_inscricao UNIQUE (id_evento, id_inscricao),
    CONSTRAINT chk_resultado_colocacao CHECK (colocacao IS NULL OR colocacao >= 1),
    CONSTRAINT chk_resultado_wo CHECK (indicador_wo IN ('Sim', 'Não')),
    CONSTRAINT chk_resultado_doping CHECK (status_doping IN ('Limpo', 'Sob Investigação', 'Positivo/Anulado')),
    CONSTRAINT chk_resultado_homogolacao CHECK (status_homologacao IN ('Pendente', 'Homologado', 'Rejeitado')),
    CONSTRAINT chk_resultado_medalha CHECK (medalha_atribuida IN ('Ouro', 'Prata', 'Bronze', 'Nenhuma')),
    CONSTRAINT chk_resultado_pontos CHECK (pontos_gerados BETWEEN 0 AND 10),
    CONSTRAINT chk_regra_wo CHECK (
        (indicador_wo = 'Não') OR
        (indicador_wo = 'Sim' AND colocacao IS NULL AND medalha_atribuida = 'Nenhuma' AND pontos_gerados = 0)
    ),
    CONSTRAINT chk_regra_doping CHECK (
        (status_doping <> 'Positivo/Anulado') OR
        (status_doping = 'Positivo/Anulado' AND colocacao IS NULL AND medalha_atribuida = 'Nenhuma' AND pontos_gerados = 0)
    )
);

-- ----------------------------------------------------------------------------
-- 14. Tabela Associativa HOMOLOGACAO_RESULTADO
-- ----------------------------------------------------------------------------

CREATE TABLE HOMOLOGACAO_RESULTADO (
    id_resultado INTEGER NOT NULL,
    id_arbitro INTEGER NOT NULL,
    data_hora_confirmacao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    assinatura_validacao VARCHAR(100) NOT NULL,
    PRIMARY KEY (id_resultado, id_arbitro),
    CONSTRAINT fk_homologacao_resultado FOREIGN KEY(id_resultado)
        REFERENCES RESULTADO(id_resultado) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_homologacao_arbitro FOREIGN KEY(id_arbitro)
        REFERENCES ARBITRO(id_arbitro) ON DELETE RESTRICT ON UPDATE CASCADE,
);

-- ----------------------------------------------------------------------------
-- 15. Tabela QUADRO_MEDALHAS
-- ----------------------------------------------------------------------------

CREATE TABLE QUADRO_MEDALHAS (
    id_quadro INTEGER PRIMARY KEY AUTOINCREMENT,
    sigla_coi CHAR(3) NOT NULL UNIQUE,
    total_ouros INTEGER NOT NULL DEFAULT 0,
    total_pratas INTEGER NOT NULL DEFAULT 0,
    total_bronzes INTEGER NOT NULL DEFAULT 0,
    pontuacao_acumulada INTEGER NOT NULL DEFAULT 0,
    posicao_ranking INTEGER NOT NULL DEFAULT 1,
    CONSTRAINT fk_quadro_pais FOREIGN KEY(sigla_coi)
        REFERENCES PAIS(sigla_coi) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_quadro_ouros CHECK (total_ouros >= 0),
    CONSTRAINT chk_quadro_pratas CHECK (total_pratas >= 0),
    CONSTRAINT chk_quadro_bronzes CHECK (total_bronzes >= 0),
    CONSTRAINT chk_quadro_pontos CHECK (pontuacao_acumulada >= 0),
    CONSTRAINT chk_quadro_posicao CHECK (posicao_ranking >= 1)
);

-- ============================================================================
-- TRIGGERS TRANSACIONAIS
-- ============================================================================

-- Trigger: Homogeneidade Nacional da Equipe (atleta deve ser da mesma delegação da equipe)

CREATE TRIGGER trg_homogeneidade_equipe
BEFORE INSERT ON COMPOSICAO_EQUIPE
FOR EACH ROW
BEGIN
    SELECT CASE
        WHEN (SELECT id_delegacao FROM ATLETA WHERE id_atleta = NEW.id_atleta) !=
             (SELECT id_delegacao FROM EQUIPE WHERE id_equipe = NEW.id_equipe)
        THEN RAISE(ABORT, 'Violação: Atleta deve pertencer à mesma delegação/país da equipe.')
    END;
END;

-- Trigger: Impedimento de Conflito/Sobreposição de Horário no mesmo Recinto

CREATE TRIGGER trg_conflito_recinto
BEFORE INSERT ON EVENTO
FOR EACH ROW
BEGIN
    SELECT CASE
        WHEN EXISTS (
            SELECT 1 FROM EVENTO
            WHERE id_recinto = NEW.id_recinto
              AND data_evento = NEW.data_evento
              AND status_evento != 'Cancelado'
              AND (NEW.horario_inicio < horario_termino AND NEW.horario_termino > horario_inicio)
        )
        THEN RAISE(ABORT, 'Violação: Conflito de horário para o mesmo recinto esportivo.')
    END;
END;

-- Trigger: Dupla Validação de Resultados (homologa automaticamente ao atingir 2 árbitros)

CREATE TRIGGER trg_dupla_homologacao
AFTER INSERT ON HOMOLOGACAO_RESULTADO
FOR EACH ROW
BEGIN
    UPDATE RESULTADO
    SET status_homologacao = 'Homologado'
    WHERE id_resultado = NEW.id_resultado
      AND (SELECT COUNT(DISTINCT id_arbitro) FROM HOMOLOGACAO_RESULTADO WHERE id_resultado = NEW.id_resultado) >= 2;
END;

-- Trigger: Medalhas restritas apenas a eventos da Fase Final

CREATE TRIGGER trg_medalha_fase_final
BEFORE INSERT ON RESULTADO
FOR EACH ROW
WHEN NEW.medalha_atribuida != 'Nenhuma'
BEGIN
    SELECT CASE
        WHEN (SELECT fase FROM EVENTO WHERE id_evento = NEW.id_evento) != 'Final'
        THEN RAISE(ABORT, 'Violação RN12: Medalhas só podem ser atribuídas na fase Final.')
    END;
END;