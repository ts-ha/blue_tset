import 'dart:async';

import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final flutterReactiveBle = FlutterReactiveBle();

// Some state management stuff
  bool _foundDeviceWaitingToConnect = false;
  bool _scanStarted = false;
  bool _connected = false;

// Bluetooth related variables
  late DiscoveredDevice _ubiqueDevice;

  late StreamSubscription<DiscoveredDevice> _scanStream;
  late QualifiedCharacteristic _rxCharacteristic;

// These are the UUIDs of your device
  final Uuid serviceUuid = Uuid.parse("75C276C3-8F97-20BC-A143-B354244886D4");
  final Uuid characteristicUuid =
      Uuid.parse("6ACF4F08-CC9D-D495-6B41-AA7E60C4E8A6");

  @override
  void initState() {
    super.initState();
    // _startScan();
    permissionServiceCall();
  }

  permissionServiceCall() async {
    await permissionServices().then(
      (value) {
        if (value[Permission.bluetoothScan]!.isGranted &&
            value[Permission.location]!.isGranted &&
            value[Permission.bluetoothConnect]!.isGranted
        /* &&
            value[Permission.bluetooth]!.isGranted*/) {
          _startScan();
          /* ========= New Screen Added  ============= */

          // Navigator.pushReplacement(
          //   context,
          //   MaterialPageRoute(builder: (context) => SplashScreen()),
          // );
        }
      },
    );
  }

  Future<Map<Permission, PermissionStatus>> permissionServices() async {
    // You can request multiple permissions at once.
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.bluetoothScan,
      Permission.bluetoothConnect
      /*Permission.bluetooth*/

      //add more permission to request here.
    ].request();

    if (statuses[Permission.location]!.isPermanentlyDenied) {
      openAppSettings();
      //setState(() {});
    } else {
      if (statuses[Permission.location]!.isDenied) {
        permissionServiceCall();
      }
    }
    if (statuses[Permission.bluetoothScan]!.isPermanentlyDenied) {
      openAppSettings();
      // setState(() {});
    } else {
      if (statuses[Permission.bluetoothScan]!.isDenied) {
        permissionServiceCall();
      }
    }if (statuses[Permission.bluetoothConnect]!.isPermanentlyDenied) {
      openAppSettings();
      // setState(() {});
    } else {
      if (statuses[Permission.bluetoothConnect]!.isDenied) {
        permissionServiceCall();
      }
    }

    /*if (statuses[Permission.bluetooth]!.isPermanentlyDenied) {
      openAppSettings();
      // setState(() {});
    } else {
      if (statuses[Permission.bluetooth]!.isDenied) {
        permissionServiceCall();
      }
    }*/
    /*{Permission.camera: PermissionStatus.granted, Permission.storage: PermissionStatus.granted}*/
    return statuses;
  }

  /*@override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        SystemNavigator.pop();
      },
      child: Scaffold(
        body: Container(
          child: Center(
            child: InkWell(
                onTap: () {
                  permissionServiceCall();
                },
                child: Text("Click here to enable Enable Permissions")),
          ),
        ),
      ),
    );
  }*/

  void _startScan() async {
// Platform permissions handling stuff
    bool permGranted = true;

// Main scanning logic happens here ⤵️
    if (permGranted) {
      _scanStream =
          flutterReactiveBle.scanForDevices(withServices: []).listen((device) {
        // Change this string to what you defined in Zephyr
        print('device.name ${device.name}');

        if (device.name == 'UBIQUE') {
          setState(() {
            _ubiqueDevice = device;
            _foundDeviceWaitingToConnect = true;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('BluetoothPrint example app'),
        ),
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextButton(
              onPressed: () {
                print("TextButton");
                _startScan();
              },
              child: const Text('fesf'),
            ),
            TextButton(
                onPressed: () {
                  permissionServiceCall();
                },
                child: const Text('perission Call'))
          ],
        ),
      ),
    );
  }
}
