import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/notification.dart';

// Provider pour les préférences de notifications
final notificationPreferencesProvider =
    StateNotifierProvider<NotificationPreferencesNotifier, NotificationPreferences>((ref) {
  return NotificationPreferencesNotifier();
});

// Provider pour les notifications
final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, List<AppNotification>>((ref) {
  return NotificationsNotifier();
});

// Provider pour compter les notifications non lues
final unreadNotificationsCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationsProvider);
  return notifications.where((n) => !n.isRead).length;
});

// Classe pour gérer les préférences de notifications
class NotificationPreferences {
  final bool documentsEnabled;
  final bool ecolesEnabled;
  final bool filieresEnabled;

  NotificationPreferences({
    this.documentsEnabled = true,
    this.ecolesEnabled = true,
    this.filieresEnabled = true,
  });

  NotificationPreferences copyWith({
    bool? documentsEnabled,
    bool? ecolesEnabled,
    bool? filieresEnabled,
  }) {
    return NotificationPreferences(
      documentsEnabled: documentsEnabled ?? this.documentsEnabled,
      ecolesEnabled: ecolesEnabled ?? this.ecolesEnabled,
      filieresEnabled: filieresEnabled ?? this.filieresEnabled,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'documentsEnabled': documentsEnabled,
      'ecolesEnabled': ecolesEnabled,
      'filieresEnabled': filieresEnabled,
    };
  }

  factory NotificationPreferences.fromMap(Map<String, dynamic> map) {
    return NotificationPreferences(
      documentsEnabled: map['documentsEnabled'] ?? true,
      ecolesEnabled: map['ecolesEnabled'] ?? true,
      filieresEnabled: map['filieresEnabled'] ?? true,
    );
  }
}

// Notifier pour gérer les préférences
class NotificationPreferencesNotifier extends StateNotifier<NotificationPreferences> {
  NotificationPreferencesNotifier() : super(NotificationPreferences()) {
    _loadPreferences();
  }

  static const String _prefsKey = 'notification_preferences';

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? prefsJson = prefs.getString(_prefsKey);
      if (prefsJson != null) {
        final Map<String, dynamic> prefsMap = json.decode(prefsJson);
        state = NotificationPreferences.fromMap(prefsMap);
      }
    } catch (e) {
      debugPrint('Erreur lors du chargement des préférences de notifications: $e');
    }
  }

  Future<void> _savePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String prefsJson = json.encode(state.toMap());
      await prefs.setString(_prefsKey, prefsJson);
    } catch (e) {
      debugPrint('Erreur lors de la sauvegarde des préférences de notifications: $e');
    }
  }

  void toggleDocuments(bool value) {
    state = state.copyWith(documentsEnabled: value);
    _savePreferences();
  }

  void toggleEcoles(bool value) {
    state = state.copyWith(ecolesEnabled: value);
    _savePreferences();
  }

  void toggleFilieres(bool value) {
    state = state.copyWith(filieresEnabled: value);
    _savePreferences();
  }
}

// Notifier pour gérer les notifications
class NotificationsNotifier extends StateNotifier<List<AppNotification>> {
  NotificationsNotifier() : super([]) {
    _loadNotifications();
  }

  static const String _notificationsKey = 'notifications';

  Future<void> _loadNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? notificationsJson = prefs.getString(_notificationsKey);
      if (notificationsJson != null) {
        final List<dynamic> notificationsList = json.decode(notificationsJson);
        state = notificationsList
            .map((n) => AppNotification.fromMap(n as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('Erreur lors du chargement des notifications: $e');
    }
  }

  Future<void> _saveNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String notificationsJson = json.encode(
        state.map((n) => n.toMap()).toList(),
      );
      await prefs.setString(_notificationsKey, notificationsJson);
    } catch (e) {
      debugPrint('Erreur lors de la sauvegarde des notifications: $e');
    }
  }

  void addNotification(AppNotification notification) {
    state = [notification, ...state];
    _saveNotifications();
  }

  void markAsRead(String notificationId) {
    state = state.map((n) {
      if (n.id == notificationId) {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();
    _saveNotifications();
  }

  void markAllAsRead() {
    state = state.map((n) => n.copyWith(isRead: true)).toList();
    _saveNotifications();
  }

  void deleteNotification(String notificationId) {
    state = state.where((n) => n.id != notificationId).toList();
    _saveNotifications();
  }

  void clearAll() {
    state = [];
    _saveNotifications();
  }

  // Méthode pour créer une notification de nouveau document
  void notifyNewDocument(String documentName, String ecoleOrFiliereContext) {
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Nouveau document ajouté',
      message: 'Le document "$documentName" a été ajouté dans $ecoleOrFiliereContext',
      type: NotificationType.document,
      createdAt: DateTime.now(),
    );
    addNotification(notification);
  }

  // Méthode pour créer une notification de nouvelle école
  void notifyNewEcole(String ecoleName, String? ecoleId) {
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Nouvelle école ajoutée',
      message: 'L\'école "$ecoleName" a été ajoutée à DocStore',
      type: NotificationType.ecole,
      createdAt: DateTime.now(),
      relatedId: ecoleId,
    );
    addNotification(notification);
  }

  // Méthode pour créer une notification de nouvelle filière
  void notifyNewFiliere(String filiereName, String ecoleName, String? filiereId) {
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Nouvelle filière ajoutée',
      message: 'La filière "$filiereName" a été ajoutée dans $ecoleName',
      type: NotificationType.filiere,
      createdAt: DateTime.now(),
      relatedId: filiereId,
    );
    addNotification(notification);
  }
}

