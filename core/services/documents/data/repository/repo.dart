   import '../../../../constant/end_points/api_url.dart';
import '../../../../data_source/remote_data_source.dart';
import '../../../../http/http_method.dart';
import '../../../../repository/core_repository.dart';
import '../../../../results/result.dart';
import '../model/document_model.dart';
import '../usecase/delete_document_usecase.dart';
import '../usecase/upload_current_user_document_usecase.dart';
import '../usecase/upload_many_document_usecase.dart';
import '../usecase/upload_one_document_usecase.dart';

class DocumentRepository extends CoreRepository {
  Future<Result<String>> deleteDocumentRequest({
    required DeleteDocumentParams params,
  }) async {
    final result = await RemoteDataSource.noModelRequest(
      withAuthentication: true,
      url: "$deleteDocumentUrl/${params.id}",
      method: HttpMethod.DELETE,
    );
    return noModelCall(result: result);
  }

  Future<Result<List<DocumentModel>>> uploadCurrentUserDocumentRequest({
    required UploadCurrentUserDocumentParams params,
  }) async {
    final result = await RemoteDataSource.request<List<DocumentModel>>(
      withAuthentication: true,
      files: params.photo,
      fileKey: 'Files',
      data: params.toJson(),
      url: uploadCuurentUserDocumentUrl,
      method: HttpMethod.POST,
      converter2: (json) {
        return List<DocumentModel>.from(
          json.map((x) => DocumentModel.fromJson(x)),
        );
      },
    );

    return call(result: result);
  }

  Future<Result<DocumentModel>> uploadOneDocumentRequest({
    required UploadOneDocumentParams params,
  }) async {
    final result = await RemoteDataSource.request<DocumentModel>(
      withAuthentication: true,
      file: params.photo,
      fileKey: 'File',
      data: params.toJson(),
      url: uploadOneDocumentUrl,
      method: HttpMethod.POST,
      converter: (json) {
        return DocumentModel.fromJson(json);
      },
    );

    return call(result: result);
  }

  Future<Result<List<DocumentModel>>> uploadManyDocumentRequest({
    required UploadManyDocumentParams params,
  }) async {
    final result = await RemoteDataSource.request<List<DocumentModel>>(
      withAuthentication: true,
      files: params.photos,
      fileKey: 'Files',
      data: params.toJson(),
      url: uploadManyDocumentUrl,
      method: HttpMethod.POST,
      converter2: (json) {
        return List<DocumentModel>.from(
          json.map((x) => DocumentModel.fromJson(x)),
        );
      },
    );

    return call(result: result);
  }
}
