import 'package:cloud_firestore/cloud_firestore.dart';

class PostData {
  PostData({
    required this.text,
    required this.createdAt,
    required this.posterName,
    required this.posterImageURL,
    required this.posterID,
    required this.reference,
  });
  factory PostData.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final mapdata = snapshot.data()!;
//
    return PostData(
      text: mapdata['text'],
      createdAt: mapdata['createdAt'],
      posterName: mapdata['posterName'],
      posterImageURL: mapdata['posterImageURL'],
      posterID: mapdata['posterID'],
      reference: snapshot.reference,
    );
  }
//PostDataインスタンスからMapに変換するため
  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'createdAt': createdAt,
      'posterName': posterName,
      'posterImageURL': posterImageURL,
      'posterID': posterID,
    };
  }

  //投稿文
  final String text;
//投稿日時
  final Timestamp createdAt;
//投稿者の名前
  final String posterName;
//投稿者のアイコンURL
  final String posterImageURL;
//投稿者のユーザーID
  final String posterID;
//Firestoreの何処にデータが存在するかを表すPATH情報
  final DocumentReference reference;
}
