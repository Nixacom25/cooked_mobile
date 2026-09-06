# Cooked

Application mobile Flutter permettant d'importer des recettes depuis les réseaux sociaux
(TikTok, Instagram, YouTube) via le partage système, de les organiser en cookbooks, de
générer des listes de courses et de gérer un abonnement premium.

## Stack technique

- Flutter / Dart
- Hive (cache local des requêtes API avec TTL)
- Firebase (Analytics, Crashlytics, Performance)
- RevenueCat / `in_app_purchase` pour les abonnements
- `receive_sharing_intent` / `app_links` pour l'import et le deep linking

Voir [`TECHNICAL_DOCUMENTATION.md`](./TECHNICAL_DOCUMENTATION.md) pour le détail de
l'architecture, des services et de la configuration native iOS/Android.

## Démarrer

```bash
flutter pub get
flutter run
```
