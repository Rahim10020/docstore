import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/appwrite_service.dart';
import '../data/models/ecole.dart';
import '../data/models/filiere.dart';
import '../data/models/ue.dart';
import '../data/models/concours.dart';
export 'saved_resources_provider.dart';

/// Provider pour le service Appwrite
final appwriteServiceProvider = Provider<AppwriteService>((ref) {
  return AppwriteService();
});

// ========== PROVIDERS ECOLES ==========

/// Provider pour charger toutes les écoles
final ecolesProvider = FutureProvider<List<Ecole>>((ref) async {
  final service = ref.read(appwriteServiceProvider);
  return await service.getEcoles();
});

/// Provider pour charger une école spécifique par ID
final ecoleProvider = FutureProvider.family<Ecole, String>((
  ref,
  ecoleId,
) async {
  final service = ref.read(appwriteServiceProvider);
  return await service.getEcole(ecoleId);
});

// ========== PROVIDERS FILIERES ==========

/// Provider pour charger les filières d'une école
final filieresByEcoleProvider = FutureProvider.family<List<Filiere>, String>((
  ref,
  ecoleId,
) async {
  final service = ref.read(appwriteServiceProvider);
  return await service.getFilieresByEcole(ecoleId);
});

/// Provider pour charger une filière spécifique par ID
final filiereProvider = FutureProvider.family<Filiere, String>((
  ref,
  filiereId,
) async {
  final service = ref.read(appwriteServiceProvider);
  return await service.getFiliere(filiereId);
});

// ========== PROVIDERS UES ==========

/// Provider pour charger les UEs d'une filière
final uesByFiliereProvider = FutureProvider.family<List<Ue>, String>((
  ref,
  filiereId,
) async {
  final service = ref.read(appwriteServiceProvider);
  return await service.getUEsByFiliere(filiereId);
});

/// Provider pour charger une UE spécifique par ID
final ueProvider = FutureProvider.family<Ue, String>((ref, ueId) async {
  final service = ref.read(appwriteServiceProvider);
  return await service.getUE(ueId);
});

// ========== PROVIDERS CONCOURS ==========

/// Provider pour charger tous les concours
final concoursProvider = FutureProvider<List<Concours>>((ref) async {
  final service = ref.read(appwriteServiceProvider);
  return await service.getConcours();
});

/// Provider pour charger un concours spécifique par ID
final concoursDetailProvider = FutureProvider.family<Concours, String>( (
  ref,
  concoursId,
) async {
  final service = ref.read(appwriteServiceProvider);
  return await service.getConcoursById(concoursId);
});

/// Provider pour charger les concours d'une école
final concoursByEcoleProvider = FutureProvider.family<List<Concours>, String>( (
  ref,
  ecoleId,
) async {
  final service = ref.read(appwriteServiceProvider);
  return await service.getConcoursByEcole(ecoleId);
});
