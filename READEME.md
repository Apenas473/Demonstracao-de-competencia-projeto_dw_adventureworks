# Projeto Final - Data Warehouse com Apache Airflow e PostgreSQL

## Descrição

Este projeto implementa um processo de ETL (Extract, Transform and Load) utilizando Apache Airflow e PostgreSQL para realizar a carga de dados de um banco OLTP para um Data Warehouse modelado em Star Schema.

O processo é executado de forma incremental, evitando a duplicação de registros na tabela fato e permitindo a atualização contínua do Data Warehouse.

---

# Tecnologias Utilizadas

* Python 3
* Apache Airflow 2.10.2
* PostgreSQL 16
* Docker
* Docker Compose

# Modelo Dimensional

## Dimensões

* dim_tempo
* dim_produto
* dim_cliente
* dim_vendedor
* dim_territorio

## Tabela Fato

* fato_vendas

# KPIs Implementados

* Receita Total
* Quantidade Vendida
* Ticket Médio
* Lucro Total
* Total de Pedidos
* Valor Médio por Item
* Custo Total
* Lucro Médio
* Produtos Vendidos
* Receita por Produto

# Como executar o projeto

## 1. Subir os containers

```bash
docker compose up -d
```

## 2. Executar o ETL

```bash
docker exec -it airflow_webserver airflow tasks test etl_oltp_to_dw load_dw 2026-06-28
```

## 3. Consultar os KPIs

Exemplo:

```sql
SELECT * FROM dw_vendas.kpi_receita_total;

SELECT * FROM dw_vendas.kpi_quantidade;

SELECT * FROM dw_vendas.kpi_ticket_medio;

SELECT * FROM dw_vendas.kpi_lucro_total;
```

---

# Resultado Obtido

Após a execução do ETL, os dados do banco OLTP são carregados para o Data Warehouse, preenchendo as dimensões e a tabela fato. Em seguida, os KPIs são disponibilizados através de Views SQL para análise dos dados de vendas.

O processo foi desenvolvido utilizando carga incremental, impedindo a duplicação de registros quando executado novamente.

---

# Autor

Alessandro Santos

Projeto desenvolvido como trabalho da disciplina de Data Warehouse utilizando PostgreSQL, Apache Airflow e Docker.
