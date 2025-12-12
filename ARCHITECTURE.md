# Architecture du Système de Notifications

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         DOCSTORE NOTIFICATION SYSTEM                     │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────┐
│                              UI LAYER                                    │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  ┌─────────────────┐    ┌──────────────────┐    ┌──────────────────┐  │
│  │  DocStoreHeader │    │ NotificationsScreen│   │ SettingsScreen   │  │
│  │                 │    │                   │    │                  │  │
│  │  [NotificationIcon]  │  • Liste notifications│  • Préférences   │  │
│  │   avec Badge    │    │  • Swipe to delete │    │  • Toggles      │  │
│  │                 │    │  • Mark as read    │    │  • Test button  │  │
│  └────────┬────────┘    └─────────┬──────────┘    └────────┬─────────┘  │
│           │                       │                        │            │
└───────────┼───────────────────────┼────────────────────────┼────────────┘
            │                       │                        │
            │                       │                        │
┌───────────┼───────────────────────┼────────────────────────┼────────────┐
│           │         RIVERPOD STATE MANAGEMENT              │            │
├───────────┼───────────────────────┼────────────────────────┼────────────┤
│           │                       │                        │            │
│           ▼                       ▼                        ▼            │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │         notificationsProvider                                    │   │
│  │  • List<AppNotification>                                        │   │
│  │  • addNotification()                                            │   │
│  │  • markAsRead()                                                 │   │
│  │  • deleteNotification()                                         │   │
│  │  • clearAll()                                                   │   │
│  └────────────────────────────┬────────────────────────────────────┘   │
│                                │                                        │
│  ┌────────────────────────────┴────────────────────────────────────┐   │
│  │         notificationPreferencesProvider                          │   │
│  │  • documentsEnabled                                             │   │
│  │  • ecolesEnabled                                                │   │
│  │  • filieresEnabled                                              │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                          │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │         unreadNotificationsCountProvider                         │   │
│  │  • Compte automatique des notifications non lues                │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                          │
└──────────────────────────────┬───────────────────────────────────────────┘
                               │
                               │
┌──────────────────────────────┼───────────────────────────────────────────┐
│                SERVICES LAYER│                                           │
├──────────────────────────────┼───────────────────────────────────────────┤
│                               │                                           │
│  ┌───────────────────────────▼────────────────────────────────────────┐ │
│  │         NotificationService (Singleton)                            │ │
│  │                                                                     │ │
│  │  • init(ref)                                                       │ │
│  │  • notifyNewDocument(name, context)                               │ │
│  │  • notifyNewEcole(ecole)                                          │ │
│  │  • notifyNewFiliere(filiere, ecoleName)                           │ │
│  └────────────────────────────────────────────────────────────────────┘ │
│                                                                          │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │         NotificationTestHelper                                   │   │
│  │  • addDemoNotifications(ref)                                    │   │
│  │  • clearAllNotifications(ref)                                   │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                          │
└──────────────────────────────┬───────────────────────────────────────────┘
                               │
                               │
┌──────────────────────────────┼───────────────────────────────────────────┐
│                   DATA LAYER │                                           │
├──────────────────────────────┼───────────────────────────────────────────┤
│                               │                                           │
│  ┌───────────────────────────▼────────────────────────────────────────┐ │
│  │         AppNotification Model                                       │ │
│  │                                                                     │ │
│  │  • id: String                                                      │ │
│  │  • title: String                                                   │ │
│  │  • message: String                                                 │ │
│  │  • type: NotificationType (document/ecole/filiere)                │ │
│  │  • createdAt: DateTime                                            │ │
│  │  • isRead: bool                                                   │ │
│  │  • relatedId: String?                                             │ │
│  └────────────────────────────────────────────────────────────────────┘ │
│                                                                          │
└──────────────────────────────┬───────────────────────────────────────────┘
                               │
                               │
┌──────────────────────────────┼───────────────────────────────────────────┐
│              PERSISTENCE     │                                           │
├──────────────────────────────┼───────────────────────────────────────────┤
│                               │                                           │
│  ┌───────────────────────────▼────────────────────────────────────────┐ │
│  │         SharedPreferences (Local Storage)                          │ │
│  │                                                                     │ │
│  │  Key: 'notifications'                                             │ │
│  │  Value: JSON List<AppNotification>                                │ │
│  │                                                                     │ │
│  │  Key: 'notification_preferences'                                  │ │
│  │  Value: JSON NotificationPreferences                              │ │
│  └────────────────────────────────────────────────────────────────────┘ │
│                                                                          │
└──────────────────────────────────────────────────────────────────────────┘


═══════════════════════════════════════════════════════════════════════════
                              FLUX DE DONNÉES
═══════════════════════════════════════════════════════════════════════════

1. CRÉATION D'UNE NOTIFICATION
   ────────────────────────────
   
   Votre Code
       ↓
   NotificationService.notifyNewDocument()
       ↓
   Vérifie les préférences (notificationPreferencesProvider)
       ↓
   Si activé → notificationsProvider.notifier.addNotification()
       ↓
   Ajoute en mémoire (state)
       ↓
   Sauvegarde dans SharedPreferences
       ↓
   UI se met à jour automatiquement (Riverpod)
       ↓
   Badge affiche le nombre (unreadNotificationsCountProvider)


2. LECTURE D'UNE NOTIFICATION
   ──────────────────────────
   
   User clique sur notification
       ↓
   notificationsProvider.notifier.markAsRead(id)
       ↓
   Met à jour en mémoire (isRead = true)
       ↓
   Sauvegarde dans SharedPreferences
       ↓
   UI se met à jour (bordure bleue disparaît)
       ↓
   Badge se met à jour (nombre diminue)


3. CHARGEMENT AU DÉMARRAGE
   ────────────────────────
   
   App démarre
       ↓
   NotificationsNotifier() constructor
       ↓
   _loadNotifications() appelé
       ↓
   Lit depuis SharedPreferences
       ↓
   Parse JSON → List<AppNotification>
       ↓
   Charge en mémoire (state)
       ↓
   UI affiche les notifications


═══════════════════════════════════════════════════════════════════════════
                          POINTS D'INTÉGRATION
═══════════════════════════════════════════════════════════════════════════

┌─────────────────────────────────────────────────────────────────────────┐
│  APPWRITE SERVICE                                                        │
│                                                                          │
│  Future<Ecole> createEcole(Ecole ecole) async {                        │
│    final created = await _databases.createDocument(...);                │
│    // ⚠️ AJOUTEZ ICI ⚠️                                                 │
│    NotificationService().notifyNewEcole(Ecole.fromMap(created.data));  │
│    return Ecole.fromMap(created.data);                                 │
│  }                                                                       │
│                                                                          │
│  Future<Filiere> createFiliere(Filiere filiere) async {               │
│    final created = await _databases.createDocument(...);                │
│    // ⚠️ AJOUTEZ ICI ⚠️                                                 │
│    NotificationService().notifyNewFiliere(                             │
│      Filiere.fromMap(created.data),                                    │
│      'Nom de l\'école'                                                 │
│    );                                                                   │
│    return Filiere.fromMap(created.data);                               │
│  }                                                                       │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────┐
│  APPWRITE REALTIME (Automatique - Future)                               │
│                                                                          │
│  final subscription = realtime.subscribe([                              │
│    'databases.*.collections.*.documents'                                │
│  ]);                                                                     │
│                                                                          │
│  subscription.stream.listen((response) {                                │
│    if (response.events.contains('create')) {                            │
│      // Détecter le type et notifier automatiquement                    │
│      NotificationService().notifyNew...();                              │
│    }                                                                     │
│  });                                                                     │
└─────────────────────────────────────────────────────────────────────────┘


═══════════════════════════════════════════════════════════════════════════
                           DÉPENDANCES
═══════════════════════════════════════════════════════════════════════════

flutter_riverpod: ^2.4.9      → State management
shared_preferences: ^2.2.2     → Persistance locale
timeago: ^3.7.0                → Temps relatif ("il y a X minutes")
flutter_svg: ^2.0.10           → Icône SVG

═══════════════════════════════════════════════════════════════════════════
```

