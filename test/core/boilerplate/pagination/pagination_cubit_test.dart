import 'package:bloc_test/bloc_test.dart';
import 'package:coachappmobile/core/boilerplate/pagination/cubits/pagination_cubit.dart'
    as pg;
import 'package:coachappmobile/core/results/result.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests the P18 error-state distinction in [pg.PaginationCubit]: an initial
/// (first-page) failure surfaces a full-screen [pg.Error], while a load-more
/// (next-page) failure keeps the loaded list and surfaces [pg.LoadMoreError]
/// with the page cursor rolled back so a retry re-fetches the same page.
void main() {
  // First page (skip 0) succeeds with [1,2]; any next page (skip > 0) fails.
  pg.RepositoryCallBack firstPageOkThenFail() => (data) async {
    final skip = (data.skip as int?) ?? 0;
    if (skip == 0) return Result<List<int>>(data: [1, 2]);
    return Result<List<int>>(error: 'boom');
  };

  group('initial load', () {
    blocTest<pg.PaginationCubit<int>, pg.PaginationState>(
      'success emits Loading then GetListSuccessfully with the page',
      build: () => pg.PaginationCubit<int>(firstPageOkThenFail()),
      act: (c) => c.getList(),
      expect: () => [isA<pg.Loading>(), isA<pg.GetListSuccessfully>()],
      verify: (c) => expect(c.list, [1, 2]),
    );

    blocTest<pg.PaginationCubit<int>, pg.PaginationState>(
      'first-page failure emits Error (full-screen), never LoadMoreError',
      build: () =>
          pg.PaginationCubit<int>((_) async => Result<List<int>>(error: 'x')),
      act: (c) => c.getList(),
      expect: () => [isA<pg.Loading>(), isA<pg.Error>()],
    );
  });

  group('load more', () {
    blocTest<pg.PaginationCubit<int>, pg.PaginationState>(
      'next-page failure keeps the list and emits LoadMoreError (not Error)',
      build: () => pg.PaginationCubit<int>(firstPageOkThenFail()),
      act: (c) async {
        await c.getList(); // page 0 → ok
        await c.getList(loadMore: true); // page 1 → fails
      },
      expect: () => [
        isA<pg.Loading>(),
        isA<pg.GetListSuccessfully>(),
        isA<pg.LoadMoreError>(),
      ],
      verify: (c) {
        expect(c.list, [1, 2], reason: 'loaded list is preserved');
        expect(c.skip, 0, reason: 'page cursor rolled back for a clean retry');
      },
    );

    test('LoadMoreError carries the still-visible list', () async {
      final cubit = pg.PaginationCubit<int>(firstPageOkThenFail());
      await cubit.getList();
      await cubit.getList(loadMore: true);
      final state = cubit.state;
      expect(state, isA<pg.LoadMoreError>());
      expect((state as pg.LoadMoreError).list, [1, 2]);
      await cubit.close();
    });
  });
}
