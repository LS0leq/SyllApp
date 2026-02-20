import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/usecases/analyze_rhymes.dart';
import '../../../core/settings/settings_providers.dart';
import 'editor_infra_providers.dart';
import 'editor_notifier.dart';
import 'rhyme_state.dart';

final rhymeNotifierProvider =
    NotifierProvider<RhymeNotifier, RhymeState>(RhymeNotifier.new);


class RhymeNotifier extends Notifier<RhymeState> {
  Timer? _debounce;

  AnalyzeRhymesUseCase get _analyzeRhymes => ref.read(analyzeRhymesUseCaseProvider);

  @override
  RhymeState build() {
    ref.listen(
      editorNotifierProvider.select((s) => s.content),
      (previous, next) => _onContentChanged(next),
      fireImmediately: true,
    );

    ref.onDispose(() {
      _debounce?.cancel();
    });

    return const RhymeState();
  }

  void _onContentChanged(String text) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _analyze(text);
    });
  }

  Future<void> _analyze(String text) async {
    if (text.isEmpty) {
      state = const RhymeState();
      return;
    }

    final settings = ref.read(settingsNotifierProvider);
    final result = await _analyzeRhymes.call(
      AnalyzeRhymesParams(
        text: text,
        threshold: settings.rhymeThreshold,
        enableAssonance: settings.enableAssonance,
      ),
    );

    if (ref.mounted) {
      state = RhymeState(stanzaRhymes: result.stanzaRhymes);
    }
  }
}
