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
                    _sectionTitle("Our Team"),
                    SizedBox(height: 16),
                    _buildTeamMember(
                        name: "Sandinu Pinnawala",
                        linkedinUrl:
                            "https://www.linkedin.com/in/sandinu-pinnawala-b85b2b20a/"),
                    _buildTeamMember(
                        name: "Sachin Kulathilaka",
                        linkedinUrl:
                            "https://www.linkedin.com/in/sachin-kulathilaka-064037267/"),
                    _buildTeamMember(
                        name: "Thisas Ranchagoda",
                        linkedinUrl:
                            "https://www.linkedin.com/in/thisas-ranchagoda-124b82294/"),
                    _buildTeamMember(
                        name: "Malsha Jayasinghe",
                        linkedinUrl:
                            "https://www.linkedin.com/in/malsha-pabodani-jayasinghe-64a805292/"),
                    _buildTeamMember(
                        name: "Monali Suriarachchi",
                        linkedinUrl:
                            "https://www.linkedin.com/in/monalisuriarachchi/"),
                    _buildTeamMember(
                        name: "Sadinsa Welagedara",
                        linkedinUrl:
                            "https://www.linkedin.com/in/sadinsa-welagedara-68013b295/"),
                    SizedBox(height: 32),
                    Center(
                      child: GestureDetector(
                        onTap: () async {
                          const url = 'https://www.relivememo.com/';
                          if (await canLaunchUrl(Uri.parse(url))) {
                            await launchUrl(Uri.parse(url),
                                mode: LaunchMode.externalApplication);
                          }
                        },
                        child: Text(
                          "Visit our website: www.relivememo.com",
                          style: TextStyle(
                            fontSize: 16,
                            color: Color.fromARGB(255, 160, 105, 211),
                            fontWeight: FontWeight.w400,
                            decoration: TextDecoration.underline,
                            decorationColor: Color.fromARGB(255, 160, 105, 211),
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

  Widget _buildTeamMember({required String name, required String linkedinUrl}) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      elevation: 0,
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 4),
      color: const Color.fromARGB(230, 255, 255, 255),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        leading: CircleAvatar(
          backgroundColor: Color.fromARGB(255, 160, 105, 211),
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
        onTap: () async {
          if (await canLaunchUrl(Uri.parse(linkedinUrl))) {
            await launchUrl(Uri.parse(linkedinUrl),
                mode: LaunchMode.externalApplication);
          }
        },
      ),
    );
  }
}
