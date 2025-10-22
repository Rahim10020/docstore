import 'package:docstore/core/utils/helpers.dart';

import '../../domain/entities/resource_file.dart';

class ResourceFileModel extends ResourceFile {
  const ResourceFileModel({
    required super.id,
    required super.name,
    required super.source,
    super.mimeType,
    super.sizeBytes,
    super.createdAt,
    super.driveFileId,
    super.driveDownloadUrl,
    super.drivePreviewUrl,
  });

  // Factory pour créer depuis un ID/URL (détection auto)
  factory ResourceFileModel.fromIdOrUrl(String idOrUrl, {String? name}) {
    if (Helpers.isGoogleDriveLink(idOrUrl)) {
      // C'est un lien Google Drive
      final fileId = Helpers.extractDriveFileId(idOrUrl);
      return ResourceFileModel(
        id: idOrUrl,
        name: name ?? 'Fichier Google Drive',
        source: FileSource.googleDrive,
        driveFileId: fileId,
        driveDownloadUrl: fileId != null
            ? Helpers.getDriveDownloadUrl(fileId)
            : null,
        drivePreviewUrl: fileId != null
            ? Helpers.getDrivePreviewUrl(fileId)
            : null,
      );
    } else {
      // C'est un ID Appwrite
      return ResourceFileModel(
        id: idOrUrl,
        name: name ?? 'Fichier',
        source: FileSource.appwrite,
      );
    }
  }

  // From JSON (métadonnées Appwrite Storage)
  factory ResourceFileModel.fromAppwriteFile(Map<String, dynamic> json) {
    return ResourceFileModel(
      id: json['\$id'] as String,
      name: json['name'] as String,
      source: FileSource.appwrite,
      mimeType: json['mimeType'] as String?,
      sizeBytes: json['sizeOriginal'] as int?,
      createdAt: json['\$createdAt'] != null
          ? DateTime.parse(json['\$createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'source': source.toString(),
      'mimeType': mimeType,
      'sizeBytes': sizeBytes,
      'createdAt': createdAt?.toIso8601String(),
      'driveFileId': driveFileId,
      'driveDownloadUrl': driveDownloadUrl,
      'drivePreviewUrl': drivePreviewUrl,
    };
  }

  factory ResourceFileModel.fromMap(Map<String, dynamic> map) {
    return ResourceFileModel(
      id: map['id'] as String,
      name: map['name'] as String,
      source: map['source'].toString().contains('googleDrive')
          ? FileSource.googleDrive
          : FileSource.appwrite,
      mimeType: map['mimeType'] as String?,
      sizeBytes: map['sizeBytes'] as int?,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : null,
      driveFileId: map['driveFileId'] as String?,
      driveDownloadUrl: map['driveDownloadUrl'] as String?,
      drivePreviewUrl: map['drivePreviewUrl'] as String?,
    );
  }

  ResourceFileModel copyWith({
    String? id,
    String? name,
    FileSource? source,
    String? mimeType,
    int? sizeBytes,
    DateTime? createdAt,
    String? driveFileId,
    String? driveDownloadUrl,
    String? drivePreviewUrl,
  }) {
    return ResourceFileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      source: source ?? this.source,
      mimeType: mimeType ?? this.mimeType,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      createdAt: createdAt ?? this.createdAt,
      driveFileId: driveFileId ?? this.driveFileId,
      driveDownloadUrl: driveDownloadUrl ?? this.driveDownloadUrl,
      drivePreviewUrl: drivePreviewUrl ?? this.drivePreviewUrl,
    );
  }
}
