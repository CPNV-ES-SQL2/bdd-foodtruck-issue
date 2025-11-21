Vos scénarios se ressemble trop. Alice va pour une fois, mais pas pour tous les scénarios.

Je vous prie de réaliser les modifications suivantes:

* construisez une vraie situation où la transaction fait du sens (c'est d'ailleurs l'une de vos questions). Le cas standard que l'on traite habituellement pour découvrir le concept, c'est les transactions bancaires. La transaction va éviter d'avoir 200.- en transit d'un compte à l'autre, En ouvrant la transaction, réalisant le transfert d'argent et en le commitant une fois le transfert terminé, on évite ainsi d'avoir un état soit en ayant "perdu" 200.-, soit en ayant "virtuellement" 400.- car le premier compte n'a pas été débité avant que le second ne soit crédité.

Concernant le soin rédactionnel. Je vous demande un effort. Exemple:

* vous mentionnez "commit" en minuscule, mais "ROLLBACK" en majuscule.
* il y a aussi plusieurs "coquilles" dans les formulations
* pour faire suite à notre discussion de midi, ajouter l'utilisation de session vous comprendre l'action de COMMIT et prouver que la transaction est restreinte à la session en cours.
