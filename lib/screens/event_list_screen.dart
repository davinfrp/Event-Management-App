import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/event_service.dart';
import '../services/notification_service.dart';
import '../models/event_model.dart';
import 'event_form_screen.dart';

class EventListScreen extends StatelessWidget {
  final AuthService _authService = AuthService();
  final EventService _eventService = EventService();

  @override
  Widget build(BuildContext context) {
    final userId = _authService.getCurrentUser()!.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Event Management',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.greenAccent[700],
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await _authService.logout();
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Event>>(
        stream: _eventService.getEventsStream(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No events found'));
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final event = snapshot.data![index];
              return ListTile(
                title: Text(
                  event.title,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${event.description}\n${event.dateTime.toString().split('.')[0]}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.yellow[800]),
                      onPressed:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => EventFormScreen(event: event),
                            ),
                          ),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await _eventService.deleteEvent(event.id);
                        await NotificationService.cancelNotification(event.id);
                        await NotificationService.showNotification(
                          'Event Deleted',
                          'Event "${event.title}" has been deleted.',
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => EventFormScreen()),
            ),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
