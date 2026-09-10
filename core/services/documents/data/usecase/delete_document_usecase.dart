 
import '../../../../params/base_params.dart';
import '../../../../results/result.dart';
import '../../../../usecase/usecase.dart';
import '../repository/repo.dart';

class DeleteDocumentParams extends BaseParams {
  final String id;

  DeleteDocumentParams({required this.id});
}

class DeleteDocumentUseCase extends UseCase<String, DeleteDocumentParams> {
  final DocumentRepository repository;

  DeleteDocumentUseCase(this.repository);

  @override
  Future<Result<String>> call({required DeleteDocumentParams params}) {
    return repository.deleteDocumentRequest(params: params);
  }
}
