package com.ultimate_hid
import android.bluetooth.*
import android.content.Context
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.ultimate_hid.bluetooth/hid"
    private var bluetoothHidDevice: BluetoothHidDevice? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startHidService" -> { setupBluetoothHid(); result.success(true) }
                "sendHidKey" -> { sendKeyReport(call.argument<String>("key")); result.success(true) }
                "sendMouseMove" -> { sendMouseReport(call.argument<Double>("dx") ?: 0.0, call.argument<Double>("dy") ?: 0.0); result.success(true) }
                else -> result.notImplemented()
            }
        }
    }

    private fun setupBluetoothHid() {
        val adapter = BluetoothAdapter.getDefaultAdapter()
        adapter?.getProfileProxy(this, object : BluetoothProfile.ServiceListener {
            override fun onServiceConnected(profile: Int, proxy: BluetoothProfile) {
                if (profile == BluetoothProfile.HID_DEVICE) {
                    bluetoothHidDevice = proxy as BluetoothHidDevice
                    val sdp = BluetoothHidDeviceAppSdpSettings.Builder()
                        .setProductName("Ultimate Remote").setAppearance(BluetoothHidDevice.Appearance.KEYBOARD).build()
                    bluetoothHidDevice?.registerApp(sdp, null, null, Context.MODE_PRIVATE, object : BluetoothHidDevice.Callback() {
                        override fun onConnectionStateChanged(device: BluetoothDevice, state: Int) {
                            val status = if (state == BluetoothProfile.STATE_CONNECTED) "connected" else "disconnected"
                            MethodChannel(this@MainActivity, CHANNEL).invokeMethod("onStatusChanged", status)
                        }
                    })
                }
            }
            override fun onServiceDisconnected(profile: Int) {}
        }, BluetoothProfile.HID_DEVICE)
    }

    private fun sendKeyReport(key: String?) {
        val keyMap = mapOf("ENTER" to 0x28.toByte(), "SPACE" to 0x2C.toByte(), "A" to 0x04.toByte())
        val keyCode = keyMap[key?.uppercase()] ?: 0x00.toByte()
        bluetoothHidDevice?.sendReport(null, 1, byteArrayOf(0x00, 0x00, keyCode, 0x00, 0x00, 0x00, 0x00, 0x00))
        Thread.sleep(20)
        bluetoothHidDevice?.sendReport(null, 1, byteArrayOf(0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00))
    }

    private fun sendMouseReport(dx: Double, dy: Double) {
        bluetoothHidDevice?.sendReport(null, 2, byteArrayOf(0x00, dx.toInt().toByte(), dy.toInt().toByte(), 0x00, 0x00))
    }
}
