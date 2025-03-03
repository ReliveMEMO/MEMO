import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:memo/services/auth_service.dart';
import 'package:memo/services/msg_encryption.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationTile extends StatefulWidget {
  final String notificationId;
  const NotificationTile({super.key, required this.notificationId});

  @override
  State<NotificationTile> createState() => _NotificationTileState();
}