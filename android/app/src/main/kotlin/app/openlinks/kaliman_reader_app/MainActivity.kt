package app.openlinks.kaliman_reader_app

import android.os.Bundle
import android.view.KeyEvent
import android.view.View
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    // Channel name must match the Dart side
    private val CHANNEL = "app.openlinks.kaliman_reader_app/buttons"
    private lateinit var volumeChannel: MethodChannel

    override fun configureFlutterEngine(flutterEngine: io.flutter.embedding.engine.FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Set up the MethodChannel to communicate with Flutter
        volumeChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
    }

    override fun onKeyDown(keyCode: Int, event: KeyEvent?): Boolean {
        if (keyCode == KeyEvent.KEYCODE_VOLUME_UP) {
            volumeChannel.invokeMethod("volume_button", "VOLUME_UP")
            return true  // Consume event, prevent system volume change
        } else if (keyCode == KeyEvent.KEYCODE_VOLUME_DOWN) {
            volumeChannel.invokeMethod("volume_button", "VOLUME_DOWN")
            return true  // Consume event, prevent system volume change
        }
        return super.onKeyDown(keyCode, event)  // Allow other key events to propagate normally
    }
}
