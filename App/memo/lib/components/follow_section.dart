import 'package:flutter/material.dart';
import 'package:memo/services/auth_service.dart';

class FollowSections extends StatefulWidget {
  final String? userId;
  const FollowSections({super.key, required this.userId});

  @override
  State<FollowSections> createState() => _FollowSectionsState();
}

class _FollowSectionsState extends State<FollowSections> {
  final authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: authService.getCurrentUserID() == widget.userId
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  child: Text(
                    'Edit Profile',
                    style: TextStyle(color: Colors.grey),
                  ),
                  style: ButtonStyle(
                      elevation: WidgetStateProperty.all(0),
                      backgroundColor: WidgetStateProperty.all(Colors.white),
                      side: WidgetStateProperty.all(
                          BorderSide(color: Colors.grey, width: 1))),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/create-timeline');
                  },
                  child: Text(
                    '+ Create Timeline',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ButtonStyle(
                    elevation: WidgetStateProperty.all(0),
                    backgroundColor: WidgetStateProperty.all(Colors.purple),
                  ),
                ),
              ],
            )
          : ElevatedButton(
              onPressed: () {},
              child: Text(
                'Follow',
                style: TextStyle(color: Colors.white),
              ),
              style: ButtonStyle(
                  elevation: WidgetStateProperty.all(0),
                  backgroundColor: WidgetStateProperty.all(Colors.purple),
                  fixedSize: MaterialStateProperty.all(Size(170, 40))),
            ),
    );
  }
}
