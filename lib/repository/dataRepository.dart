import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:poc1/model/homes.dart';

class DataRepository {
  // top level reference is pets
  final CollectionReference<Map<String, dynamic>> collection =
      FirebaseFirestore.instance.collection('homes');

  // snapshots method to get a stream of snapshots, listens for updates
  Stream<QuerySnapshot<Map<String, dynamic>>> getStream() {
    return collection.snapshots();
  }

  // add new pet, returns Future if waiting for result; will auto create new document id for Pet
  Future<DocumentReference> addHome(Home home) {
    return collection.add(home.toJson());
  }

  // Update pet class
  updateHome(Home home) async {
    await collection.doc(home.reference.id).update(home.toJson());
  }
}
