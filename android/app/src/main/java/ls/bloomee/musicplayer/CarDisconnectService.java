package ls.bloomee.musicplayer;

import io.flutter.plugin.common.MethodChannel;

public class CarDisconnectService {
    public static MethodChannel channel;

    public static void sendDisconnectEvent() {
        if (channel != null) {
            channel.invokeMethod("carDisconnect", null);
        }
    }
}
