-- scenario_session2.sql
-- Session 2 (S2) - TP Transactions MySQL
USE tp1;
SET autocommit = 0;

-- =========================
-- SCENARIO 1 : Observation depuis S2
-- =========================
SELECT * FROM transaction_tp5;

-- Après les opérations de S1 non validées,
-- tu peux relancer ce SELECT pour vérifier ce qui est visible.
SELECT * FROM transaction_tp5;

-- =========================
-- SCENARIO 2 : Concurrence
-- =========================
-- Réservation de 3 places par C2
START TRANSACTION;

UPDATE client_tp5
SET nbrPlacesReserveesClient = 3
WHERE idClient = 'C2';

UPDATE vol_tp5
SET nbrPlacesReserveesVol = nbrPlacesReserveesVol + 3
WHERE idVol = 'V1';

SELECT * FROM client_tp5;
SELECT * FROM vol_tp5;

COMMIT;

SELECT * FROM client_tp5;
SELECT * FROM vol_tp5;

-- =========================
-- Variante SERIALIZABLE
-- =========================
-- À tester séparément si demandé :
-- SET SESSION TRANSACTION ISOLATION LEVEL SERIALIZABLE;
-- START TRANSACTION;
-- UPDATE client_tp5
-- SET nbrPlacesReserveesClient = 3
-- WHERE idClient = 'C2';
-- UPDATE vol_tp5
-- SET nbrPlacesReserveesVol = nbrPlacesReserveesVol + 3
-- WHERE idVol = 'V1';
-- COMMIT;
