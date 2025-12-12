import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/notification_provider.dart';
import '../data/models/ecole.dart';
import '../data/models/filiere.dart';

/// Service pour gérer l'envoi de notifications
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  WidgetRef? _ref;

  void init(WidgetRef ref) {
    _ref = ref;
  }

  /// Notifie l'ajout d'un nouveau document
  void notifyNewDocument(String documentName, String context) {
    if (_ref == null) {
      debugPrint('NotificationService non initialisé');
      return;
    }

    final prefs = _ref!.read(notificationPreferencesProvider);
    if (!prefs.documentsEnabled) return;

    _ref!.read(notificationsProvider.notifier).notifyNewDocument(
          documentName,
          context,
        );
  }

  /// Notifie l'ajout d'une nouvelle école
  void notifyNewEcole(Ecole ecole) {
    if (_ref == null) {
      debugPrint('NotificationService non initialisé');
      return;
    }

    final prefs = _ref!.read(notificationPreferencesProvider);
    if (!prefs.ecolesEnabled) return;

    _ref!.read(notificationsProvider.notifier).notifyNewEcole(
          ecole.nom,
          ecole.id,
        );
  }

  /// Notifie l'ajout d'une nouvelle filière
  void notifyNewFiliere(Filiere filiere, String ecoleName) {
    if (_ref == null) {
      debugPrint('NotificationService non initialisé');
      return;
    }

    final prefs = _ref!.read(notificationPreferencesProvider);
    if (!prefs.filieresEnabled) return;

    _ref!.read(notificationsProvider.notifier).notifyNewFiliere(
          filiere.nom,
          ecoleName,
          filiere.id,
        );
  }
}

