import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_provider/user.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Providers
// Provider
// StateProvider
// StateNotifier and StateNotifierProvider
// ChangeNotifierProvider
// FutureProvider

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

// ChangeNotifierProvider is exposing ChangeNotifier
final userChangeNotifierProvider =
    ChangeNotifierProvider((ref) => UserNotifierChange());

void changeNameProvider(WidgetRef ref, String value) {
  // ref.read(nameProvider2.notifier).update((state) => value);
  //  ref.read(userProvider3.notifier).updateName(value);
  // ref.read(userProvider3.notifier).updateName(value);
  ref.read(userChangeNotifierProvider).updateName(value);
}

final fetchUserProvider = FutureProvider((ref) async {
  String url = 'https://jsonplaceholder.typicode.com/users/1';

  // Fetch data from the URL
  final response = await http.get(Uri.parse(url));
  log(response.body.toString());
  return http
      .get(Uri.parse(url))
      .then((value) => UserModel.fromJson(value.body));
  // if (response.statusCode == 200) {
  //   // If the server returns a 200 OK response, parse the JSON
  //   final Map<String, dynamic> data = json.decode(response.body);
  //   return data; // Return the parsed data
  // } else {
  //   // If the server did not return a 200 OK response, throw an exception
  //   throw Exception('Failed to load user');
  // }
});

void changeAgeProvider(WidgetRef ref, int value) {
  ref.read(userChangeNotifierProvider).updateAge(value);
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
    // final user = ref.watch(userProvider3);
    // here widget tree will rebuild only when there is any change in name property
    // final nameSelect = ref.watch(userProvider3.select((value) => value.name));
    final userChangeNotifier = ref.watch(userChangeNotifierProvider).user;

    final user = ref.watch(fetchUserProvider);

    // there is no ref here
    return user.when(
      data: (data) {
        return Scaffold(
          appBar: AppBar(),
          body: Column(children: [
            // TextField(
            //   onSubmitted: (value) => changeNameProvider(ref, value),
            // ),
            // Text(user.name),
            // Text(userChangeNotifier.name),
            // Text(userChangeNotifier.age.toString()),
            Text(data.name),
            Text(data.email),
            // Text(data.age.toString()),
            ElevatedButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => StExample()));
                },
                child: Text("next page"))
          ]),
        );
      },
      error: (error, stackTrace) {
        return Scaffold(
          body: Center(
            child: Text(error.toString()),
          ),
        );
      },
      loading: () {
        return Scaffold(
          body: Center(
            child: const CircularProgressIndicator(),
          ),
        );
      },
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
            final name3 = ref.watch(userChangeNotifierProvider);
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
        TextField(
          onSubmitted: (value) => changeAgeProvider(ref, int.parse(value)),
        ),
        Text(ref.watch(userChangeNotifierProvider).user.name),
        Text(ref.watch(userChangeNotifierProvider).user.age.toString())
      ]),
    );
  }
}
