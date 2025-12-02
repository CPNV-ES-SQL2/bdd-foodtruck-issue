/**************************************************************************
 * GIVEN
 * Exécuter init_scenario_implicit_commit.sql
 * mysql --force=0 --show-warnings -h localhost -u julienschneider < init_scenario_implicit_commit.sql

SESSION 1
 * mysql -h localhost -u julienschneider

SESSION 2
 * mysql -h localhost -u julienschneider
 **************************************************************************/

-- SESSION 1 (autocommit désactivé)
-- À exécuter dans le client / terminal de la session 1
USE bank;
SET autocommit = 1;
SELECT @@autocommit;  -- attendu : 0

-- SESSION 2 (autocommit activé)
-- À exécuter dans le client / terminal de la session 2
USE bank;
SET autocommit = 1;
SELECT @@autocommit;  -- attendu : 1

SELECT * FROM transfers;
-- Résultat attendu : 0 ligne

SELECT id, name, balance FROM users;

-- Vérification de la somme totale des soldes (225 CHF)
SELECT SUM(balance) AS total_balance
FROM users
WHERE name IN ('Bernard', 'Alfred');


/**************************************************************************
 * WHEN
 **************************************************************************/

-- ======================================================================
-- SESSION 1 : enregistrement du transfert + mise à jour des soldes
-- ======================================================================

-- Démarrer explicitement une transaction
START TRANSACTION;
-- 1) Enregistrer un nouveau transfert PENDING (Alfred -> Bernard, 50 CHF)
INSERT INTO transfers (from_user_id, to_user_id, amount, status)
VALUES (2, 1, 50.00, 'PENDING');

-- 2) Mettre à jour les soldes dans users
UPDATE users
SET balance = balance - 50.00
WHERE id = 2;   -- Alfred

UPDATE users
SET balance = balance + 50.00
WHERE id = 1;   -- Bernard

-- 3) Consulter les soldes (SESSION 1, avant CREATE TABLE)
SELECT id, name, balance
FROM users
WHERE id IN (1, 2)
ORDER BY id;
-- THEN attendu en SESSION 1 AVANT CREATE TABLE :
--   Bernard : 150.00
--   Alfred  :  75.00
--   Somme   : 225.00

--   Consulter le transfert créé
SELECT *
FROM transfers
WHERE from_user_id = 2 AND to_user_id = 1;
-- THEN attendu en SESSION 1 AVANT CREATE TABLE :
--   1 ligne : amount = 50.00, status = 'PENDING'



-- ======================================================================
-- SESSION 2 : lecture avant le CREATE TABLE (modifs non commitées)
-- ======================================================================

SELECT id, name, balance
FROM users
WHERE id IN (1, 2)
ORDER BY id;
-- THEN attendu en SESSION 2 AVANT CREATE TABLE :
--   Bernard : 100.00
--   Alfred  : 125.00
--   Somme   : 225.00

SELECT *
FROM transfers;
-- THEN attendu en SESSION 2 AVANT CREATE TABLE :
--   0 ligne (le transfert en cours n’est pas visible)



-- ======================================================================
-- SESSION 1 : CREATE TABLE contracts (DDL avec commit implicite)
-- ======================================================================

CREATE TABLE contracts (
                           id        INT AUTO_INCREMENT PRIMARY KEY,
                           title     VARCHAR(255) NOT NULL,
                           signed_at DATETIME NULL
) ENGINE=InnoDB;
-- Ici MySQL effectue un COMMIT implicite :
--   - les modifications sur users/transfers sont validées
--   - la table contracts est créée et visible par toutes les sessions



-- ======================================================================
-- SESSION 1 : après CREATE TABLE et avant ROLLBACK
-- ======================================================================

-- Liste des tables de la base bank
SHOW TABLES;
-- THEN attendu en SESSION 1 :
--   users, transfers, contracts

-- Soldes Bernard / Alfred
SELECT id, name, balance
FROM users
WHERE id IN (1, 2)
ORDER BY id;
-- THEN attendu en SESSION 1 APRÈS CREATE TABLE (commit implicite déjà fait) :
--   Bernard : 150.00
--   Alfred  :  75.00
--   Somme   : 225.00

-- Transferts
SELECT *
FROM transfers
WHERE from_user_id = 2 AND to_user_id = 1;
-- THEN attendu en SESSION 1 APRÈS CREATE TABLE :
--   1 ligne : amount = 50.00, status = 'PENDING'



-- ======================================================================
-- SESSION 2 : après CREATE TABLE et avant ROLLBACK
-- ======================================================================

SHOW TABLES;
-- THEN attendu en SESSION 2 :
--   users, transfers, contracts  (contracts est visible)

SELECT id, name, balance
FROM users
WHERE id IN (1, 2)
ORDER BY id;
-- THEN attendu en SESSION 2 APRÈS CREATE TABLE :
--   Bernard : 150.00
--   Alfred  :  75.00
--   Somme   : 225.00

SELECT *
FROM transfers
WHERE from_user_id = 2 AND to_user_id = 1;
-- THEN attendu en SESSION 2 APRÈS CREATE TABLE :
--   1 ligne : amount = 50.00, status = 'PENDING'



-- ======================================================================
-- SESSION 1 : tentative d’annulation avec ROLLBACK
-- ======================================================================

ROLLBACK;
-- Ce ROLLBACK n’annule PAS :
--   - les updates sur users
--   - l’insert dans transfers
--   - la création de contracts
-- car le CREATE TABLE a déjà provoqué un commit implicite.



-- ======================================================================
-- SESSION 1 : lecture après ROLLBACK
-- ======================================================================

SELECT id, name, balance
FROM users
WHERE id IN (1, 2)
ORDER BY id;
-- THEN attendu en SESSION 1 APRÈS ROLLBACK :
--   Bernard : 150.00
--   Alfred  :  75.00
--   Somme   : 225.00

SELECT *
FROM transfers
WHERE from_user_id = 2 AND to_user_id = 1;
-- THEN attendu en SESSION 1 APRÈS ROLLBACK :
--   1 ligne toujours présente (50.00, 'PENDING')

SHOW TABLES;
-- THEN attendu en SESSION 1 APRÈS ROLLBACK :
--   contracts existe toujours



-- ======================================================================
-- SESSION 2 : lecture après le ROLLBACK de la session 1
-- ======================================================================

SELECT id, name, balance
FROM users
WHERE id IN (1, 2)
ORDER BY id;
-- THEN attendu en SESSION 2 APRÈS ROLLBACK (mais déjà commit implicite) :
--   Bernard : 150.00
--   Alfred  :  75.00
--   Somme   : 225.00

SELECT *
FROM transfers
WHERE from_user_id = 2 AND to_user_id = 1;
-- THEN attendu en SESSION 2 APRÈS ROLLBACK :
--   1 ligne : amount = 50.00, status = 'PENDING'

SHOW TABLES;
-- THEN attendu en SESSION 2 APRÈS ROLLBACK :
--   contracts existe toujours



/**************************************************************************
 * RÉSUMÉ THEN (en commentaires)
 *
 * - Après le transfert et avant CREATE TABLE :
 *   - Session 1 : voit 150 / 75 et le transfert PENDING.
 *   - Session 2 : voit 100 / 125 et aucun transfert.
 *
 * - Après CREATE TABLE contracts (commit implicite) et avant ROLLBACK :
 *   - Session 1 & 2 :
 *       users     : 150 / 75
 *       transfers : transfert PENDING visible
 *       tables    : contracts existe
 *
 * - Après ROLLBACK en session 1 :
 *   - Session 1 & 2 :
 *       users     : toujours 150 / 75
 *       transfers : transfert toujours présent
 *       tables    : contracts toujours présent
 *   → Le ROLLBACK n’a rien annulé, car CREATE TABLE a déjà validé la transaction.
 **************************************************************************/
