import 'package:flutter/material.dart';
import 'package:note_sphere/helpers/snackbar.dart';
import 'package:note_sphere/models/todo_model.dart';
import 'package:note_sphere/services/todo_service.dart';
import 'package:note_sphere/utils/colors.dart';
import 'package:note_sphere/utils/router.dart';
import 'package:note_sphere/widgets/todo_card.dart';

class TodoTab extends StatefulWidget {
  final List<Todo> incompletedTodos;
  final List<Todo> completedTodos;
  const TodoTab({
    super.key,
    required this.incompletedTodos,
    required this.completedTodos,
  });

  @override
  State<TodoTab> createState() => _TodoTabState();
}

class _TodoTabState extends State<TodoTab> {
  final TextEditingController _taskController = TextEditingController();

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  // Done කරන ලොජික් එක
  void _markAsDone(Todo todo) async {
    try {
      final updatedTodo = Todo(
        id: todo.id,
        title: todo.title,
        date: todo.date,
        time: todo.time,
        isDone: true,
      );
      await TodoService().markAsDone(
        updatedTodo,
      ); // කලින් සර්විස් එකේ updateTodo වගේ එකක්

      setState(() {
        widget.incompletedTodos.remove(todo);
        widget.completedTodos.add(updatedTodo);
      });

      AppRouter.router.go("/todos");

      AppHelpers.showSnackBar(context, "Marked as Done");
    } catch (e) {
      AppHelpers.showSnackBar(context, "Problem with Mark as Done");
    }
  }

  // Delete කරන ලොජික් එක
  void _deleteTodo(Todo todo) async {
    try {
      await TodoService().deleteTodo(todo);
      setState(() {
        widget.incompletedTodos.remove(todo);
      });
      AppHelpers.showSnackBar(context, "Todo Deleted");
    } catch (e) {
      AppHelpers.showSnackBar(context, "Error deleting todo");
    }
  }

  // Edit සේව් කරන ලොජික් එක
  void _saveEditTodo(Todo todo) async {
    try {
      if (_taskController.text.isNotEmpty) {
        // අලුත් ටයිටල් එක අප්ඩේට් කරනවා
        todo.title = _taskController.text;

        await TodoService().editTodo(todo);

        setState(() {}); // UI එක රිප්‍රෙෂ් කරනවා
        AppHelpers.showSnackBar(context, "Task updated successfully!");
        Navigator.of(context).pop();
      }
    } catch (e) {
      AppHelpers.showSnackBar(context, "Error updating task");
    }
  }

  // Edit Dialog එක (මේකෙදි Controller එකට කලින් තිබ්බ Title එක දාන්න ඕනේ)
  void openMessageModel(BuildContext context, Todo todo) {
    _taskController.text =
        todo.title; // මෙතනදී තමයි පරණ ටෙක්ස්ට් එක ටෙක්ස්ට් ෆීල්ඩ් එකට දාන්නේ

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.kCardColor,
          title: const Text(
            "Edit Task",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: _taskController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Enter task name",
              hintStyle: const TextStyle(color: Colors.grey),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.kWhiteColor),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.white),
              ),
            ),
            ElevatedButton(
              onPressed: () => _saveEditTodo(todo),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.kFabColor,
              ),
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    widget.incompletedTodos.sort((a, b) => a.time.compareTo(b.time));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: widget.incompletedTodos.length,
              itemBuilder: (context, index) {
                final Todo todo = widget.incompletedTodos[index];

                return Dismissible(
                  key: Key(todo.id.toString()),

                  // left to right edit (Edit - green color)
                  background: Container(
                    color: Colors.green,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.edit, color: Colors.white),
                  ),

                  // right to left swipe (Delete - red color)
                  secondaryBackground: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),

                  // what is doing when swiped
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.startToEnd) {
                      // Edit logic
                      openMessageModel(context, todo);
                      return false; // මේක false කරාම ලිස්ට් එකෙන් අයිටම් එක අයින් වෙන්නේ නැහැ
                    } else {
                      // Delete ලොජික් එක
                      _deleteTodo(todo);
                      return true; // මේක true කරාම ලිස්ට් එකෙන් අයිටම් එක අයින් වෙනවා
                    }
                  },

                  child: TodoCard(
                    todo: todo,
                    isCompleted: false,
                    onCheckBoxChanged: () => _markAsDone(todo),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
