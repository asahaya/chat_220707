import 'dart:ui';

import 'package:chat_220707/main.dart';
import 'package:chat_220707/my_page.dart';
import 'package:chat_220707/post.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  Future<void> sendPost(String text) async {
    final user = FirebaseAuth.instance.currentUser!;

    final postId = user.uid;
    final posterName = user.displayName!;
    final posterImageURL = user.photoURL!;

    final newDocumentReference = postReference.doc();

    final newPost = PostData(
      text: text,
      createdAt: Timestamp.now(),
      posterName: posterName,
      posterImageURL: posterImageURL,
      posterID: postId,
      reference: newDocumentReference,
    );
    newDocumentReference.set(newPost);
  }

  final controller = TextEditingController();

  @override
  void dispose() {
    // TODO: implement dispose
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('chat'),
        actions: [
          InkWell(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) {
                  return const MyPage();
                },
              ));
            },
            child: CircleAvatar(
                backgroundImage:
                    NetworkImage(FirebaseAuth.instance.currentUser!.photoURL!)),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot<PostData>>(
              stream: postReference.orderBy('createdAt').snapshots(),
              builder: (context, snapshot) {
                final docs = snapshot.data?.docs ?? [];
                return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final postdata = docs[index].data();
                      return PostWidget(
                        postdata: postdata,
                        docs: docs[index],
                        cont: controller,
                      );
                    });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.amber),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(
                    color: Colors.amber,
                    width: 2,
                  ),
                ),
                fillColor: Colors.amber,
                filled: true,
              ),
              onFieldSubmitted: (text) {
                sendPost(text);

                controller.clear();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class PostWidget extends StatelessWidget {
  const PostWidget({
    Key? key,
    required this.postdata,
    required this.docs,
    required this.cont,
  }) : super(key: key);

  final PostData postdata;
  final DocumentSnapshot docs;
  final TextEditingController cont;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(
              postdata.posterImageURL,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    postdata.posterName,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  Text(
                    DateFormat('yy/MM/DD HH:mm')
                        .format(postdata.createdAt.toDate()),
                    style: const TextStyle(fontSize: 10),
                  ),
                ],
              ),
              GestureDetector(
                onLongPress: () async {
                  cont.text = postdata.text;

                  //update

                  await postdata.reference.update({
                    'text': cont.text,
                  });
                },
                child: Align(
                  alignment: FirebaseAuth.instance.currentUser!.uid ==
                          postdata.posterID
                      ? Alignment.topRight
                      : Alignment.topLeft,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: FirebaseAuth.instance.currentUser!.uid ==
                              postdata.posterID
                          ? Colors.amber[100]
                          : Colors.blue[100],
                    ),
                    child: Text(postdata.text),
                  ),
                ),
              ),
              if (FirebaseAuth.instance.currentUser!.uid == postdata.posterID)
                IconButton(
                  onPressed: () {
                    postdata.reference.delete();
                  },
                  icon: const Icon(Icons.delete),
                ),
              if (FirebaseAuth.instance.currentUser!.uid == postdata.posterID)
                IconButton(
                  onPressed: () {
                    cont.text = postdata.text;
                  },
                  icon: const Icon(Icons.edit),
                )
            ]),
          ),
        ],
      ),
    );
  }
}
