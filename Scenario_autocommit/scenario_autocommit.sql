/**************************************************************************
 * GIVEN
 * Exécuter init_scenario_autocommit.sql
 * mysql --force=0 --show-warnings -h localhost -u julienschneider < init_scenario_autocommit.sql

SESSION 1
 * mysql -h localhost -u julienschneider

SESSION 2
 * mysql -h localhost -p -u monuser
 **************************************************************************/

SELECT @@autocommit;


-- SESSION 1 (conseiller) : autocommit désactivé
-- À exécuter dans le client / terminal de la session 1
SET autocommit = 0;

SELECT @@autocommit;


-- SESSION 2 (autre utilisateur) : autocommit activé
-- À exécuter dans un autre client / terminal (session 2)
SELECT @@autocommit;

SET autocommit = 1;

/**************************************************************************
 * WHEN
 **************************************************************************/

-- ======================================================================
-- SESSION 1 (conseiller, mode brouillon)
-- ======================================================================

USE bank;

SELECT id, name  FROM customers;
SELECT id, customer_id, status, limit_amount FROM cards;

-- Augmenter le plafond d’Alice de 2000 CHF à 5000 CHF (NON commit)
UPDATE cards
SET limit_amount = 5000.00
WHERE customer_id = 1;

-- Consulter la carte d’Alice en session 1
SELECT id, customer_id, status, limit_amount
FROM cards
WHERE customer_id = 1;
-- Résultat attendu AVANT ROLLBACK en SESSION 1 :
-- limit_amount = 5000.00, status = 'active'


-- ======================================================================
-- SESSION 2 (autre utilisateur)
-- ======================================================================

-- Consulter la carte d’Alice en session 2
SELECT id, customer_id, status, limit_amount
FROM cards
WHERE customer_id = 1;
-- Résultat attendu AVANT ROLLBACK en SESSION 2 :
-- limit_amount = 2000.00, status = 'active'
-- (la modification non commit de la session 1 n’est pas visible)


-- ======================================================================
-- SESSION 1
-- ======================================================================

-- Le conseiller décide de ne pas garder la modification
ROLLBACK;

-- Consulter à nouveau la carte en session 1
SELECT id, customer_id, status, limit_amount
FROM cards
WHERE customer_id = 1;
-- Résultat attendu APRÈS ROLLBACK en SESSION 1 :
-- limit_amount = 2000.00, status = 'active'


-- ======================================================================
-- SESSION 2
-- ======================================================================

-- Consulter à nouveau la carte d’Alice en session 2
SELECT id, customer_id, status, limit_amount
FROM cards
WHERE customer_id = 1;
-- Résultat attendu APRÈS ROLLBACK en SESSION 2 :
-- limit_amount = 2000.00, status = 'active'



/**************************************************************************
 * THEN (récapitulé en commentaires)
 *
 * AVANT le ROLLBACK :
 *  - Session 1 : voit limit_amount = 5000
 *  - Session 2 : voit limit_amount = 2000
 *
 * APRÈS le ROLLBACK en session 1 :
 *  - Session 1 : revient à limit_amount = 2000, status = 'active'
 *  - Session 2 : toujours limit_amount = 2000, status = 'active'
 *
 * → Le test de plafond à 5000 CHF ne laisse aucune trace en base.
 **************************************************************************/
