conn = sqlite3.connect("clinica.db")

-- Top serviços por faturamento
q1 = """
SELECT 
    servico,
    COUNT(*) AS total_atendimentos,
    ROUND(SUM(valor_R$), 2) AS faturamento_total,
    ROUND(AVG(valor_R$), 2) AS ticket_medio
FROM atendimentos
WHERE status = 'Realizado'
GROUP BY servico
ORDER BY faturamento_total DESC
"""

-- Taxa de cancelamento por profissional
q2 = """
SELECT
    profissional,
    COUNT(*) AS total_agendamentos,
    SUM(CASE WHEN status = 'Realizado' THEN 1 ELSE 0 END) AS realizados,
    ROUND(
        100.0 * SUM(CASE WHEN status != 'Realizado' THEN 1 ELSE 0 END) / COUNT(*), 1
    ) AS taxa_cancelamento_pct
FROM atendimentos
GROUP BY profissional
ORDER BY taxa_cancelamento_pct DESC
"""

-- Receita por mês
q3 = """
SELECT mes, ROUND(SUM(valor_R$), 2) AS receita
FROM atendimentos
WHERE status = 'Realizado'
GROUP BY mes
ORDER BY mes
"""

for nome, query in [("Top Serviços", q1), ("Cancelamentos", q2), ("Receita Mensal", q3)]:
    print(f"\n=== {nome} ===")
    print(pd.read_sql(query, conn).to_string(index=False))

conn.close()