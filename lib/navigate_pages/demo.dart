import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class DemoClass extends StatefulWidget {
  @override
  _DemoClassState createState() => _DemoClassState();

  const DemoClass({Key? key}) : super(key: key);
}

class _DemoClassState extends State<DemoClass> {
  final textController = TextEditingController();
  final databaseRef = FirebaseDatabase.instance.reference();
  String? val;
  void createData(name, number) {
    databaseRef.child("Users").push().set({'name': name, 'number': number});
  }

  void readData() {
    databaseRef.once().then((DataSnapshot snapshot) {
      print(snapshot.value);
    });
  }

  void updateData(title, data) {
    databaseRef.child("Users").update({'name': name, 'number': number});
  }

  void deleteData(title) {
    databaseRef.remove();
  }

  String? name, number;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Firebase Demo"),
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: const InputDecoration(
                    label: Text('name'),
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    name = value;
                  },
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: const InputDecoration(label: Text('number'), border: InputBorder.none),
                  onChanged: (value) {
                    number = value;
                  },
                ),
              ),
            ),
          ),
          ElevatedButton(
              onPressed: () {
                createData(name, number);
              },
              child: const Text('Add Data')),
          ElevatedButton(
              onPressed: () {
                readData();
              },
              child: const Text('read Data')),
          ElevatedButton(
              onPressed: () {
                deleteData(name);
              },
              child: const Text('delete Data')),
          ElevatedButton(
              onPressed: () {
                updateData(name, number);
              },
              child: const Text('update Data')),
        ],
      ),
    );
  }
}
