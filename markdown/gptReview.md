Vos scénarios se ressemblent trop. Alice intervient une fois, mais pas dans tous les scénarios.

Je vous prie de réaliser les modifications suivantes :

Construisez une situation réaliste où la transaction a du sens (c’est d’ailleurs l’une de vos questions). Le cas standard que l’on utilise habituellement pour illustrer le concept est celui des transactions bancaires. La transaction permet d’éviter d’avoir 200.- en transit d’un compte à l’autre. En ouvrant la transaction, en réalisant le transfert d’argent et en la commitant une fois le transfert terminé, on évite d’avoir un état incohérent : soit "perdre" 200.-, soit avoir "virtuellement" 400.- parce que le premier compte n’a pas été débité avant que le second ne soit crédité.

Concernant le soin rédactionnel, je vous demande un effort particulier. Par exemple :

Vous mentionnez commit en minuscule, mais ROLLBACK en majuscule ; il est préférable d’harmoniser la typographie.

Il y a également plusieurs coquilles dans les formulations.

Pour faire suite à notre discussion de midi, ajoutez l’utilisation de session pour montrer l’effet de COMMIT et prouver que la transaction est limitée à la session en cours.
