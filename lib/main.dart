import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_provider/user.dart';

final nameProvider = Provider<String>((ref) {
  return 'Hey flutter!';
});
// this is a normal provider, we cannot change its val, to change any provider val, we have a diff.
// provider called StateProvider
// this provider can have a string or a null value
final nameProvider2 = StateProvider<String?>((ref) {
  return null;
});
// StateProvider is good for small values but for values like classes
// we'll use a combination of StateNotifier and StateNotifierProvider
final userProvider3 =
    StateNotifierProvider<UserNotifier, User>((ref) => UserNotifier());

void changeNameProvider(WidgetRef ref, String value) {
  // ref.read(nameProvider2.notifier).update((state) => value);
  ref.read(userProvider3.notifier).updateName(value);
}

void main() {
  runApp(
    // Enabled Riverpod for the entire application
    ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Home(),
    );
  }
}

// by wraping it with a ConsumerWidget it will rebuild the whole widget treeg
class Home extends ConsumerWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider3);
    return Scaffold(
      appBar: AppBar(),
      body: Column(children: [
        // TextField(
        //   onSubmitted: (value) => changeNameProvider(ref, value),
        // ),
        Text(user.name),
        ElevatedButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => StExample()));
            },
            child: Text("next page"))
      ]),
    );
  }
}

class NextPage extends StatelessWidget {
  const NextPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // consumer widget rebuild only those widget, who we want to
          Consumer(builder: (context, ref, child) {
            // ref.watch() is preferred over ref.read(), coz ref.watch() constantly looks,
            // if the provider data is changed!!!
            final name = ref.watch(nameProvider);
            final name2 = ref.read(nameProvider2) ?? '';
            return Center(
              child: Text(name2),
            );
          }),
          Text('no change'),
          Text('no change'),
          Text('no change'),
        ],
      ),
    );
  }
}

//example with a Stateful widget
class StExample extends ConsumerStatefulWidget {
  const StExample({super.key});

  @override
  ConsumerState<StExample> createState() => _StExampleState();
}

class _StExampleState extends ConsumerState<StExample> {
  // here we do not need to explicitly define WdgetRef in build method,
  // this ConsumerState already has it
  // we can use it anywhere

  @override
  Widget build(BuildContext context) {
    // accessing a provider using a consumer widget has no change
    return Scaffold(
      appBar: AppBar(),
      body: Column(children: [
        TextField(
          onSubmitted: (value) => changeNameProvider(ref, value),
        ),
        Text(ref.watch(userProvider3).name)
      ]),
    );
  }
}
