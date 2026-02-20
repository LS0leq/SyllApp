
class RhymeState {
  
  final Map<int, Map<String, int>> stanzaRhymes;

  const RhymeState({this.stanzaRhymes = const {}});

  RhymeState copyWith({
    Map<int, Map<String, int>>? stanzaRhymes,
  }) {
    return RhymeState(
      stanzaRhymes: stanzaRhymes ?? this.stanzaRhymes,
    );
  }
}
