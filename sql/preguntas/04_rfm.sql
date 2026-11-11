USE superstore_rafaela;
WITH ref AS (SELECT MAX(order_date) fecha FROM superstore_ventas),
rfm AS (
 SELECT customer_id, MAX(customer_name) customer_name,
 DATEDIFF(MAX(ref.fecha),MAX(v.order_date)) recency_dias,
 COUNT(DISTINCT order_id) frequency, SUM(sales) monetary
 FROM superstore_ventas v CROSS JOIN ref GROUP BY customer_id
), s AS (
 SELECT *, NTILE(5) OVER(ORDER BY recency_dias DESC, customer_id) r_score,
 NTILE(5) OVER(ORDER BY frequency ASC, customer_id) f_score,
 NTILE(5) OVER(ORDER BY monetary ASC, customer_id) m_score FROM rfm
)
SELECT customer_id, customer_name, recency_dias, frequency, ROUND(monetary,2) monetary,
 r_score, f_score, m_score,
 CONCAT(CAST(r_score AS STRING),CAST(f_score AS STRING),CAST(m_score AS STRING)) rfm_score,
 CASE WHEN r_score>=4 AND f_score>=4 AND m_score>=4 THEN 'alto_valor'
 WHEN f_score>=4 AND r_score>=3 THEN 'recurrente'
 WHEN r_score<=2 AND (f_score>=3 OR m_score>=3) THEN 'en_riesgo'
 ELSE 'otros' END segmento
FROM s ORDER BY monetary DESC;
