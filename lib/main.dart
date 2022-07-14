import 'package:chat_220707/chat_page.dart';
import 'package:chat_220707/post.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'firebase_options.dart';

Future<void> main() async {
  // main 関数でも async が使えます
  WidgetsFlutterBinding.ensureInitialized(); // runApp 前に何かを実行し+たいときはこれが必要です。
  await Firebase.initializeApp(
    // これが Firebase の初期化処理です。
    options: DefaultFirebaseOptions.android,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    if (FirebaseAuth.instance.currentUser == null) {
      //not login
      return MaterialApp(
        theme: ThemeData(),
        home: const SignInPage(),
      );
    } else {
      return MaterialApp(
        theme: ThemeData(),
        home: const ChatPage(),
      );
    }
  }
}

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  Future<void> signInWithGoogle() async {
    // GoogleSignIn をして得られた情報を Firebase と関連づけることをやっています。
    final googleUser =
        await GoogleSignIn(scopes: ['profile', 'email']).signIn();

    final googleAuth = await googleUser?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    await FirebaseAuth.instance.signInWithCredential(credential);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('googleSignIN'),
      ),
      body: Center(
          child: ElevatedButton(
        child: const Text('GoogleSignIn'),
        onPressed: () async {
          await signInWithGoogle();

          print("${FirebaseAuth.instance.currentUser?.displayName}name");

//login success
          if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) {
              return const ChatPage();
            }), (route) => false);
          }
        },
      )),
    );
  }
}

final postReference = FirebaseFirestore.instance
    .collection('postDatas')
    .withConverter<PostData>(fromFirestore: ((snapshot, _) {
  return PostData.fromFirestore(snapshot);
}), toFirestore: ((value, _) {
  return value.toMap();
}));
