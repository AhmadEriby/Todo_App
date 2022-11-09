import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:todo/Todo%20App/cubit/cubit.dart';
import 'package:todo/Todo%20App/cubit/states.dart';
import '../reusable_component/reusable_components.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  var scaffoldKey = GlobalKey<ScaffoldState>();
  var formKey = GlobalKey<FormState>();
  TextEditingController titleController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  TextEditingController dateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (BuildContext context) => TodoCubit()..createDatabase(),
        child: BlocConsumer<TodoCubit, TodoStates>(
          listener: (BuildContext context, state) {
            if (state is TodoInsertToDBState) {
              Navigator.pop(context);
              titleController.clear();
              dateController.clear();
              timeController.clear();
              // TodoCubit.get(context).isBottomSheet = false;
            }
          },
          builder: (context, state) {
            return Scaffold(
              key: scaffoldKey,
              appBar: AppBar(
                backgroundColor: Colors.red,
                title: Text(TodoCubit.get(context)
                    .titles[TodoCubit.get(context).currentIndex]),
              ),
              bottomNavigationBar: BottomNavigationBar(
                  selectedItemColor: Colors.white,
                  unselectedItemColor: Colors.black54,
                  backgroundColor: Colors.red,
                  type: BottomNavigationBarType.fixed,
                  currentIndex: TodoCubit.get(context).currentIndex,
                  onTap: (index) {
                    TodoCubit.get(context).changeIndex(index);
                  },
                  items: const [
                    BottomNavigationBarItem(
                        icon: Icon(Icons.new_label), label: 'Tasks'),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.check_circle), label: 'Done'),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.archive), label: 'Archive'),
                  ]),
              body: ConditionalBuilder(
                condition: state is! TodoGetDBStateLoadingState,
                builder: (context) => TodoCubit.get(context)
                    .screens[TodoCubit.get(context).currentIndex],
                fallback: (context) => const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              floatingActionButton: FloatingActionButton(
                backgroundColor: Colors.redAccent,
                onPressed: () {
                  if (TodoCubit.get(context).isBottomSheet) {
                    if (formKey.currentState!.validate()) {
                      TodoCubit.get(context).insertToDatabase(
                          title: titleController.text,
                          time: timeController.text,
                          date: dateController.text);
                    }
                  } else {
                    scaffoldKey.currentState
                        ?.showBottomSheet(
                          (context) => Container(
                            padding: const EdgeInsetsDirectional.all(20),
                            child: Form(
                              key: formKey,
                              child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    defaultFormField(
                                      controller: titleController,
                                      type: TextInputType.text,
                                      validate: (value) {
                                        if (value.isEmpty) {
                                          return 'Title must not be empty';
                                        }
                                        return null;
                                      },
                                      label: 'Title Task',
                                      prefix: Icons.title,
                                      onTap: () {},
                                      onChange: (value) {},
                                    ),
                                    const SizedBox(
                                      height: 15,
                                    ),
                                    defaultFormField(
                                      controller: timeController,
                                      type: TextInputType.datetime,
                                      validate: (value) {
                                        if (value.isEmpty) {
                                          return 'Time must not be empty';
                                        }
                                        return null;
                                      },
                                      label: 'Task Time',
                                      prefix: Icons.calendar_today_outlined,
                                      onTap: () {
                                        showTimePicker(
                                                context: context,
                                                initialTime: TimeOfDay.now())
                                            .then((value) {
                                          timeController.text =
                                              value!.format(context);
                                        });
                                      },
                                      onChange: (value) {},
                                    ),
                                    const SizedBox(
                                      height: 15,
                                    ),
                                    defaultFormField(
                                      controller: dateController,
                                      type: TextInputType.datetime,
                                      validate: (value) {
                                        if (value.isEmpty) {
                                          return 'Date must not be empty';
                                        }
                                        return null;
                                      },
                                      label: 'Task Date',
                                      prefix: Icons.calendar_today_outlined,
                                      onTap: () {
                                        showDatePicker(
                                                context: context,
                                                initialDate: DateTime.now(),
                                                firstDate: DateTime.now(),
                                                lastDate:
                                                    DateTime(2030, 12, 31))
                                            .then((value) {
                                          dateController.text =
                                              DateFormat.yMMMd().format(value!);
                                        });
                                      },
                                      onChange: (value) {},
                                    ),
                                  ]),
                            ),
                          ),
                          elevation: 20,
                        )
                        .closed
                        .then((value) {
                      TodoCubit.get(context).changeBottomSheetState(
                          isShow: false, icon: Icons.edit);
                    });
                    TodoCubit.get(context).changeBottomSheetState(
                        isShow: true, icon: Icons.add_task);
                  }
                },
                child: Icon(TodoCubit.get(context).fabIcon),
              ),
            );
          },
        ));
  }
}
