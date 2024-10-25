import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  double downloadProgress = 0.0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  Future<void> downloadFile() async {
    // Firebase URL
    const url = 'https://firebasestorage.googleapis.com/v0/b/tmcmobileapp-496ce.appspot.com/o/Training%20Modules%2FM1%20-%20Research%20101.pptx?alt=media&token=ff63b7ac-053a-4888-ac9e-9797ad5f89d1';

    // Check permissions and request if necessary
    if (await requestPermission()) {
      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) {
        print("Unable to access storage directory.");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to access storage directory")),
        );
        return;
      }

      // Define the path where the file will be saved
      String savePath = '${directory.path}/M1 - Research 101.pptx';
      print("Saving file to: $savePath");

      try {
        Dio dio = Dio();
        await dio.download(
          url,
          savePath,
          onReceiveProgress: (received, total) {
            if (total != -1) {
              setState(() {
                downloadProgress = received / total;
              });
              print("Download progress: ${(received / total * 100).toStringAsFixed(0)}%");
            }
          },
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Download completed! File saved to $savePath")),
        );
      } catch (e) {
        print("Download failed: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Download failed: $e")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Storage permission denied")),
      );
    }
  }

  Future<bool> requestPermission() async {
    if (Platform.isAndroid) {
      // Check for Android SDK 30 and above
      if (Platform.isAndroid && (await Permission.manageExternalStorage.status.isDenied)) {
        await Permission.manageExternalStorage.request();
      }
    }
    
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
    }
    return status.isGranted;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            ElevatedButton(
              onPressed: downloadFile,
              child: const Text('Download PPTX'),
            ),
            SizedBox(height: 20),
            Text(
              'Download Progress: ${(downloadProgress * 100).toStringAsFixed(0)}%',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            LinearProgressIndicator(
              value: downloadProgress,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
