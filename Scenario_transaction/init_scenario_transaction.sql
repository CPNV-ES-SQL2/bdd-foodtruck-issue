/**************************************************************************
 * GIVEN (préparation commune aux deux sessions)
 **************************************************************************/

DROP DATABASE IF EXISTS bank;
CREATE DATABASE bank;
USE bank;

/*-- Tables
DROP TABLE IF EXISTS transfers;
DROP TABLE IF EXISTS users;
*/
CREATE TABLE users (
    id      INT PRIMARY KEY,
    name    VARCHAR(100)   NOT NULL,
    balance DECIMAL(10,2)  NOT NULL
) ENGINE=InnoDB;

CREATE TABLE transfers (
    id           INT AUTO_INCREMENT PRIMARY KEY,
    from_user_id INT NOT NULL,
    to_user_id   INT NOT NULL,
    amount       DECIMAL(10,2) NOT NULL,
    status       ENUM('PENDING', 'COMPLETED', 'FAILED') NOT NULL,
    CONSTRAINT fk_transfers_from
    FOREIGN KEY (from_user_id) REFERENCES users(id),
    CONSTRAINT fk_transfers_to
    FOREIGN KEY (to_user_id)   REFERENCES users(id)
) ENGINE=InnoDB;

-- Données de départ : Mark et Brigitte
INSERT INTO users (id, name, balance) VALUES
    (1, 'Mark',     100.00),
    (2, 'Brigitte', 125.00);

-- Aucun transfert n’existe encore
-- (la table vient d’être créée => vide, mais on peut contrôler)
SELECT * FROM transfers;
-- Résultat attendu : 0 ligne

SELECT id, name, balance FROM users;

-- Vérification de la somme totale des soldes (225 CHF)
SELECT SUM(balance) AS total_balance
FROM users
WHERE name IN ('Mark', 'Brigitte');
-- Résultat attendu : 225.00
