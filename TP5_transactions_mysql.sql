-- TP Transactions - Version MySQL
-- Base : tp1
-- A lancer avec : source /Users/nourbenammar/Downloads/tp5_transactions_mysql.sql

USE tp1;

-- =========================
-- 0) Nettoyage
-- =========================
DROP TABLE IF EXISTS client_tp5;
DROP TABLE IF EXISTS vol_tp5;
DROP TABLE IF EXISTS transaction_tp5;

-- =========================
-- 1) Exercice 1 : atomicité
-- =========================

-- En MySQL, on n'utilise pas :
-- SET AUTOCOMMIT OFF;
-- mais :
SET autocommit = 0;

CREATE TABLE transaction_tp5 (
    idTransaction VARCHAR(44),
    valTransaction INT
);

SELECT * FROM transaction_tp5;

-- Insertion de données de test
INSERT INTO transaction_tp5 VALUES ('T1', 100);
INSERT INTO transaction_tp5 VALUES ('T2', 200);
INSERT INTO transaction_tp5 VALUES ('T3', 300);

SELECT * FROM transaction_tp5;

-- Modifications
UPDATE transaction_tp5
SET valTransaction = 250
WHERE idTransaction = 'T2';

DELETE FROM transaction_tp5
WHERE idTransaction = 'T3';

SELECT * FROM transaction_tp5;

-- Annulation
ROLLBACK;

SELECT * FROM transaction_tp5;

-- Nouvelle transaction
INSERT INTO transaction_tp5 VALUES ('T4', 400);
INSERT INTO transaction_tp5 VALUES ('T5', 500);

SELECT * FROM transaction_tp5;

-- Valider pour conserver les données
COMMIT;

SELECT * FROM transaction_tp5;

-- Test DDL + transaction
ALTER TABLE transaction_tp5
ADD COLUMN remarque VARCHAR(50);

-- En MySQL, ALTER TABLE provoque aussi un commit implicite.
SELECT * FROM transaction_tp5;

-- =========================
-- 2) Exercice 2 : concurrence
-- =========================

DROP TABLE IF EXISTS client_tp5;
DROP TABLE IF EXISTS vol_tp5;

CREATE TABLE vol_tp5 (
    idVol VARCHAR(44) PRIMARY KEY,
    capaciteVol INT,
    nbrPlacesReserveesVol INT
);

CREATE TABLE client_tp5 (
    idClient VARCHAR(44) PRIMARY KEY,
    prenomClient VARCHAR(20),
    nbrPlacesReserveesClient INT
);

INSERT INTO vol_tp5 VALUES ('V1', 200, 0);

INSERT INTO client_tp5 VALUES ('C1', 'Ali', 0);
INSERT INTO client_tp5 VALUES ('C2', 'Sara', 0);

SELECT * FROM vol_tp5;
SELECT * FROM client_tp5;

-- =========================
-- Scénario T1 (session 1)
-- =========================
-- Dans S1 :
-- SET autocommit = 0;
-- START TRANSACTION;
-- UPDATE client_tp5
-- SET nbrPlacesReserveesClient = 2
-- WHERE idClient = 'C1';
--
-- UPDATE vol_tp5
-- SET nbrPlacesReserveesVol = nbrPlacesReserveesVol + 2
-- WHERE idVol = 'V1';
--
-- SELECT * FROM client_tp5;
-- SELECT * FROM vol_tp5;
-- COMMIT;

-- =========================
-- Scénario T2 (session 2)
-- =========================
-- Dans S2 :
-- SET autocommit = 0;
-- START TRANSACTION;
-- UPDATE client_tp5
-- SET nbrPlacesReserveesClient = 3
-- WHERE idClient = 'C2';
--
-- UPDATE vol_tp5
-- SET nbrPlacesReserveesVol = nbrPlacesReserveesVol + 3
-- WHERE idVol = 'V1';
--
-- SELECT * FROM client_tp5;
-- SELECT * FROM vol_tp5;
-- COMMIT;

-- =========================
-- Vérification finale
-- =========================
SELECT * FROM client_tp5;
SELECT * FROM vol_tp5;

-- =========================
-- Remise à zéro pour nouveaux tests
-- =========================
UPDATE client_tp5
SET nbrPlacesReserveesClient = 0;

UPDATE vol_tp5
SET nbrPlacesReserveesVol = 0;

COMMIT;

SELECT * FROM client_tp5;
SELECT * FROM vol_tp5;

-- =========================
-- Isolation SERIALIZABLE
-- =========================
-- Dans chaque session, exécuter :
-- SET SESSION TRANSACTION ISOLATION LEVEL SERIALIZABLE;
-- START TRANSACTION;
