import 'dart:io';
import '../../../../params/base_params.dart';
import '../../../../results/result.dart';
import '../../../../usecase/usecase.dart';
import '../model/document_model.dart';
import '../repository/repo.dart';

class UploadManyDocumentParams extends BaseParams {
  List<File> photos;
  String masterType;
  String masterId;
  int entityType;

  UploadManyDocumentParams({
    required this.photos,
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

class UploadManyDocumentUseCase
    extends UseCase<List<DocumentModel>, UploadManyDocumentParams> {
  final DocumentRepository repository;

  UploadManyDocumentUseCase(this.repository);

  @override
  Future<Result<List<DocumentModel>>> call({
    required UploadManyDocumentParams params,
  }) {
    return repository.uploadManyDocumentRequest(params: params);
  }
}
