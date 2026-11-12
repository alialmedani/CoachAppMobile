import 'package:coachappmobile/core/constant/end_points/api_url.dart';
import 'package:coachappmobile/core/data_source/remote_data_source.dart';
import 'package:coachappmobile/core/http/http_method.dart';
import 'package:coachappmobile/core/repository/core_repository.dart';
import 'package:coachappmobile/core/results/result.dart';
import 'package:coachappmobile/features/coach/exercises/data/model/exercise_model.dart';

/// HTTP boundary for the trainee's read-only view of a single exercise's
/// details (`My*` API). `GET /{id}` returns the same `ExerciseDto` the coach
/// endpoint does, so [ExerciseModel] is reused. The server 404s if the exercise
/// isn't visible to the caller, surfaced as a `Result` error.
class MyExerciseRepository extends CoreRepository {
  Future<Result<ExerciseModel>> getExerciseRequest(String id) async {
    final result = await RemoteDataSource.request<ExerciseModel>(
      withAuthentication: true,
      url: '$myExerciseUrl/$id',
      method: HttpMethod.GET,
      converter: (json) => ExerciseModel.fromJson(json),
    );
    return call(result: result);
  }
}
