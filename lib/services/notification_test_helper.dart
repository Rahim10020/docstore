import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/notification_provider.dart';
import '../data/models/notification.dart';

/// Utilitaire pour ajouter des notifications de démo
class NotificationTestHelper {
  /// Ajoute quelques notifications de test
  static void addDemoNotifications(WidgetRef ref) {
    final notifier = ref.read(notificationsProvider.notifier);

    // Notification de nouveau document
    notifier.addNotification(
      AppNotification(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Nouveau document ajouté',
        message: 'Le document "Cours de Programmation Web.pdf" a été ajouté dans Licence 3 Informatique',
        type: NotificationType.document,
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
    );

    // Notification de nouvelle école
    notifier.addNotification(
      AppNotification(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        title: 'Nouvelle école ajoutée',
        message: 'L\'école "Institut Supérieur de Technologie" a été ajoutée à DocStore',
        type: NotificationType.ecole,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    );

    // Notification de nouvelle filière
    notifier.addNotification(
      AppNotification(
        id: (DateTime.now().millisecondsSinceEpoch + 2).toString(),
        title: 'Nouvelle filière ajoutée',
        message: 'La filière "Master en Intelligence Artificielle" a été ajoutée dans EPL',
        type: NotificationType.filiere,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    );

    // Notification de document plus ancienne
    notifier.addNotification(
      AppNotification(
        id: (DateTime.now().millisecondsSinceEpoch + 3).toString(),
        title: 'Nouveau document ajouté',
        message: 'Le document "Sujets d\'examen 2024.pdf" a été ajouté dans Master 1 GLSI',
        type: NotificationType.document,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    );
  }

  /// Efface toutes les notifications
  static void clearAllNotifications(WidgetRef ref) {
    ref.read(notificationsProvider.notifier).clearAll();
  }
}

