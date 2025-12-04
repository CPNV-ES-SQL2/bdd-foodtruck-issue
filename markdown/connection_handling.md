## Client
Un client (terminal, script, application) souhaite établir une connexion vers MySQL/MariaDB. Il utilise le protocole
client-serveur MySQL via libmysqlclient ou un connecteur.

## Connection Request
Le client envoie une requête TCP/IP vers le port 3306 pour ouvrir la connexion. Ce n’est qu’après cette étape que se déroulent le handshake, la négociation de capacités et l’authentification (user/mot de passe, hôte comme localhost, etc.).

## Receiver Thread
Le serveur reçoit les demandes de connexion via le Receiver Thread. Ce thread traite les requêtes une par une et crée
un User Thread pour chaque nouvelle connexion, ou récupère un thread existant si disponible. Son rôle est uniquement
d’attribuer un thread utilisateur.

## Thread Cache
Le Thread Cache contient des threads système inactifs, prêts à être réutilisés. Si un thread libre est trouvé,
le serveur l’utilise pour la connexion au lieu d’en créer un nouveau. Le cache était crucial lorsque créer un thread OS
était coûteux, mais reste utile lorsque le nombre de connexions varie fortement.

## User Thread
Le User Thread est le thread qui prend en charge toute la connexion : handshake initial, négociation, authentification,
puis exécution des requêtes SQL. Ce thread est dédié à la connexion tant qu’elle reste ouverte et alloue
la structure THD associée.

## THD (Thread Handler Data)
Chaque connexion possède sa propre THD, créée au moment de l’ouverture et détruite à la déconnexion. Elle n’est jamais
réutilisée pour une autre connexion. La THD contient tout le contexte de session : variables utilisateur,
variables de session, droits, contexte transactionnel, tables temporaires, allocations mémoire, etc. Sa taille initiale
est d’environ 10 Ko, mais elle peut monter jusqu’à plusieurs Mo selon les requêtes exécutées.