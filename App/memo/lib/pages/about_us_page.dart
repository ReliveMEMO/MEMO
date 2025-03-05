import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).copyWith(
      scaffoldBackgroundColor: Colors.grey[50],
      textTheme: Theme.of(context).textTheme.apply(
            fontFamily: 'Roboto',
          ),
    );

    return Theme(
      data: theme,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "About Us",
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 20,
              color: Colors.black87,
            ),
          ),
          backgroundColor: Colors.grey[50],
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black54),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle("Development Team"),
                    SizedBox(height: 16),
                    _buildTeamMember(name: "Sandinu Pinnawala"),
                    _buildTeamMember(name: "Sachin Kulathilaka"),
                    _buildTeamMember(name: "Thisas Ranchagoda"),
                    _buildTeamMember(name: "Malsha Jayasinghe"),
                    _buildTeamMember(name: "Monali Suriarachchi"),
                    _buildTeamMember(name: "Sadinsa Welagedara"),
                    SizedBox(height: 32),
                    Center(
                      child: GestureDetector(
                        onTap: () async {
                          const url = 'https://www.relivememo.com/';
                          if (await canLaunch(url)) {
                            await launch(url);
                          }
                        },
                        child: Text(
                          "Visit our website: www.relivememo.com",
                          style: TextStyle(
                            fontSize: 16,
                            color: Color.fromARGB(255, 145, 67, 223),
                            fontWeight: FontWeight.w400,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(20),
              alignment: Alignment.center,
              child: Text(
                "© 2024 MEMO. All Rights Reserved",
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildTeamMember({required String name}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 1),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        leading: CircleAvatar(
          backgroundColor: Color.fromARGB(255, 198, 173, 220),
          child: Icon(Icons.person, color: Colors.white),
        ),
        title: Text(
          name,
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}
