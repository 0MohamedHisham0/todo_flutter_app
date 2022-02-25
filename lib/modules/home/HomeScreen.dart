import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/shared/componets/components.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>  {
  List<Map> dbList = [];
  List<Map> todoList = [];
  List<Map> doneList = [];
  var scaffoldKey = GlobalKey<ScaffoldState>();
  var formKey = GlobalKey<FormState>();
  var taskController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    getTaskDB();
    return SafeArea(
      child: Scaffold(
          key: scaffoldKey,
          floatingActionButton: FloatingActionButton(
            child: chooseIconForFloating(),
            onPressed: () {
              if (formKey.currentState != null) {
                if (formKey.currentState!.validate()) {
                  Map map = {};
                  map["taskTitle"] = taskController.text;
                  map["taskState"] = "ToDo";
                  addNewTask(map);
                } else {
                  scaffoldKey.currentState
                      ?.showBottomSheet((context) =>
                      Container(
                        height: 200,
                        color: Colors.white,
                        padding: const EdgeInsets.all(16.0),
                        child: Form(
                          key: formKey,
                          child: Column(
                            children: [
                              const Text(
                                "Add your Task",
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              defaultTextField(
                                label: "Your Task",
                                controller: taskController,
                                prefixIcon: Icons.add_task,
                                validate: (value) {
                                  if (value
                                      .toString()
                                      .isEmpty) {
                                    return 'title must not be empty';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ));
                }
              } else {
                scaffoldKey.currentState
                    ?.showBottomSheet((context) =>
                    Container(
                      height: 200,
                      color: Colors.white,
                      padding: const EdgeInsets.all(16.0),
                      child: Form(
                        key: formKey,
                        child: Column(
                          children: [
                            const Text(
                              "Add your Task",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            defaultTextField(
                              label: "Your Task",
                              controller: taskController,
                              prefixIcon: Icons.add_task,
                              validate: (value) {
                                if (value
                                    .toString()
                                    .isEmpty) {
                                  return 'title must not be empty';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ));
              }
            },
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //ToDo Tasks
                const Text(
                  "ToDo Tasks",
                  style: TextStyle(fontSize: 20.0, color: Colors.black),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Divider(
                  height: 2,
                ),
                const SizedBox(
                  height: 10,
                ),
                Expanded(
                  child: ListView.separated(
                      itemBuilder: (context, index) {
                        return taskItem(todoList[index]);
                      },
                      separatorBuilder: (context, index) {
                        return const Divider(
                          height: 2,
                        );
                      },
                      itemCount: todoList.length),
                ),

                //Done Tasks
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  "Done Tasks",
                  style: TextStyle(fontSize: 20.0, color: Colors.green),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Divider(
                  height: 2,
                ),
                Expanded(
                  child: ListView.separated(
                      itemBuilder: (context, index) {
                        return taskItem(doneList[index]);
                      },
                      separatorBuilder: (context, index) {
                        return const Divider(
                          height: 2,
                        );
                      },
                      itemCount: doneList.length),
                ),
              ],
            ),
          )),
    );
  }

  Widget taskItem(Map map) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            IconButton(
              icon: Icon(map['taskState'] == "ToDo"
                  ? Icons.circle_outlined
                  : Icons.check_circle),
              onPressed: () {
                if (map['taskState'] == "ToDo") {
                  setState(() {
                    Fluttertoast.showToast(
                        msg: "Task Done",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0);
                    var map2 = {};
                    map2['taskTitle'] = map['taskTitle'];
                    map2['taskState'] = "Done";
                    map2['id'] = map['id'];
                    updateTask(map2);
                    doneList.add(map2);
                    todoList.remove(map);
                  });
                } else {
                  Fluttertoast.showToast(
                      msg: "You already fished this task",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0);
                }
              },
            ),
            const SizedBox(
              width: 10,
            ),
            Text(
              map["taskTitle"].toString(),
              style: const TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }

  Future<Database> getTaskDB() async {
    // open the database
    Database database = await openDatabase('tasks.db', version: 1,
        onCreate: (Database db, int version) async {
          // When creating the db, create the table
          await db.execute(
              'CREATE TABLE Tasks (id INTEGER PRIMARY KEY, taskTitle TEXT, taskState TEXT)');
        });
    setState(() {
      rearrangeLists();
    });

    dbList = (await database.rawQuery('SELECT * FROM Tasks'));
    return database;
  }

  void rearrangeLists() {
    doneList = [];
    todoList = [];

    for (Map i in dbList) {
      if (i["taskState"] == "Done") {
        doneList.add(i);
      } else {
        todoList.add(i);
      }
    }
  }

  Future<void> addNewTask(Map map) async {
    await getTaskDB().then((txn) async {
      await txn.rawInsert(
          'INSERT INTO Tasks (taskTitle, taskState) VALUES("${map['taskTitle']}","${map['taskState']}")');
    });
  }

  Future<void> updateTask(Map map) async {
    await getTaskDB().then((value) =>
        value.rawUpdate(
            'UPDATE Tasks SET taskState = ?, taskTitle = ? WHERE id = ?',
            ['${map['taskState']}', '${map['taskTitle']}', '${map['id']}']));
  }

  Widget chooseIconForFloating() {
    if (formKey.currentState != null) {
      if (!formKey.currentState!.validate()) {
        return const Icon(Icons.add);
      } else {
        return const Icon(Icons.done);
      }
    } else {
      return const Icon(Icons.add);
    }
  }

  Future<void> removeTask(Map task) async {
    await getTaskDB().then((value) =>
        value.rawDelete('DELETE FROM Tasks WHERE id = ?', ['${task['id']}']));
  }
}
