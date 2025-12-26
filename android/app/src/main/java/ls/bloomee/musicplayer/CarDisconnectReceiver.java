package ls.bloomee.musicplayer;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.util.Log;

public class CarDisconnectReceiver extends BroadcastReceiver {

    @Override
    public void onReceive(Context context, Intent intent) {
        String action = intent.getAction();

        Log.d("CarDisconnectReceiver", "Received: " + action);

        if (action == null) return;

        // USB unplugged
        if (action.equals(Intent.ACTION_POWER_DISCONNECTED)) {
            CarDisconnectService.sendDisconnectEvent();
        }

        // USB state changed (covers many car disconnect cases)
        if (action.equals("android.hardware.usb.action.USB_STATE")) {
            boolean connected = intent.getExtras() != null &&
                    intent.getExtras().getBoolean("connected", false);

            if (!connected) {
                CarDisconnectService.sendDisconnectEvent();
            }
        }

        // Android Auto disconnected
        if (action.equals("com.google.android.gms.car.DISCONNECTED")) {
            CarDisconnectService.sendDisconnectEvent();
        }
    }
}
