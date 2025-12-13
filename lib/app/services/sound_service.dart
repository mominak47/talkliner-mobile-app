import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static final AudioPlayer _audioPlayer = AudioPlayer();

  static Future<void> playMessageReceived() async {
    await _audioPlayer.play(AssetSource('audio/message-received.mp3'));
  }

  static void dispose() {
    _audioPlayer.dispose();
  }
}
