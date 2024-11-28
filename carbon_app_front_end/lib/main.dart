import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: ListView.builder(
            itemCount: 100,
            itemBuilder: (context, index) => ListTile(
                  title: Text(index.toString()),
                )),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color.fromARGB(255, 155, 213, 157),
        appBar: AppBar(
            title: const Text(
              "My App Bar",
              style: TextStyle(
                color: Colors.white, // 設置文字顏色為白色
              ),
            ),
            backgroundColor: const Color.fromARGB(255, 88, 140, 89),
            elevation: 0,
            leading: const Icon(
              Icons.menu,
              color: Colors.white,
            ),
            actions: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.logout),
                color: Colors.white,
              )
            ]),
        body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Container(
              height: 300,
              width: 300,
              decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 88, 140, 89),
                  borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.all(25),
              child: const Icon(
                Icons.favorite,
                color: Color.fromARGB(255, 255, 255, 255),
                size: 64,
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 88, 140, 89),
                  borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.all(25),
              child: const Icon(
                Icons.favorite,
                color: Color.fromARGB(255, 255, 255, 255),
                size: 64,
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 88, 140, 89),
                  borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.all(25),
              child: const Icon(
                Icons.favorite,
                color: Color.fromARGB(255, 255, 255, 255),
                size: 64,
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
