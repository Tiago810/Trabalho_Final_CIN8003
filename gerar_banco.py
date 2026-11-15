import sqlite3
from pathlib import Path

DB_NAME = "jogos_poliesportivos.db"
DDL_FILE = "script_ddl.sql"
DML_FILE = "script_dml.sql"


def construir_banco():
    db_path = Path(DB_NAME)
    if db_path.exists():
        db_path.unlink()

    conexao = sqlite3.connect(DB_NAME)
    cursor = conexao.cursor()
    cursor.execute("PRAGMA foreign_keys = ON;")

    with open(DDL_FILE, "r", encoding="utf-8") as f_ddl:
        cursor.executescript(f_ddl.read())
    print(f"[OK] Estrutura física criada com sucesso a partir de '{DDL_FILE}'.")

    with open(DML_FILE, "r", encoding="utf-8") as f_dml:
        cursor.executescript(f_dml.read())
    print(f"[OK] Dados inseridos com sucesso a partir de '{DML_FILE}'.")

    conexao.commit()

    # Consulta de validação da RN16 (Quadro Geral de Medalhas)
    print("\n--- QUADRO GERAL DE MEDALHAS HOMOLOGADO (RN16) ---")
    consulta_quadro = """
        SELECT q.posicao_ranking, q.sigla_coi, p.nome_oficial,
               q.total_ouros, q.total_pratas, q.total_bronzes, q.pontuacao_acumulada
        FROM QUADRO_MEDALHAS q
        JOIN PAIS p ON p.sigla_coi = q.sigla_coi
        ORDER BY q.total_ouros DESC, q.total_pratas DESC, q.total_bronzes DESC, q.sigla_coi ASC;
    """
    for linha in cursor.execute(consulta_quadro):
        pos, coi, nome, ouros, pratas, bronzes, pts = linha
        print(f"{pos}º | {coi} ({nome:<32}) | O:{ouros} P:{pratas} B:{bronzes} | Pontos: {pts}")

    conexao.close()
    print(f"\n[CONCLUÍDO] Arquivo '{DB_NAME}' gerado e pronto para o GitHub!")


if __name__ == "__main__":
    construir_banco()