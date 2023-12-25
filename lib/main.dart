import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/riverpod.dart';

final nameProvider = Provider<String>((ref) {
  return 'Hey flutter!';
});
// this is a normal provider, we cannot change its val, to change any provider val, we have a diff.
// provider called StateProvider

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
    final name = ref.watch(nameProvider);
    return Scaffold(
      appBar: AppBar(),
      body: Column(children: [
        Text(name),
        ElevatedButton(
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => NextPage()));
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
            final name2 = ref.read(nameProvider);
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
