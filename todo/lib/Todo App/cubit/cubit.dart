import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo/Todo%20App/cubit/states.dart';
import '../archive_tasks/archive_tasks_screen.dart';
import '../done_tasks/done_task_screen.dart';
import '../new_tasks/new_task_screen.dart';

class TodoCubit extends Cubit<TodoStates> {
  TodoCubit() : super(TodoInitialState());

  bool isBottomSheet = false;
  IconData fabIcon = Icons.edit;
  late Database database;
  List<Map> newTasks = [];
  List<Map> doneTasks = [];
  List<Map> archivedTasks = [];
  int currentIndex = 0;
  List<Widget> screens = [
    const NewTasksScreen(),
    const DoneTasksScreen(),
    const ArchiveTasksScreen()
  ];

  List<String> titles = ['New Tasks', 'Done Tasks', 'Archive Tasks'];

  static TodoCubit get(context) => BlocProvider.of(context);

  void changeIndex(int index) {
    currentIndex = index;
    emit(TodoChangeNavBarState());
  }

  void createDatabase() async {
    openDatabase(
      'todo.db',
      version: 1,
      onCreate: (database, version) {
        print('Database created');
        database
            .execute(
                'CREATE TABLE Tasks (id INTEGER PRIMARY KEY, title TEXT,date TEXT,time TEXT,status TEXT)')
            .then((value) {
          print('Table created');
        }).catchError((onError) {
          print('Error${onError.toString()}');
        });
      },
      onOpen: (database) {
        getDataFromDB(database);
        print('Database opened');
      },
    ).then((value) {
      database = value;
      emit(TodoCreateDBState());
      getDataFromDB(database);
    });
  }

  void insertToDatabase({
    required String title,
    required String time,
    required String date,
  }) async {
    database.transaction((txn) async {
      txn
          .rawInsert(
              'INSERT INTO Tasks(title,date,time,status) VALUES ("$title","$date","$time","new")')
          .then((value) {
        print('$value inserted successfully');
        emit(TodoInsertToDBState());
        getDataFromDB(database);
      }).catchError((onError) {
        print('Error${onError.toString()}');
      });
    });
  }

  void getDataFromDB(database) {
    newTasks=[];
    doneTasks=[];
    archivedTasks=[];
    emit(TodoGetDBStateLoadingState());
    database.rawQuery('SELECT * FROM Tasks').then((value) {
      value.forEach((element) {
        if (element['status'] == "new") {
          newTasks.add(element);
        } else if (element['status'] == "Done") {
          doneTasks.add(element);
        } else {
          archivedTasks.add(element);
        }
      });
      emit(TodoGetDBState());
    });
  }
  void updateDatabase({required String status, required int id}) async {
    database.rawUpdate(
        'UPDATE Tasks SET status = ? WHERE id = ?', [status, id]).then((value) {
      getDataFromDB(database);
      emit(TodoUpdateDBState());
    });
  }

  void deleteData({required int id}) async {
    database.rawDelete(
        'DELETE FROM Tasks  WHERE id = ?', [ id]).then((value) {
      getDataFromDB(database);
      emit(TodoDeleteDBState());
    });
  }

  void changeBottomSheetState({required bool isShow, required IconData icon}) {
    isBottomSheet = isShow;
    fabIcon = icon;
    emit(TodoChangeBottomSheetState());
  }
}
