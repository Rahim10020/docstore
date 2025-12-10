import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/appwrite_service.dart';
import '../data/models/drive_file.dart';

// Provider pour le service Appwrite
final appwriteServiceProvider = Provider<AppwriteService>((ref) {
  return AppwriteService();
});

// Provider pour charger les fichiers d'un dossier
final folderFilesProvider = FutureProvider.family<List<DriveFile>, String>(
  (ref, folderId) async {
    final service = ref.read(appwriteServiceProvider);
    return await service.getFolderContents(folderId);
  },
);

