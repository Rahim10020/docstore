// Example: Comment intégrer les notifications avec vos données
// Placez ce code dans vos widgets ou providers qui créent de nouvelles données

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'notification_service.dart';
import 'notification_test_helper.dart';
import '../data/models/ecole.dart';
import '../data/models/filiere.dart';
import '../providers/notification_provider.dart';
import '../providers/data_provider.dart';

/// EXEMPLE 1: Notifier quand une nouvelle école est ajoutée
///
/// Utilisez ceci dans votre formulaire d'ajout d'école ou après
/// avoir détecté une nouvelle école via Appwrite Realtime
void onEcoleCreated(WidgetRef ref, Ecole nouvelleEcole) {
  // Votre logique métier...

  // Envoyer la notification
  NotificationService().notifyNewEcole(nouvelleEcole);

  // Optionnel: Rafraîchir les données
  ref.invalidate(ecolesProvider);
}

/// EXEMPLE 2: Notifier quand une nouvelle filière est ajoutée
void onFiliereCreated(WidgetRef ref, Filiere nouvelleFiliere, String nomEcole) {
  // Votre logique métier...

  // Envoyer la notification
  NotificationService().notifyNewFiliere(nouvelleFiliere, nomEcole);

  // Optionnel: Rafraîchir les données
  ref.invalidate(filieresByEcoleProvider(nouvelleFiliere.idEcole));
}

/// EXEMPLE 3: Notifier quand un nouveau document est ajouté
void onDocumentUploaded(WidgetRef ref, String nomDocument, String contexte) {
  // Votre logique métier (upload vers Appwrite, etc.)...

  // Envoyer la notification
  NotificationService().notifyNewDocument(nomDocument, contexte);
}

/// EXEMPLE 4: Détecter automatiquement les nouveaux éléments avec Appwrite Realtime
///
/// Ajoutez ceci dans votre AppwriteService ou dans un provider dédié
class NotificationMonitorService {
  // Dans votre méthode init() du service Appwrite:
  /*
  void setupRealtimeNotifications(WidgetRef ref) {
    final realtime = Realtime(_config.client);

    // Écouter les nouvelles écoles
    final ecolesSubscription = realtime.subscribe([
      'databases.${AppwriteConfig.databaseId}.collections.${AppwriteConfig.ecolesCollectionId}.documents'
    ]);

    ecolesSubscription.stream.listen((response) {
      if (response.events.contains('databases.*.collections.*.documents.*.create')) {
        final data = response.payload;
        final ecole = Ecole.fromMap(data);
        NotificationService().notifyNewEcole(ecole);
      }
    });

    // Écouter les nouvelles filières
    final filieresSubscription = realtime.subscribe([
      'databases.${AppwriteConfig.databaseId}.collections.${AppwriteConfig.filieresCollectionId}.documents'
    ]);

    filieresSubscription.stream.listen((response) {
      if (response.events.contains('databases.*.collections.*.documents.*.create')) {
        final data = response.payload;
        final filiere = Filiere.fromMap(data);
        // Vous devrez récupérer le nom de l'école associée
        final ecoleName = 'Nom de l\'école'; // À récupérer
        NotificationService().notifyNewFiliere(filiere, ecoleName);
      }
    });
  }
  */
}

/// EXEMPLE 5: Initialiser le NotificationService dans votre app
///
/// Dans votre ConsumerStatefulWidget principal (ex: DocStoreAppShell)
class ExampleAppShellWithNotifications extends ConsumerStatefulWidget {
  const ExampleAppShellWithNotifications({super.key});

  @override
  ConsumerState<ExampleAppShellWithNotifications> createState() =>
      _ExampleAppShellWithNotificationsState();
}

class _ExampleAppShellWithNotificationsState
    extends ConsumerState<ExampleAppShellWithNotifications> {
  @override
  void initState() {
    super.initState();
    // Initialiser le service de notifications avec la référence ref
    // Ceci doit être fait après que le widget soit construit
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationService().init(ref);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Votre UI ici...
    return Container();
  }
}

/// EXEMPLE 6: Utiliser le helper de test pour ajouter des notifications de démo
///
/// Utile pendant le développement pour tester l'interface
void addTestNotifications(WidgetRef ref) {
  // Import: import '../services/notification_test_helper.dart';
  NotificationTestHelper.addDemoNotifications(ref);
}

/// EXEMPLE 7: Vérifier les préférences avant d'envoyer une notification
///
/// Le NotificationService le fait déjà automatiquement, mais vous pouvez
/// aussi vérifier manuellement si nécessaire
void checkNotificationPreferences(WidgetRef ref) {
  final prefs = ref.read(notificationPreferencesProvider);

  if (prefs.documentsEnabled) {
    // L'utilisateur veut recevoir les notifications de documents
  }

  if (prefs.ecolesEnabled) {
    // L'utilisateur veut recevoir les notifications d'écoles
  }

  if (prefs.filieresEnabled) {
    // L'utilisateur veut recevoir les notifications de filières
  }
}

