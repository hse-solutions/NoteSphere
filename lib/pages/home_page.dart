import 'package:flutter/material.dart';
import 'package:note_sphere/models/note_model.dart';
import 'package:note_sphere/models/todo_model.dart';
import 'package:note_sphere/services/note_service.dart';
import 'package:note_sphere/services/todo_service.dart';
import 'package:note_sphere/utils/router.dart';
import 'package:note_sphere/utils/text_style.dart';
import 'package:note_sphere/widgets/main_screen_todo_card.dart';
import 'package:note_sphere/widgets/notes_todo_card.dart';
import 'package:note_sphere/widgets/progress_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Note> allNotes = [];
  List<Todo> allTodos = [];

  @override
  void initState() {
    _checkIfUserIsNew();
    super.initState();
    setState(() {});
  }

  void _checkIfUserIsNew() async {
    final bool isNewUser =
        await NoteService().isNewUser() || await TodoService().isNewUser();
    if (isNewUser) {
      NoteService().createInitialNotes();
      TodoService().createInizialTodos();
    }
    _loadNotes();
    _loadTodos();
  }

  Future<void> _loadNotes() async {
    final List<Note> loadedNotes = await NoteService().loadNotes();
    setState(() {
      allNotes = loadedNotes;
    });
  }

  Future<void> _loadTodos() async {
    final List<Todo> loadedTodos = await TodoService().loadTodos();
    setState(() {
      allTodos = loadedTodos;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("NoteSphere", style: AppTextStyles.appTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            SizedBox(height: 20),
            ProgressCard(
              completedTasks: allTodos.where((todo) => todo.isDone).length,

              totalTasks: allTodos.length,
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    AppRouter.router.push("/notes");
                  },
                  child: NotesTodoCard(
                    title: "Notes",
                    description: "You have ${allNotes.length.toString()} notes",
                    icon: Icons.note_add_outlined,
                  ),
                ),
                SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    AppRouter.router.push("/todos");
                  },
                  child: NotesTodoCard(
                    title: "To-Do",
                    description: "You have ${allTodos.length.toString()} tasks",
                    icon: Icons.check_circle_outline,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Today's Progress", style: AppTextStyles.appSubtitle),

                InkWell(
                  onTap: () {
                    AppRouter.router.push("/todos");
                  },
                  child: Text("See All", style: AppTextStyles.appButton),
                ),
              ],
            ),
            const SizedBox(height: 20),
            allTodos.length == 0
                ? Container(
                    margin: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.1,
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          Text(
                            "No tasks for today , Add some tasks to get started!",
                            style: AppTextStyles.appDescription.copyWith(
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                Colors.blue,
                              ),
                            ),
                            onPressed: () {
                              AppRouter.router.push("/todos");
                            },
                            child: const Text("Add Task"),
                          ),
                        ],
                      ),
                    ),
                  )
                : Expanded(
                    child: ListView.builder(
                      itemCount: allTodos.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsetsGeometry.only(bottom: 20),
                          child: MainScreenTodoCard(
                            title: allTodos[index].title,
                            isDone: allTodos[index].isDone,
                            date: allTodos[index].date.toString(),
                            time: allTodos[index].time.toString(),
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
