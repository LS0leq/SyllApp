import '../../../../core/usecases/usecase.dart';
import '../entities/lyric.dart';


class UpdateLyricsUseCase implements UseCase<Lyric, UpdateLyricsParams> {
  
  @override
  Future<Lyric> call(UpdateLyricsParams params) async {
    final lyric = Lyric();
    lyric.updateFromLines(params.lines);
    return lyric;
  }
}

class UpdateLyricsParams {
  final List<String> lines;
  
  const UpdateLyricsParams({required this.lines});
  
  factory UpdateLyricsParams.fromText(String text) {
    return UpdateLyricsParams(lines: text.split('\n'));
  }
}
