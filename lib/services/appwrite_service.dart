import 'dart:convert';
import 'package:appwrite/appwrite.dart';
import '../core/constants.dart';
import '../data/models/drive_file.dart';

class AppwriteService {
  final Client client = Client();
  late final Functions functions;

  AppwriteService() {
    client
        .setEndpoint(AppConstants.appwriteEndpoint)
        .setProject(AppConstants.appwriteProjectId);
    functions = Functions(client);
  }

  Future<List<DriveFile>> getFolderContents(String folderId) async {
    try {
      final execution = await functions.createExecution(
        functionId: AppConstants.googleDriveFunctionId,
        body: jsonEncode({'folderId': folderId}),
      );

      if (execution.status == 'completed') {
        final data = jsonDecode(execution.responseBody);
        
        // Adaptez le parsing selon la structure exacte renvoyée par votre fonction JS
        // Si la fonction renvoie { files: [...] } ou directement [...]
        final List<dynamic> filesList = data is List 
            ? data 
            : (data['files'] ?? []);

        return filesList.map((e) => DriveFile.fromJson(e)).toList();
      } else {
        throw Exception('Erreur exécution fonction: ${execution.status}');
      }
    } catch (e) {
      print('Erreur Appwrite: $e');
      rethrow;
    }
  }
}

