import 'package:bloc/bloc.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:todo/Todo%20App/cubit/cubit.dart';

Widget defaultFormField({
  required TextEditingController controller,
  required TextInputType type,
  required FormFieldValidator validate,
  VoidCallback? onSubmitted,
  required ValueChanged<String> onChange,
  VoidCallback? onTap,
  required String label,
  required IconData prefix,
}) =>
    TextFormField(
      controller: controller,
      validator: (value) => validate(value),
      // onFieldSubmitted: (value) => onSubmitted!(value),
      onChanged: (value) => onChange(value),
      onFieldSubmitted: onSubmitted != null ? (value) => onSubmitted() : null,
      onTap: () => onTap!(),
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(prefix),
        border: const OutlineInputBorder(),
      ),
    );

Widget buildTasks(Map model, context) {
  return Dismissible(
    key: Key(model['id'].toString()),
    child: Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 35,
            child: Text('${model['time']}'),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text('${model['title']}',
                  style: const TextStyle(
                    fontSize: 20,
                  )),
              Text('${model['date']}',
                  style: const TextStyle(
                      fontSize: 17,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold)),
            ]),
          ),
          const SizedBox(width: 10),
          IconButton(
              onPressed: () {
                TodoCubit.get(context)
                    .updateDatabase(status: 'Done', id: model['id']);
              },
              icon: const Icon(Icons.check_box),
              color: Colors.green),
          IconButton(
            onPressed: () {
              TodoCubit.get(context)
                  .updateDatabase(status: 'Archived', id: model['id']);
            },
            icon: const Icon(Icons.archive),
            color: Colors.red,
          )
        ],
      ),
    ),
    onDismissed: (direction) {
      TodoCubit.get(context).deleteData(id: model['id']);
    },
  );
}

Widget taskBuilder({required List<Map> tasks}) => ConditionalBuilder(
      condition: tasks.isNotEmpty,
      builder: (context) => ListView.separated(
          itemBuilder: (context, int index) =>
              buildTasks(tasks[index], context),
          separatorBuilder: (context, index) =>
              const Divider(height: 1, color: Colors.grey),
          itemCount: tasks.length),
      fallback: (context) => const Center(
        child: Text('No Tasks yet, Please add some tasks .. ',maxLines: 3,
            style: TextStyle(color: Colors.deepOrange,fontSize: 20, fontWeight: FontWeight.bold)),
      ),
    );

class MyBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    print('onCreate -- ${bloc.runtimeType}');
  }

  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    print('onEvent -- ${bloc.runtimeType}, $event');
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    print('onChange -- ${bloc.runtimeType}, $change');
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print('onTransition -- ${bloc.runtimeType}, $transition');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    print('onError -- ${bloc.runtimeType}, $error');
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    print('onClose -- ${bloc.runtimeType}');
  }
}

