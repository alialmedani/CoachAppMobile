import 'dart:io';
import '../../../../params/base_params.dart';
import '../../../../results/result.dart';
import '../../../../usecase/usecase.dart';
import '../model/document_model.dart';
import '../repository/repo.dart';

class UploadCurrentUserDocumentParams extends BaseParams {
  List<File> photo;
  String masterType;

  UploadCurrentUserDocumentParams({
    required this.photo,
    required this.masterType,
  });

  Map<String, dynamic> toJson() {
    return {'MasterType': masterType};
  }
}

class UploadCurrentUserDocumentUseCase
    extends UseCase<List<DocumentModel>, UploadCurrentUserDocumentParams> {
  final DocumentRepository repository;

  UploadCurrentUserDocumentUseCase(this.repository);

  @override
  Future<Result<List<DocumentModel>>> call({
    required UploadCurrentUserDocumentParams params,
  }) {
    return repository.uploadCurrentUserDocumentRequest(params: params);
  }
}
