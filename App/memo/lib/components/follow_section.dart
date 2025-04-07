import 'package:flutter/material.dart';
import 'package:memo/pages/edit_profile.dart';
import 'package:memo/services/auth_service.dart';
import 'package:memo/services/follow.dart';

class FollowSections extends StatefulWidget {
  @override
  _FollowSectionsState createState() => _FollowSectionsState();

  final String? userId;
  final bool? privateProfile;
  const FollowSections({super.key, required this.userId, this.privateProfile});
}

class _FollowSectionsState extends State<FollowSections> {
  final authService = AuthService();
  final followService = FollowService();
  String? userId;
  String following = 'not-following';

  @override
  void initState() {
    super.initState();
    following = widget.userId == authService.getCurrentUserID()
        ? "following"
        : "not-following";
    userId = widget.userId;
    checkFollow();
  }

  Future<void> checkFollow() async {
    final response = await followService.checkFollow(userId!);

    if (response == 'following') {
      setState(() {
        following = "following";
      });
    } else if (response == 'requested') {
      setState(() {
        following = "requested";
      });
    } else {
      setState(() {
        following = "not-following";
      });
    }
    return;
  }

  Future<void> handleFollow() async {
    bool response = false;
    if (widget.privateProfile == true) {
      response =
          await followService.handleFollow(userId!, widget.privateProfile!);
      if (response) {
        setState(() {
          following = "requested";
        });
      }
    } else {
      response =
          await followService.handleFollow(userId!, widget.privateProfile!);
      if (response) {
        setState(() {
          following = "following";
        });
      }
    }

    print('response');
    print(response);
  }

  Future<void> handleUnfollow() async {
    bool response = await followService.handleUnfollow(userId!);
    if (response) {
      setState(() {
        following = "not-following";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: authService.getCurrentUserID() == widget.userId
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => EditProfile()));
                  },
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
          : following == 'following'
              ? ElevatedButton(
                  onPressed: handleUnfollow,
                  child: Text(
                    'Following',
                    style: TextStyle(color: Colors.purple),
                  ),
                  style: ButtonStyle(
                      elevation: WidgetStateProperty.all(0),
                      backgroundColor:
                          WidgetStateProperty.all(Colors.purple[50]),
                      fixedSize: MaterialStateProperty.all(Size(170, 40)),
                      side: WidgetStateProperty.all(
                          BorderSide(color: Colors.purple, width: 1))),
                )
              : following == "requested"
                  ? ElevatedButton(
                      onPressed: handleFollow,
                      child: Text(
                        'Requested',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                      style: ButtonStyle(
                          elevation: WidgetStateProperty.all(0),
                          backgroundColor:
                              WidgetStateProperty.all(Colors.transparent),
                          fixedSize: MaterialStateProperty.all(Size(170, 40)),
                          side: WidgetStateProperty.all(
                              BorderSide(color: Colors.purple, width: 1))),
                    )
                  : ElevatedButton(
                      onPressed: handleFollow,
                      child: Text(
                        'Follow',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ButtonStyle(
                          elevation: WidgetStateProperty.all(0),
                          backgroundColor:
                              WidgetStateProperty.all(Colors.purple),
                          fixedSize: MaterialStateProperty.all(Size(170, 40))),
                    ),
    );
  }
}
