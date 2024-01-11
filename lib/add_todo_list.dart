import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddToDoList extends StatefulWidget {
  final Map? todo;
  const AddToDoList({super.key, this.todo});

  @override
  State<AddToDoList> createState() => _AddToDoListState();
}

class _AddToDoListState extends State<AddToDoList> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  bool isEdit = false;
  @override
  void initState() {
    final todo = widget.todo;
    super.initState();
    if (todo != null) {
      isEdit = true;
      final title = todo['title'];
      final description = todo['description'];
      titleController.text = title;
      descriptionController.text = description;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: isEdit ? const Text("Edit To DO") : const Text("Add To DO"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: titleController,
            decoration: const InputDecoration(
              hintText: "Title",
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          TextField(
            controller: descriptionController,
            minLines: 5,
            maxLines: 8,
            keyboardType: TextInputType.multiline,
            decoration: const InputDecoration(
              hintText: "Description",
            ),
          ),
          const SizedBox(
            height: 12,
          ),
          ElevatedButton(
            onPressed: () {
              isEdit ? updateData() : submitData();
            },
            child: Text(isEdit ? "Update " : "Submit"),
          ),
        ],
      ),
    );
  }

  Future<void> updateData() async {
    final todo = widget.todo;
    if (todo == null) {
      print('you can not call updated w/o todo data');
      return;
    }
    final id = todo['_id'];
    String title = titleController.text;
    String description = descriptionController.text;
    final body = {
      "title": title,
      "description": description,
      "is_completed": false,
    };

    //submit the data to server
    final url = "https://api.nstack.in/v1/todos/$id";
    final uri = Uri.parse(url);
    final response = await http.put(
      uri,
      body: jsonEncode(body),
      headers: {
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      print("success");
      // titleController.text = "";
      // descriptionController.text = "";
      showScaffoldMessenger('success');
      print(response.body);
    } else {
      print("Failed");
      showScaffoldMessenger("Failed");
    }
  }

  Future<void> submitData() async {
    //get the data from textfields
    String title = titleController.text;
    String description = descriptionController.text;
    final body = {
      "title": title,
      "description": description,
      "is_completed": false,
    };

    //submit the data to server
    const url = "https://api.nstack.in/v1/todos";
    final uri = Uri.parse(url);
    final response = await http.post(
      uri,
      body: jsonEncode(body),
      headers: {
        'Content-Type': 'application/json',
      },
    );
    //show success message or failed message to send server
    if (response.statusCode == 201) {
      print("success");
      titleController.text = "";
      descriptionController.text = "";
      showScaffoldMessenger('success');
      print(response.body);
    } else {
      print("Failed");
      showScaffoldMessenger("Failed");
    }
  }

  void showScaffoldMessenger(String message) {
    Color snackBarColor = Colors.white; // Default color for success

    if (message.toLowerCase() == "failed") {
      snackBarColor = Colors.red; // Change color to red for failure
    }

    final snackbar = SnackBar(
      backgroundColor: snackBarColor,
      content: Text(
        message,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }
}
