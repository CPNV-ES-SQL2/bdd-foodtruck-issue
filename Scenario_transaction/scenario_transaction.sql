/**************************************************************************
 * GIVEN
 * Exécuter init_scenario_transactiom.sql
 * mysql --force=0 --show-warnings -h localhost -u julienschneider < init_scenario_transaction.sql

SESSION 1
 * mysql -h localhost -u julienschneider

SESSION 2
 * mysql -h localhost -u julienschneider
 **************************************************************************/

-- SESSION 1 (autocommit activé)
-- À exécuter dans le client / terminal de la session 1
SELECT @@autocommit;
SET autocommit = 1;

-- SESSION 2 (autocommit activé)
-- À exécuter dans le client / terminal de la session 2
SELECT @@autocommit;
SET autocommit = 1;

/**************************************************************************
 * WHEN
 **************************************************************************/

-- ======================================================================
-- SESSION 1 : démarrer la transaction et effectuer le transfert
-- ======================================================================

USE bank;

SELECT * FROM transfers;
-- Résultat attendu : 0 ligne

SELECT id, name, balance FROM users;

-- Vérification de la somme totale des soldes (225 CHF)
SELECT SUM(balance) AS total_balance
FROM users
WHERE name IN ('Mark', 'Brigitte');

-- Démarrer explicitement une transaction
START TRANSACTION;

-- Enregistrer un nouveau transfert dans `transfers`
-- Brigitte -> Mark, 50 CHF, status = 'PENDING'
INSERT INTO transfers (from_user_id, to_user_id, amount, status)
VALUES (2, 1, 50.00, 'PENDING');

-- Mettre à jour les soldes dans `users`
--   - Brigitte -50
--   - Mark +50
UPDATE users
SET balance = balance - 50.00
WHERE id = 2;  -- Brigitte

UPDATE users
SET balance = balance + 50.00
WHERE id = 1;  -- Mark

-- Consulter les soldes de Mark et Brigitte (SESSION 1, AVANT COMMIT)
SELECT id, name, balance
FROM users
WHERE id IN (1, 2)
ORDER BY id;
-- THEN attendu en SESSION 1 avant COMMIT :
--   Mark     : 150.00
--   Brigitte :  75.00
--   Somme    : 225.00

SELECT SUM(balance) AS total_balance
FROM users
WHERE name IN ('Mark', 'Brigitte');

SELECT *
FROM transfers
WHERE from_user_id = 2 AND to_user_id = 1;
-- THEN attendu en SESSION 1 avant COMMIT :
--   1 ligne avec amount = 50.00 et status = 'PENDING'


-- ======================================================================
-- SESSION 2 : lecture pendant que la transaction de la session 1 est ouverte
-- ======================================================================

-- Consulter les soldes de Mark et Brigitte (SESSION 2, AVANT COMMIT)
SELECT id, name, balance
FROM users
WHERE id IN (1, 2)
ORDER BY id;
-- THEN attendu en SESSION 2 avant COMMIT (lecture de l’état commité) :
--   Mark     : 100.00
--   Brigitte : 125.00
--   Somme    : 225.00

SELECT *
FROM transfers;
-- THEN attendu en SESSION 2 avant COMMIT :
--   0 ligne (le transfert en cours de transaction n’est pas encore visible)



-- ======================================================================
-- SESSION 1 : valider la transaction
-- ======================================================================

SELECT SUM(balance) AS total_balance
FROM users
WHERE name IN ('Mark', 'Brigitte');

COMMIT;



-- ======================================================================
-- SESSION 2 : nouvelle lecture après le COMMIT de la session 1
-- ======================================================================

-- Re-consulter les soldes de Mark et Brigitte
SELECT id, name, balance
FROM users
WHERE id IN (1, 2)
ORDER BY id;
-- THEN après COMMIT (SESSION 1 et 2) :
--   Mark     : 150.00
--   Brigitte :  75.00
--   Somme    : 225.00

SELECT *
FROM transfers
WHERE from_user_id = 2 AND to_user_id = 1;
-- THEN après COMMIT (SESSION 1 et 2) :
--   1 ligne visible :
--      from_user_id = 2 (Brigitte)
--      to_user_id   = 1 (Mark)
--      amount       = 50.00
--      status       = 'PENDING' (ou 'COMPLETED' si tu le mets à jour dans la même transaction)

SELECT SUM(balance) AS total_balance
FROM users
WHERE name IN ('Mark', 'Brigitte');
