package com.example.bluetooth_camera_receiver

import android.Manifest
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothServerSocket
import android.bluetooth.BluetoothSocket
import android.content.pm.PackageManager
import android.os.Build
import android.util.Log
import androidx.core.app.ActivityCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.BufferedReader
import java.io.InputStreamReader
import java.util.UUID
import kotlin.concurrent.thread

class MainActivity : FlutterActivity() {

    companion object {
        // Yeh channel aapke Receiver main.dart ke MethodChannel se exact match hona chahiye
        private const val CHANNEL = "bluetooth_camera_receiver"
        private val APP_UUID = UUID.fromString("00001101-0000-1000-8000-00805F9B34FB")
        private const val APP_NAME = "BluetoothCameraReceiver"
    }

    private lateinit var channel: MethodChannel
    private var bluetoothAdapter: BluetoothAdapter? = null
    private var serverSocket: BluetoothServerSocket? = null
    private var isServerRunning = false

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        bluetoothAdapter = BluetoothAdapter.getDefaultAdapter()
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)

        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "startServer" -> {
                    startServer()
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
        startServer()
    }

    private fun startServer() {
        if (isServerRunning) return
        isServerRunning = true

        thread {
            if (bluetoothAdapter == null) {
                Log.e("BT_SERVER", "Bluetooth not supported")
                return@thread
            }

            try {
                // RFCOMM Server Socket Initialization
                serverSocket = bluetoothAdapter!!.listenUsingRfcommWithServiceRecord(APP_NAME, APP_UUID)
                Log.d("BT_SERVER", "RFCOMM Server Started. Waiting for connections...")

                // Continuous loop to accept multiple incoming connections safely
                while (isServerRunning) {
                    var socket: BluetoothSocket? = null
                    try {
                        socket = serverSocket?.accept()
                    } catch (e: Exception) {
                        Log.e("BT_SERVER", "Accept failed or server stopped")
                        break
                    }

                    if (socket != null) {
    Log.d("BT_SERVER", "Client Connected successfully!")

    runOnUiThread {
        channel.invokeMethod("onBluetoothConnected", true)
    }

    listen(socket)
}
                }
            } catch (e: Exception) {
                Log.e("BT_SERVER", "Server Loop Error", e)
            }
        }
    }

    private fun listen(socket: BluetoothSocket) {
        thread {
            try {
                val reader = BufferedReader(InputStreamReader(socket.inputStream, Charsets.UTF_8))
                while (isServerRunning && socket.isConnected) {
                    val command = reader.readLine()
                    if (command == null) {
                        Log.d("BT_SERVER", "Client disconnected")
                        break
                    }
                    
                    val trimmedCmd = command.trim().uppercase()
                    if (trimmedCmd.isNotEmpty()) {
                        Log.d("BT_SERVER", "CMD Received: $trimmedCmd")
                        
                        // CRITICAL UI BRIDGE: Background thread se data main thread par Flutter ko bheja
                        runOnUiThread {
                            channel.invokeMethod("onCommand", trimmedCmd)
                        }
                    }
                }
            } catch (e: Exception) {
                Log.e("BT_SERVER", "Connection read error/dropped", e)
            } finally {

    runOnUiThread {
        channel.invokeMethod("onBluetoothDisconnected", true)
    }

    try {
        socket.close()
    } catch (e: Exception) {}
}
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        isServerRunning = false
        try {
            serverSocket?.close()
        } catch (e: Exception) {}
    }
}