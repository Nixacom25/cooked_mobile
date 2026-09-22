# Configuration des Abonnements - Cooked App

## Configuration RevenueCat

### Entitlements
- **ID**: `premium`
- Description: Accès complet à l'application

### Produits

#### 1. Monthly Subscription
- **Product ID**: `monthly_sub`
- **Type**: Monthly Subscription
- **Free Trial**: **AUCUN** (0 jours)
- **Pricing**: $9.99/mo
- **Behavior**: Facturation immédiate après achat

#### 2. Yearly Subscription
- **Product ID**: `yearly_sub`
- **Type**: Annual Subscription
- **Free Trial**: **3 jours**
- **Pricing**: $29.99/an
- **Behavior**: 3 jours gratuits, puis facturation automatique

## Configuration Apple App Store Connect

### Monthly Subscription
1. Créer le produit d'abonnement avec Product ID: `monthly_sub`
2. **Gratuité d'essai**: 0 jours
3. **Prix**: $9.99/mo
4. **Durée**: 1 mois
5. **Renouvellement automatique**: Oui

### Yearly Subscription
1. Créer le produit d'abonnement avec Product ID: `yearly_sub`
2. **Gratuité d'essai**: 3 jours
3. **Prix**: $29.99/an
4. **Durée**: 1 an
5. **Renouvellement automatique**: Oui

## Configuration Google Play Console

### Monthly Subscription
1. Créer le produit d'abonnement avec Product ID: `monthly_sub`
2. **Période d'essai gratuite**: 0 jours
3. **Prix**: $9.99/mo
4. **Durée**: 1 mois
5. **Renouvellement automatique**: Oui

### Yearly Subscription
1. Créer le produit d'abonnement avec Product ID: `yearly_sub`
2. **Période d'essai gratuite**: 3 jours
3. **Prix**: $29.99/an
4. **Durée**: 1 an
5. **Renouvellement automatique**: Oui

## Configuration Backend API

### Endpoint: POST /api/user/subscription/webhook
Le backend doit recevoir les webhooks RevenueCat pour :

1. **Activation d'abonnement**:
   - Mettre à jour `subscriptionStatus` à `ACTIVE` ou `TRIAL`
   - Définir `subscriptionExpiresAt` selon le plan
   - Activer l'accès à l'utilisateur

2. **Expiration d'abonnement**:
   - Mettre à jour `subscriptionStatus` à `EXPIRED`
   - Désactiver l'accès à l'utilisateur
   - Forcer à l'écran d'abonnement à la prochaine connexion

3. **Annulation**:
   - L'utilisateur garde l'accès jusqu'à la fin de la période payée
   - `subscriptionStatus` devient `CANCELED`
   - `subscriptionExpiresAt` reste la date de fin de période

### Vérification de souscription
Le backend doit valider :
- `subscriptionStatus` est `ACTIVE` ou `TRIAL`
- `subscriptionExpiresAt` est dans le futur (si défini)
- Sinon, retourner 403 Forbidden ou rediriger vers l'écran d'abonnement

## Sécurité

### Client-side (Flutter)
- ✅ Vérification du statut premium à chaque login
- ✅ Redirection vers onboarding si non abonné
- ✅ Impossible d'accéder aux fonctionnalités sans abonnement

### Backend
- ✅ **Middleware SubscriptionRequiredFilter** : Vérifie le statut d'abonnement sur chaque requête API
- ✅ **Gestion TRIAL** : Détection correcte des essais gratuits depuis RevenueCat
- ✅ **Webhooks RevenueCat** : Synchronisation automatique du statut d'abonnement
- ✅ **Vérification getCurrentUser** : Lève PaymentRequiredException si non abonné
- ✅ **Comptes par défaut FREE** : Les nouveaux comptes sont initialisés avec subscriptionStatus = FREE
- ✅ Pas de contournement possible par manipulation locale

## Flow Utilisateur

### Nouvel utilisateur
1. Création de compte ✅ (marqué comme FREE)
2. Onboarding complet ✅
3. Écran d'abonnement (TrialStep) ✅
4. Sélection Monthly ou Yearly ✅
5. Modal de paiement (Apple/Google) ✅
6. **Si Monthly**: Facturation immédiate ✅
7. **Si Yearly**: 3 jours gratuits puis facturation ✅
8. Webhook RevenueCat met statut à ACTIVE ou TRIAL ✅
9. Accès à l'app ✅

### Utilisateur existant sans abonnement
1. Login ✅
2. Vérification statut backend (Middleware) ✅
3. Si non abonné → 403 Forbidden + Redirection vers onboarding/abonnement ✅
4. Doit s'abonner pour continuer ✅
5. Accès bloqué jusqu'à abonnement actif ✅

### Utilisateur avec abonnement actif
1. Login ✅
2. Vérification statut backend (Middleware) ✅
3. Si abonné → Accès direct à l'app ✅

## Modifications Appliquées

### 1. RevenueCatWebhookController.java
- ✅ Ajout de la détection d'essai gratuit (is_trial)
- ✅ Met subscriptionStatus à TRIAL pour les essais gratuits
- ✅ Met subscriptionStatus à ACTIVE pour les achats normaux
- ✅ Logging amélioré avec le statut

### 2. SubscriptionRequiredFilter.java (NOUVEAU)
- ✅ Filtre de sécurité pour vérifier l'abonnement sur chaque requête
- ✅ Retourne 403 Forbidden si subscriptionStatus est FREE ou EXPIRED
- ✅ Autorise si ACTIVE ou TRIAL avec expiration dans le futur
- ✅ Ignore les endpoints publics (auth, webhooks, etc.)

### 3. SecurityConfig.java
- ✅ Ajout de SubscriptionRequiredFilter dans la chaîne de filtres
- ✅ Positionné après JwtAuthenticationFilter pour vérifier après authentification

### 4. UserServiceImpl.java
- ✅ Ajout de la vérification d'abonnement dans getCurrentUser()
- ✅ Lève PaymentRequiredException si non abonné
- ✅ Vérifie l'expiration de l'abonnement

### 5. User.java
- ✅ Déjà initialisé avec subscriptionStatus = FREE par défaut
