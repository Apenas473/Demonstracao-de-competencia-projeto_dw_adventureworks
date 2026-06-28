-- =========================
-- SCHEMA DO DATA WAREHOUSE
-- =========================
CREATE SCHEMA IF NOT EXISTS dw_vendas;

-- =========================
-- DIMENSÃO TEMPO
-- =========================
CREATE TABLE dw_vendas.dim_tempo (
    data_sk SERIAL PRIMARY KEY,
    data_completa DATE UNIQUE,
    dia INT,
    mes INT,
    nome_mes TEXT,
    trimestre INT,
    ano INT,
    dia_semana INT
);

-- =========================
-- DIMENSÃO PRODUTO
-- =========================
CREATE TABLE dw_vendas.dim_produto (
    produto_sk SERIAL PRIMARY KEY,
    produto_id INT UNIQUE,
    nome TEXT,
    custo NUMERIC,
    preco NUMERIC
);

-- =========================
-- DIMENSÃO CLIENTE
-- =========================
CREATE TABLE dw_vendas.dim_cliente (
    cliente_sk SERIAL PRIMARY KEY,
    cliente_id INT UNIQUE,
    nome TEXT,
    email TEXT
);

-- =========================
-- DIMENSÃO VENDEDOR
-- =========================
CREATE TABLE dw_vendas.dim_vendedor (
    vendedor_sk SERIAL PRIMARY KEY,
    vendedor_id INT UNIQUE
);

-- =========================
-- DIMENSÃO TERRITÓRIO
-- =========================
CREATE TABLE dw_vendas.dim_territorio (
    territorio_sk SERIAL PRIMARY KEY,
    territorio_id INT UNIQUE,
    nome TEXT
);

-- =========================
-- TABELA FATO VENDAS
-- =========================
CREATE TABLE dw_vendas.fato_vendas (
    fato_sk SERIAL PRIMARY KEY,

    data_sk INT,
    produto_sk INT,
    cliente_sk INT,
    vendedor_sk INT,
    territorio_sk INT,

    order_id INT,
    quantidade INT,
    valor_unitario NUMERIC,
    valor_total NUMERIC,
    custo_total NUMERIC,
    lucro NUMERIC
);

-- =========================
-- RELACIONAMENTOS (FK)
-- =========================
ALTER TABLE dw_vendas.fato_vendas
ADD FOREIGN KEY (data_sk) REFERENCES dw_vendas.dim_tempo(data_sk);

ALTER TABLE dw_vendas.fato_vendas
ADD FOREIGN KEY (produto_sk) REFERENCES dw_vendas.dim_produto(produto_sk);

ALTER TABLE dw_vendas.fato_vendas
ADD FOREIGN KEY (cliente_sk) REFERENCES dw_vendas.dim_cliente(cliente_sk);

-- =========================
-- KPIs (VIEWS)
-- =========================

-- Receita total
CREATE OR REPLACE VIEW dw_vendas.kpi_receita_total AS
SELECT SUM(valor_total) AS receita_total
FROM dw_vendas.fato_vendas;

-- Quantidade vendida
CREATE OR REPLACE VIEW dw_vendas.kpi_quantidade AS
SELECT SUM(quantidade) AS total_itens
FROM dw_vendas.fato_vendas;

-- Ticket médio
CREATE OR REPLACE VIEW dw_vendas.kpi_ticket_medio AS
SELECT
    SUM(valor_total) / NULLIF(COUNT(DISTINCT order_id), 0) AS ticket_medio
FROM dw_vendas.fato_vendas;

-- Lucro total
CREATE OR REPLACE VIEW dw_vendas.kpi_lucro_total AS
SELECT SUM(lucro) AS lucro_total
FROM dw_vendas.fato_vendas;

-- Total de pedidos
CREATE OR REPLACE VIEW dw_vendas.kpi_total_pedidos AS
SELECT COUNT(DISTINCT order_id) AS total_pedidos
FROM dw_vendas.fato_vendas;

-- Valor médio por item
CREATE OR REPLACE VIEW dw_vendas.kpi_valor_medio_item AS
SELECT AVG(valor_unitario) AS valor_medio_item
FROM dw_vendas.fato_vendas;

-- Custo total
CREATE OR REPLACE VIEW dw_vendas.kpi_custo_total AS
SELECT SUM(custo_total) AS custo_total
FROM dw_vendas.fato_vendas;

-- Lucro médio
CREATE OR REPLACE VIEW dw_vendas.kpi_lucro_medio AS
SELECT AVG(lucro) AS lucro_medio
FROM dw_vendas.fato_vendas;

-- Produtos vendidos
CREATE OR REPLACE VIEW dw_vendas.kpi_produtos_vendidos AS
SELECT COUNT(DISTINCT produto_sk) AS produtos_vendidos
FROM dw_vendas.fato_vendas;

-- Receita por produto
CREATE OR REPLACE VIEW dw_vendas.kpi_receita_produto AS
SELECT
    p.nome,
    SUM(f.valor_total) AS receita
FROM dw_vendas.fato_vendas f
JOIN dw_vendas.dim_produto p
ON p.produto_sk = f.produto_sk
GROUP BY p.nome;