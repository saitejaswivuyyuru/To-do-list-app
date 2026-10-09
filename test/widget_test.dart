import 'package:flutter_test/flutter_test.dart';
import 'package:to_do_list/main.dart';

void main() {
  testWidgets('Smart To-Do List displays its main UI',
      (WidgetTester tester) async {
    await tester.pumpWidget(const TodoApp());

    expect(find.text('Smart To-Do List'), findsOneWidget);
    expect(find.text('Stay Organized!'), findsOneWidget);
    expect(find.text('My Tasks'), findsOneWidget);
    expect(find.text('Add Task'), findsOneWidget);
  });
}