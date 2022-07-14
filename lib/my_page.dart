import 'package:chat_220707/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class MyPage extends StatelessWidget {
  const MyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      appBar: AppBar(title: const Text('マイページ')),
      body: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(32),
        child: Column(children: [
          CircleAvatar(
            backgroundImage: NetworkImage(user.photoURL!),
            radius: 40,
          ),
          Text(
            user.displayName!,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          const SizedBox(
            height: 16,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text('`ユーザーID:${user.uid}'),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text('登録日：${user.metadata.creationTime!}'),
          ),
          const SizedBox(
            height: 16,
          ),
          ElevatedButton(
            onPressed: () async {
              await GoogleSignIn().signOut();

              await FirebaseAuth.instance.signOut();

              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) {
                return const SignInPage();
              }), (route) => false);
            },
            child: const Text('SignOut'),
          ),
        ]),
      ),
    );
  }
}
