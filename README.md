# Miam : application mobile (Flutter)

Application mobile de la cantine **Miam** pour les parents, élèves et employés. Elle se connecte à l'ERP Miam (dépôt `erp-miam`) via son API mobile.

Serveur de production : https://miam.jambo.ci

## Fonctionnalités

- **Connexion par code d'accès** remis par l'établissement (parent, élève ou employé), session conservée de façon sécurisée.
- **Accueil** : photo et « Bonjour + nom », solde, catégories, menus de la semaine, meilleures offres.
- **Articles** : filtre par catégorie, recherche, fiche article, ajout au panier.
- **Menus** : détail d'un menu, **réservation** pour les parents et élèves, ajout au panier pour les employés.
- **Panier et commande** : paiement par Paystack (via le portefeuille) ou en espèces ; mode sur place ou à emporter.
- **Commandes** : liste réelle et détail (établissement, date et heure, statut, mode, paiement).
- **Portefeuille** : QR de la personne, solde en FCFA, recharge Paystack, carte cadeau, historique des transactions.
- Thèmes clair et sombre, interface en français.

## Prérequis

- Flutter 3.41 (canal stable) et un téléphone Android (ou un émulateur).
- Un ERP Miam accessible (local ou https://miam.jambo.ci).

## Lancer l'application

```bash
git clone <url-du-depot> miam-mobile
cd miam-mobile
flutter pub get
```

Contre l'ERP local (téléphone en USB) :

```bash
adb reverse tcp:3001 tcp:3001
flutter run
```

Contre un serveur distant :

```bash
flutter run --dart-define=API_URL=https://miam.jambo.ci
```

Sans `API_URL`, l'application utilise `http://localhost:3001`.

### Firebase (connexion Google / téléphone)

Le fichier `google-services.json` n'est pas publié (il est dans `.gitignore`). Créez votre projet Firebase et placez le fichier dans `android/app/` avant de compiler.

## Structure

- `lib/core` : API (`api_client`, `erp_api`, `erp_stores`), session, thème, widgets communs, routes.
- `lib/features` : écrans par fonctionnalité (accueil, shop/articles, panier, commandes, portefeuille, profil, connexion).
- `packages/miam_assets` et `packages/miam_icons` : images, polices et icônes.
- `android/` : projet Android natif.

## Qualité

```bash
flutter analyze
```

## Sécurité

Aucun secret n'est stocké dans l'application : les prix sont calculés par le serveur, le jeton est conservé dans le stockage sécurisé, les images protégées sont chargées avec le jeton.
