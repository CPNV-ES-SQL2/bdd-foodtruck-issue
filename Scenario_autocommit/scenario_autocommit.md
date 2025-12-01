## Scénario : Modification de plafond de carte bancaire en mode brouillon (autocommit désactivé, sans transaction explicite)

### Intention métier

Un conseiller veut tester une augmentation du plafond de carte bancaire d’un client en production, sans que cette
modification soit visible pour les autres utilisateurs (Test en production).

On utilise `autocommit = 0` dans sa session, sans `START TRANSACTION`.

---

### Given

- La base de données `bank` existe.
- La table `customers` existe avec les colonnes : `(id, name)`.
- La table `cards` existe avec les colonnes : `(id, customer_id, status, limit_amount)`.
- Le client `Alice` existe dans `customers` avec `id = 1`.
- La carte de crédit d’Alice existe dans `cards` avec :
    - `customer_id = 1`
    - `status = 'active'`
    - `limit_amount = 2000` (plafond actuel : 2000 CHF).
- La session 1 (conseiller) a l’autocommit désactivé :
    - `SET autocommit = 0;`
- La session 2 (autre utilisateur) utilise l’autocommit activé :
    - `SET autocommit = 1;`
- Tous les autres clients et cartes ne sont pas pertinents pour ce test.

---

### When
- Session 1 (conseiller, mode brouillon)
  - Je mets à jour la carte d’Alice pour augmenter son plafond de 2000 CHF à 5000 CHF.
  - Je consulte la carte d’Alice en session 1 (table `cards`).
- Session 2 (Autre utilisateur de l'application)
  - Consulte la carte d’Alice (plafond et statut).
- Session 1
  - Finalement, je décide que ce n’était qu’un test et je ne veux pas garder cette modification.
  - Je consulte à nouveau la carte.
- Session 2
  - Consulte à nouveau la carte d’Alice.

---

### Then

- Avant le `ROLLBACK` :
    - En session 1 :
        - La table `cards` montre la carte d’Alice avec `limit_amount = 5000` et `status = 'active'`.
        - Le conseiller voit donc le plafond testé (5000 CHF).
    - En session 2 :
        - La table `cards` montre toujours la carte d’Alice avec `limit_amount = 2000` et `status = 'active'`.
        - Les autres utilisateurs voient encore le plafond officiel (2000 CHF).
    - La modification de plafond est visible uniquement dans la session 1, tant que le conseiller n’a ni `COMMIT` ni `ROLLBACK`.
- Après le `ROLLBACK` en session 1 :
    - En session 1 :
        - La carte d’Alice revient à `limit_amount = 2000`, `status = 'active'`.
    - En session 2 :
        - La carte d’Alice est toujours à `limit_amount = 2000`, `status = 'active'`.
    - Aucune trace du test de plafond à 5000 CHF n’a été laissée en base :
        - le conseiller a pu tester en prod,
        - puis tout annuler proprement sans impacter les autres utilisateurs.