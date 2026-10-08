-- Kasus: total premi asuransi yang masih aktif per order
-- Pertanyaan bisnis: pada hari sebuah order mulai, berapa total premi
-- milik user yang sama yang masih berlaku? Tandai TRUE kalau >= 300.000
-- Teknik: self join, GROUP BY, CASE WHEN

-- 1. Data contoh (dummy)
CREATE TABLE INSURANCE_ORDERS (
  date_start TEXT,
  date_end   TEXT,
  user_id    INT,
  order_rank INT,
  premium    INT
);

INSERT INTO INSURANCE_ORDERS VALUES
  ('2023-01-01', '2023-09-01', 1, 1, 200000),
  ('2023-08-01', '2023-10-01', 1, 2, 150000),
  ('2023-09-02', '2023-12-01', 1, 3, 100000);

-- 2. Query
SELECT a.date_start, a.date_end, a.user_id, a.order_rank, a.premium,
       SUM(b.premium) AS active_premium,
       CASE WHEN SUM(b.premium) >= 300000 THEN 'TRUE' ELSE 'FALSE' END AS flag
FROM INSURANCE_ORDERS a
JOIN INSURANCE_ORDERS b
  ON  b.user_id    = a.user_id        -- user yang sama
  AND b.order_rank <= a.order_rank    -- order sebelumnya + order ini
  AND b.date_end   >= a.date_start    -- masih aktif saat order ini mulai
GROUP BY a.user_id, a.order_rank, a.date_start, a.date_end, a.premium
ORDER BY a.user_id, a.order_rank;

-- Hasil yang diharapkan:
-- rank 1 = 200.000 (FALSE), rank 2 = 350.000 (TRUE), rank 3 = 250.000 (FALSE)
