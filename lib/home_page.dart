import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:to_do_api/add_todo_list.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = true;
  List items = [];
  @override
  void initState() {
    super.initState();
    fetchToDoList();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 10,
          centerTitle: true,
          title: const Text("To-Do List"),
        ),
        body: Visibility(
          visible: isLoading,
          child: Center(child: CircularProgressIndicator()),
          replacement: RefreshIndicator(
            onRefresh: fetchToDoList,
            child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final id = item["_id"] as String;
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text('${index + 1}'),
                    ),
                    title: Text(item['title']),
                    subtitle: Text(item['description']),
                    trailing: PopupMenuButton(
                      onSelected: (value) {
                        if (value == 'edit') {
                          navigateToEditPage(item);
                          // editbyId(id);
                          //delete the task & remove from the list
                        } else if (value == 'delete') {
                          //edit the task & show updated task
                          deletebyID(id);
                        }
                      },
                      itemBuilder: (context) {
                        return [
                          const PopupMenuItem(
                            child: Text("Edit"),
                            value: 'edit',
                          ),
                          const PopupMenuItem(
                            child: Text("Delete"),
                            value: 'delete',
                          ),
                        ];
                      },
                    ),
                  );
                }),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
            label: const Text("Add To-Do"),
            onPressed: () {
              navigateToAddPage();
            }),
      ),
    );
  }

  void navigateToEditPage(Map item) async {
    final route = MaterialPageRoute(
      builder: (context) => AddToDoList(todo: item),
    );
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    fetchToDoList();
  }

  void navigateToAddPage() async {
    final route = MaterialPageRoute(
      builder: (context) => AddToDoList(),
    );
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });

    fetchToDoList();
  }

  Future<void> deletebyID(String id) async {
    //delete the item
    final url = "https://api.nstack.in/v1/todos/$id";
    final uri = Uri.parse(url);
    final response = await http.delete(uri);
    if (response.statusCode == 200) {
      final filtered = items.where((element) => element['_id'] != id).toList();
      setState(() {
        items = filtered;
      });
      //remove the item
    } else {
      //show the error
    }
  }

  Future<void> fetchToDoList() async {
    const url = "https://api.nstack.in/v1/todos?page=1&limit=20";
    final uri = Uri.parse(url);
    final repsonse = await http.get(uri);
    // final json = jsonDecode(repsonse.body) as Map;
    // final result = json['items'] as List;
    if (repsonse.statusCode == 200) {
      final json = jsonDecode(repsonse.body) as Map;
      final result = json['items'] as List;
      setState(() {
        items = result;
        isLoading = false;
      });
    } else {
      print(repsonse.statusCode);
    }
  }

  @override
  void setState(VoidCallback fn) {
    isLoading = false;
    super.setState(fn);
  }
}
