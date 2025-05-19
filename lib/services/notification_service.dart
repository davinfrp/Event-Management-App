import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import '../models/event_model.dart';

class NotificationService {
  static Future<void> initialize() async {
    await AwesomeNotifications().initialize(null, [
      NotificationChannel(
        channelKey: 'event_channel',
        channelName: 'Event Notifications',
        channelDescription: 'Notifications for event reminders',
        defaultColor: Color(0xFF9D50BB),
        ledColor: Colors.white,
      ),
    ]);
    await AwesomeNotifications().requestPermissionToSendNotifications();
  }

  static Future<void> showNotification(String title, String body) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 1,
        channelKey: 'event_channel',
        title: title,
        body: body,
      ),
    );
  }

  static Future<void> scheduleNotification(Event event) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: event.id.hashCode,
        channelKey: 'event_channel',
        title: 'Event: ${event.title}',
        body: 'The event is starting now!',
      ),
      schedule: NotificationCalendar.fromDate(date: event.dateTime),
    );
  }

  static Future<void> cancelNotification(String eventId) async {
    await AwesomeNotifications().cancel(eventId.hashCode);
  }
}
