-- scenario_session1.sql
-- Session 1 (S1) - TP Transactions MySQL
USE tp1;
SET autocommit = 0;

-- =========================
-- SCENARIO 1 : Atomicité
-- =========================
START TRANSACTION;

INSERT INTO transaction_tp5 VALUES ('T1', 100, NULL);
INSERT INTO transaction_tp5 VALUES ('T2', 200, NULL);
INSERT INTO transaction_tp5 VALUES ('T3', 300, NULL);

SELECT * FROM transaction_tp5;

UPDATE transaction_tp5
SET valTransaction = 250
WHERE idTransaction = 'T2';

DELETE FROM transaction_tp5
WHERE idTransaction = 'T3';

SELECT * FROM transaction_tp5;

-- Test annulation
ROLLBACK;

SELECT * FROM transaction_tp5;

-- Nouvelle transaction validée
START TRANSACTION;

INSERT INTO transaction_tp5 VALUES ('T4', 400, NULL);
INSERT INTO transaction_tp5 VALUES ('T5', 500, NULL);

SELECT * FROM transaction_tp5;

COMMIT;

SELECT * FROM transaction_tp5;

-- =========================
-- SCENARIO 2 : Concurrence
-- =========================
-- Réservation de 2 places par C1
START TRANSACTION;

UPDATE client_tp5
SET nbrPlacesReserveesClient = 2
WHERE idClient = 'C1';

UPDATE vol_tp5
SET nbrPlacesReserveesVol = nbrPlacesReserveesVol + 2
WHERE idVol = 'V1';

SELECT * FROM client_tp5;
SELECT * FROM vol_tp5;

COMMIT;

SELECT * FROM client_tp5;
SELECT * FROM vol_tp5;
