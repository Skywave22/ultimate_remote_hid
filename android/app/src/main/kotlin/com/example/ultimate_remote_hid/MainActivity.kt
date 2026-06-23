package com.example.ultimate_remote_hid
import android.bluetooth.*
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executor

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.ultimate_hid.bluetooth/hid"
    private var bluetoothHidDevice: BluetoothHidDevice? = null
    private var methodChannel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        methodChannel!!.setMethodCallHandler { call, result ->
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
                    try {
                        // Build SDP settings - try multiple API approaches
                        val sdp = BluetoothHidDeviceAppSdpSettings(
                            "Ultimate Remote",
                            "Ultimate Remote HID",
                            "Ultimate",
                            BluetoothHidDevice.SUBCLASS1_COMBO,
                            byteArrayOf(
                                0x05.toByte(), 0x01.toByte(), // Usage Page (Generic Desktop)
                                0x09.toByte(), 0x06.toByte(), // Usage (Keyboard)
                                0xA1.toByte(), 0x01.toByte(), // Collection (Application)
                                0x05.toByte(), 0x07.toByte(), // Usage Page (Key Codes)
                                0x19.toByte(), 0xE0.toByte(), // Usage Minimum (224)
                                0x29.toByte(), 0xE7.toByte(), // Usage Maximum (231)
                                0x15.toByte(), 0x00.toByte(), // Logical Minimum (0)
                                0x25.toByte(), 0x01.toByte(), // Logical Maximum (1)
                                0x75.toByte(), 0x01.toByte(), // Report Size (1)
                                0x95.toByte(), 0x08.toByte(), // Report Count (8)
                                0x81.toByte(), 0x02.toByte(), // Input (Data, Variable, Absolute)
                                0x95.toByte(), 0x01.toByte(), // Report Count (1)
                                0x75.toByte(), 0x08.toByte(), // Report Size (8)
                                0x81.toByte(), 0x01.toByte(), // Input (Constant)
                                0x95.toByte(), 0x06.toByte(), // Report Count (6)
                                0x75.toByte(), 0x08.toByte(), // Report Size (8)
                                0x15.toByte(), 0x00.toByte(), // Logical Minimum (0)
                                0x25.toByte(), 0x65.toByte(), // Logical Maximum (101)
                                0x05.toByte(), 0x07.toByte(), // Usage Page (Key Codes)
                                0x19.toByte(), 0x00.toByte(), // Usage Minimum (0)
                                0x29.toByte(), 0x65.toByte(), // Usage Maximum (101)
                                0x81.toByte(), 0x00.toByte(), // Input (Data, Array)
                                0xC0.toByte() // End Collection
                            )
                        )
                        val executor = Executor { it.run() }
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                            bluetoothHidDevice?.registerApp(sdp, null, null, executor, object : BluetoothHidDevice.Callback() {
                                override fun onConnectionStateChanged(device: BluetoothDevice, state: Int) {
                                    val status = if (state == BluetoothProfile.STATE_CONNECTED) "connected" else "disconnected"
                                    runOnUiThread { methodChannel?.invokeMethod("onStatusChanged", status) }
                                }
                                override fun onAppStatusChanged(pluggedDevice: BluetoothDevice?, registered: Boolean) {
                                    super.onAppStatusChanged(pluggedDevice, registered)
                                }
                            })
                        } else {
                            bluetoothHidDevice?.registerApp(sdp, null, null, executor, object : BluetoothHidDevice.Callback() {
                                override fun onConnectionStateChanged(device: BluetoothDevice, state: Int) {
                                    val status = if (state == BluetoothProfile.STATE_CONNECTED) "connected" else "disconnected"
                                    runOnUiThread { methodChannel?.invokeMethod("onStatusChanged", status) }
                                }
                            })
                        }
                    } catch (e: Exception) {
                        e.printStackTrace()
                    }
                }
            }
            override fun onServiceDisconnected(profile: Int) {
                bluetoothHidDevice = null
            }
        }, BluetoothProfile.HID_DEVICE)
    }

    private fun sendKeyReport(key: String?) {
        try {
            val keyMap = mapOf(
                "ENTER" to 0x28.toByte(), "SPACE" to 0x2C.toByte(),
                "A" to 0x04.toByte(), "B" to 0x05.toByte(), "C" to 0x06.toByte(),
                "D" to 0x07.toByte(), "E" to 0x08.toByte(), "F" to 0x09.toByte(),
                "G" to 0x0A.toByte(), "H" to 0x0B.toByte(), "I" to 0x0C.toByte(),
                "J" to 0x0D.toByte(), "K" to 0x0E.toByte(), "L" to 0x0F.toByte(),
                "M" to 0x10.toByte(), "N" to 0x11.toByte(), "O" to 0x12.toByte(),
                "P" to 0x13.toByte(), "Q" to 0x14.toByte(), "R" to 0x15.toByte(),
                "S" to 0x16.toByte(), "T" to 0x17.toByte(), "U" to 0x18.toByte(),
                "V" to 0x19.toByte(), "W" to 0x1D.toByte(), "X" to 0x1B.toByte(),
                "Y" to 0x1C.toByte(), "Z" to 0x1D.toByte(),
                "VOL_UP" to 0x80.toByte(), "VOL_DOWN" to 0x81.toByte()
            )
            val keyCode = keyMap[key?.uppercase()] ?: 0x00.toByte()
            bluetoothHidDevice?.sendReport(null, 1, byteArrayOf(0x00, 0x00, keyCode, 0x00, 0x00, 0x00, 0x00, 0x00))
            Thread.sleep(20)
            bluetoothHidDevice?.sendReport(null, 1, byteArrayOf(0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00))
        } catch (e: Exception) { e.printStackTrace() }
    }

    private fun sendMouseReport(dx: Double, dy: Double) {
        try {
            bluetoothHidDevice?.sendReport(null, 2, byteArrayOf(0x00, dx.toInt().toByte(), dy.toInt().toByte(), 0x00))
        } catch (e: Exception) { e.printStackTrace() }
    }
}
