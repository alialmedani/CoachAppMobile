import 'dart:io';
import '../../../../params/base_params.dart';
import '../../../../results/result.dart';
import '../../../../usecase/usecase.dart';
import '../model/document_model.dart';
import '../repository/repo.dart';

class UploadOneDocumentParams extends BaseParams {
  File? photo;
  String masterType;
  String masterId;
  int entityType;

  UploadOneDocumentParams({
    required this.photo,
    required this.masterType,
    required this.masterId,
    required this.entityType,
  });

  Map<String, dynamic> toJson() {
    return {
      'MasterType': masterType,
      'MasterId': masterId,
      'EntityType': entityType,
    };
  }
}

class UploadOneDocumentUseCase
    extends UseCase<DocumentModel, UploadOneDocumentParams> {
  final DocumentRepository repository;

  UploadOneDocumentUseCase(this.repository);

  @override
  Future<Result<DocumentModel>> call({
    required UploadOneDocumentParams params,
  }) {
    return repository.uploadOneDocumentRequest(params: params);
  }
}
