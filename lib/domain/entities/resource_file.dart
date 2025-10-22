import 'package:docstore/core/utils/helpers.dart';
import 'package:equatable/equatable.dart';

enum FileSource { appwrite, googleDrive }

class ResourceFile extends Equatable {
  final String id; // ID Appwrite ou URL Drive
  final String name;
  final FileSource source;
  final String? mimeType;
  final int? sizeBytes;
  final DateTime? createdAt;

  // Pour Google Drive
  final String? driveFileId;
  final String? driveDownloadUrl;
  final String? drivePreviewUrl;

  const ResourceFile({
    required this.id,
    required this.name,
    required this.source,
    this.mimeType,
    this.sizeBytes,
    this.createdAt,
    this.driveFileId,
    this.driveDownloadUrl,
    this.drivePreviewUrl,
  });

  bool get isFromDrive => source == FileSource.googleDrive;
  bool get isFromAppwrite => source == FileSource.appwrite;

  String get displaySize =>
      sizeBytes != null ? Helpers.formatFileSize(sizeBytes!) : 'N/A';

  @override
  List<Object?> get props => [
    id,
    name,
    source,
    mimeType,
    sizeBytes,
    driveFileId,
    driveDownloadUrl,
    drivePreviewUrl,
  ];

  @override
  String toString() => 'ResourceFile(id: $id, name: $name, source: $source)';
}
