# Commande `SHOW PROCESSLIST;`
```mysql
+----+-----------------+-----------+------+---------+------+----------+------------------+----------+
| Id | User            | Host      | db   | Command | Time | State    | Info             | Progress |
+----+-----------------+-----------+------+---------+------+----------+------------------+----------+
| 44 | julienschneider | localhost | NULL | Query   |    0 | starting | SHOW PROCESSLIST |    0.000 |
+----+-----------------+-----------+------+---------+------+----------+------------------+----------+
```
## Id (CONNECTION_ID)
Identifiant unique de la session côté serveur. Sert à faire le lien avec d’autres vues (transactions, verrous) et à terminer une session via KILL id;.

## User
Compte MySQL/MariaDB utilisé pour la connexion. Permet d’identifier qui exécute les requêtes et d’analyser le comportement par utilisateur.

## Host
Origine de la connexion (hôte, IP, éventuellement port). Utile pour repérer quelles machines ou applications génèrent du trafic vers le serveur.

## db
Base de données courante de la session (résultat implicite de USE <db>). Indique sur quel schéma les requêtes vont s’exécuter par défaut.

## Command
Type d’activité en cours pour la session (Sleep, Query, Connect, etc.). Permet de distinguer les connexions inactives des requêtes réellement en cours d’exécution.

## Time
Durée (en secondes) depuis que la session est dans son état actuel. Sert à repérer les requêtes longues (Command='Query') ou les connexions dormantes depuis trop longtemps (Command='Sleep').

## State
Sous-état plus précis de la commande (starting, Sending data, Waiting for table metadata lock, etc.). Indispensable pour diagnostiquer les blocages (locks) ou les opérations coûteuses (temp tables, tri, etc.).

## Info
Texte de la requête SQL actuellement exécutée (ou NULL si aucune). Permet d’identifier exactement la requête problématique ou à l’origine d’un lock. SHOW FULL PROCESSLIST affiche la requête complète.

## Progress
Indicateur (0–100) d’avancement de certaines opérations longues (ALTER, ANALYZE, etc.), quand supporté. Utile pour suivre l’évolution de tâches lourdes.

## Portée globale de SHOW PROCESSLIST
La commande donne une vue temps réel de l’activité du serveur : sessions actives, requêtes en cours, durées, états et requêtes associées. Combinée à des filtres ou à la vue INFORMATION_SCHEMA.PROCESSLIST, elle devient un outil central pour le diagnostic de performance et de concurrence (transactions et verrous).