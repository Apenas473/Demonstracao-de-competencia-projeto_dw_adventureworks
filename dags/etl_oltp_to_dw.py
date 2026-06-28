from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime
import psycopg2


def etl():

    conn = psycopg2.connect(
        host="postgres",
        database="dw_adventureworks",
        user="postgres",
        password="dw123456",
        port=5432
    )

    cur = conn.cursor()

    # ==========================
    # DIM PRODUTO
    # ==========================

    cur.execute("""
        INSERT INTO dw_vendas.dim_produto
            (produto_id, nome, custo, preco)

        SELECT
            productid,
            name,
            standardcost,
            listprice
        FROM oltp.product
        ON CONFLICT (produto_id) DO NOTHING;
    """)

    # ==========================
    # DIM CLIENTE
    # ==========================

    cur.execute("""
        INSERT INTO dw_vendas.dim_cliente
            (cliente_id, nome, email)

        SELECT
            customerid,
            name,
            email
        FROM oltp.customer
        ON CONFLICT (cliente_id) DO NOTHING;
    """)

    # ==========================
    # DIM VENDEDOR
    # ==========================

    cur.execute("""
        INSERT INTO dw_vendas.dim_vendedor
            (vendedor_id)

        SELECT DISTINCT
            salespersonid
        FROM oltp.salesorderheader
        WHERE salespersonid IS NOT NULL
        ON CONFLICT (vendedor_id) DO NOTHING;
    """)

    # ==========================
    # DIM TERRITÓRIO
    # ==========================

    cur.execute("""
        INSERT INTO dw_vendas.dim_territorio
            (territorio_id, nome)

        SELECT DISTINCT
            territoryid,
            'Território ' || territoryid
        FROM oltp.salesorderheader
        WHERE territoryid IS NOT NULL
        ON CONFLICT (territorio_id) DO NOTHING;
    """)

    # ==========================
    # DIM TEMPO
    # ==========================

    cur.execute("""
        INSERT INTO dw_vendas.dim_tempo
        (
            data_completa,
            dia,
            mes,
            nome_mes,
            trimestre,
            ano,
            dia_semana
        )

        SELECT DISTINCT

            DATE(orderdate),

            EXTRACT(DAY FROM orderdate),

            EXTRACT(MONTH FROM orderdate),

            TO_CHAR(orderdate,'Month'),

            EXTRACT(QUARTER FROM orderdate),

            EXTRACT(YEAR FROM orderdate),

            EXTRACT(DOW FROM orderdate)

        FROM oltp.salesorderheader

        ON CONFLICT (data_completa) DO NOTHING;
    """)

    # ==========================
    # FATO
    # ==========================

    cur.execute("""
        INSERT INTO dw_vendas.fato_vendas
        (
            data_sk,
            produto_sk,
            cliente_sk,
            vendedor_sk,
            territorio_sk,
            order_id,
            quantidade,
            valor_unitario,
            valor_total,
            custo_total,
            lucro
        )

        SELECT

            dt.data_sk,

            dp.produto_sk,

            dc.cliente_sk,

            dv.vendedor_sk,

            dter.territorio_sk,

            h.salesorderid,

            d.orderqty,

            d.unitprice,

            d.linetotal,

            d.orderqty * dp.custo,

            d.linetotal - (d.orderqty * dp.custo)

        FROM oltp.salesorderdetail d

        JOIN oltp.salesorderheader h
            ON h.salesorderid = d.salesorderid

        JOIN dw_vendas.dim_produto dp
            ON dp.produto_id = d.productid

        JOIN dw_vendas.dim_cliente dc
            ON dc.cliente_id = h.customerid

        JOIN dw_vendas.dim_vendedor dv
            ON dv.vendedor_id = h.salespersonid

        JOIN dw_vendas.dim_territorio dter
            ON dter.territorio_id = h.territoryid

        JOIN dw_vendas.dim_tempo dt
            ON dt.data_completa = DATE(h.orderdate)

        WHERE NOT EXISTS (

            SELECT 1

            FROM dw_vendas.fato_vendas f

            WHERE f.order_id = h.salesorderid
              AND f.produto_sk = dp.produto_sk

        );
    """)

    conn.commit()
    cur.close()
    conn.close()


with DAG(
    dag_id="etl_oltp_to_dw",
    start_date=datetime(2024, 1, 1),
    catchup=False,
    schedule=None
) as dag:

    PythonOperator(
        task_id="load_dw",
        python_callable=etl
    )