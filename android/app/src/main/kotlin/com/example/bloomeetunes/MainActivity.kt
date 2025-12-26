package ls.bloomee.musicplayer

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Register the MethodChannel so Java can send events to Flutter
        CarDisconnectService.channel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "bloomee/car_disconnect"
        )
    }
}
