import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bnood/features/clients/data/clients_providers.dart';
import 'package:bnood/features/clients/presentation/models/client_detail_snapshot.dart';
import 'package:bnood/features/projects/domain/project_detail_params.dart';
import 'project_detail_loader.dart';

final projectDetailProvider =
    AsyncNotifierProvider.family<
      ProjectDetailNotifier,
      ClientDetailSnapshot,
      ProjectDetailParams
    >(ProjectDetailNotifier.new);

class ProjectDetailNotifier
    extends FamilyAsyncNotifier<ClientDetailSnapshot, ProjectDetailParams> {
  int _reloadSeq = 0;

  @override
  Future<ClientDetailSnapshot> build(ProjectDetailParams arg) =>
      loadProjectDetailSnapshot(ref, arg);

  Future<void> refreshSilently() async {
    final previous = state.valueOrNull;
    final seq = ++_reloadSeq;
    if (previous != null) {
      state = AsyncValue<ClientDetailSnapshot>.loading().copyWithPrevious(
        AsyncValue.data(previous),
      );
    } else if (!state.hasValue) {
      state = const AsyncValue.loading();
    }
    try {
      final next = await loadProjectDetailSnapshot(ref, arg);
      if (seq != _reloadSeq) return;
      state = AsyncValue.data(next);
    } catch (error, stackTrace) {
      if (seq != _reloadSeq) return;
      if (previous != null) {
        state = AsyncValue<ClientDetailSnapshot>.error(
          error,
          stackTrace,
        ).copyWithPrevious(AsyncValue.data(previous));
      } else {
        state = AsyncValue.error(error, stackTrace);
      }
    }
  }
}

void refreshProjectDetail(WidgetRef ref, ProjectDetailParams params) {
  ref.read(projectDetailProvider(params).notifier).refreshSilently();
}

/// Resolves the primary project for legacy routes keyed by client id only.
Future<ProjectDetailParams> primaryProjectParamsForClient(
  Ref ref,
  String clientId,
) async {
  final record = await ref.read(clientsRepositoryProvider).getClient(clientId);
  return (clientId: clientId, projectId: record.project.id);
}