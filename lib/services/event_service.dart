import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event_model.dart';

class EventService {
  final CollectionReference _eventsCollection = FirebaseFirestore.instance
      .collection('events');

  Stream<List<Event>> getEventsStream(String userId) {
    return _eventsCollection
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map(
                    (doc) => Event.fromMap(doc.data() as Map<String, dynamic>),
                  )
                  .toList(),
        );
  }

  Future<void> addEvent(Event event) async {
    var docRef = _eventsCollection.doc();
    event = event.copyWith(id: docRef.id);
    await docRef.set(event.toMap());
  }

  Future<void> updateEvent(Event event) async {
    await _eventsCollection.doc(event.id).update(event.toMap());
  }

  Future<void> deleteEvent(String eventId) async {
    await _eventsCollection.doc(eventId).delete();
  }
}
