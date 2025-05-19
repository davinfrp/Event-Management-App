import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/event_service.dart';
import '../services/notification_service.dart';
import '../models/event_model.dart';

class EventFormScreen extends StatefulWidget {
  final Event? event;

  EventFormScreen({this.event});

  @override
  _EventFormScreenState createState() => _EventFormScreenState();
}

class _EventFormScreenState extends State<EventFormScreen> {
  final EventService _eventService = EventService();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    if (widget.event != null) {
      _titleController.text = widget.event!.title;
      _descriptionController.text = widget.event!.description;
      _selectedDate = widget.event!.dateTime;
      _selectedTime = TimeOfDay.fromDateTime(widget.event!.dateTime);
    }
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.event == null ? 'New Event' : 'Edit Event',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.greenAccent[700],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedDate == null
                        ? 'No date chosen'
                        : 'Date: ${_selectedDate!.toLocal().toString().split(' ')[0]}',
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _pickDate(context),
                  child: Text('Pick Date'),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedTime == null
                        ? 'No time chosen'
                        : 'Time: ${_selectedTime!.format(context)}',
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _pickTime(context),
                  child: Text('Pick Time'),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (_titleController.text.isEmpty ||
                    _selectedDate == null ||
                    _selectedTime == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please fill all fields')),
                  );
                  return;
                }

                final dateTime = DateTime(
                  _selectedDate!.year,
                  _selectedDate!.month,
                  _selectedDate!.day,
                  _selectedTime!.hour,
                  _selectedTime!.minute,
                );

                if (widget.event == null) {
                  // Create new event
                  final event = Event(
                    id: '',
                    userId: userId,
                    title: _titleController.text,
                    description: _descriptionController.text,
                    dateTime: dateTime,
                  );
                  await _eventService.addEvent(event);
                  await NotificationService.scheduleNotification(event);
                  await NotificationService.showNotification(
                    'Event Created',
                    'Event "${event.title}" has been created.',
                  );
                } else {
                  // Update existing event
                  final updatedEvent = widget.event!.copyWith(
                    title: _titleController.text,
                    description: _descriptionController.text,
                    dateTime: dateTime,
                  );
                  await _eventService.updateEvent(updatedEvent);
                  await NotificationService.scheduleNotification(updatedEvent);
                  await NotificationService.showNotification(
                    'Event Updated',
                    'Event "${updatedEvent.title}" has been updated.',
                  );
                }
                Navigator.pop(context);
              },
              child: Text(widget.event == null ? 'Create' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }
}
