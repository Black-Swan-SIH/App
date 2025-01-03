import 'dart:convert';
import 'dart:io';

import 'package:drdo/components/background.dart';
import 'package:drdo/components/job.dart';
import 'package:drdo/components/mainheading.dart';
import 'package:drdo/components/profiledetails.dart';
import 'package:drdo/components/sectionheading.dart';
import 'package:drdo/components/skillexp.dart';
import 'package:drdo/components/text.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';


class Profile extends StatefulWidget {
  final String id;
  final String type;
  const Profile({super.key, required this.id, required this.type});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  late String name = "Om Rajpal";
  late int age = 19;
  late String pronouns = "He / Him";
  late String experience = "Beginner";
  late String industry = "1st Reconnaissance Squadron";

  late List skills = [];
  late double profileScore = 76;
  late String currentPosition = "Product Designer";
  late String bestInterviewer = "Flutter Developer";
  late String keySkill = "Node.js Developer";
  late String imgLink = "";

  @override
  void initState() {
    getData();
    super.initState();
  }

  void getData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString("token");
    print(token);
    http.Response response;
    if (widget.type == widget.type) {
      response = await http.get(
          Uri.parse(
              "https://api.black-swan.tech/expert/${widget.id}?education=true&experience=true"),
          headers: {
            "authorization": "Bearer $token",
            "Content-Type": "application/json",
            "ismobile": "true"
          });
    } else {
      response = await http.get(
          Uri.parse("https://api.black-swan.tech/candidate/${widget.id}"),
          headers: {
            "authorization": "Bearer $token",
            "Content-Type": "application/json",
            "ismobile": "true"
          });
    }

    var jsonRes = await jsonDecode(response.body);
    print(jsonRes);

    if (jsonRes["status"] == "success") {
      name = jsonRes["data"][widget.type]["name"];
      age = jsonRes["data"][widget.type]["dateOfBirth"] != null
          ? DateTime.now().year -
              DateTime.parse(jsonRes["data"][widget.type]["dateOfBirth"]).year
          : 0;
      pronouns = jsonRes["data"][widget.type]["gender"];
      currentPosition = jsonRes["data"][widget.type]["currentPosition"];
      keySkill = jsonRes["data"][widget.type]["currentDepartment"];

      // Process experience data
      List experienceData = jsonRes["data"][widget.type]["experience"];
      List<Map<String, dynamic>> experienceList = experienceData.map((exp) {
        DateTime startDate = DateTime.parse(exp["startDate"]);
        DateTime endDate = DateTime.parse(exp["endDate"]);
        int yearsWorked = endDate.year - startDate.year;
        if (endDate.month < startDate.month ||
            (endDate.month == startDate.month && endDate.day < startDate.day)) {
          yearsWorked -= 1;
        }

        return {
          "skill": exp["department"],
          "years": yearsWorked,
        };
      }).toList();

      // Update state with experience list
      setState(() {
        skills = experienceList;
      });
    } else {
      print("Error");
    }
  }

  Future<void> uploadPDF() async{
    try {
    // Specify the path of the PDF stored in your local storage
    final directory = await getApplicationDocumentsDirectory();
    final filePath = "${directory.path}/example.pdf"; // Adjust file path
    final file = File(filePath);

    if (!file.existsSync()) {
      print("File not found!");
      return;
    }

    // Create a MultipartRequest
    final uri = Uri.parse("https://api.black-swan.tech/parse");
    final request = http.MultipartRequest('GET', uri);

    // Add the file as a form field
    request.files.add(
      await http.MultipartFile.fromPath(
        'file', // Field name for form-data
        file.path,
        contentType: MediaType('application', 'pdf'),
      ),
    );

    // Optionally add other form data
    request.fields['name'] = 'example.pdf';

    // Send the request
    final response = await request.send();

    if (response.statusCode == 200) {
      print("File uploaded successfully!");
    } else {
      print("Failed to upload file. Status code: ${response.statusCode}");
    }
  } catch (e) {
    print("Error uploading file: $e");
  }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        body: Background(
      colour: Colors.white54,
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 165,
              child: Stack(
                children: [
                  Container(
                    color: const Color(0xffD0D0D0),
                    height: 125,
                  ),
                  Positioned(
                    bottom: 0,
                    left: screenWidth * 0.09,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xff6F6F6F),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            spreadRadius: 1,
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              width: screenWidth * 0.81,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Mainheading(text: name),
                      const SizedBox(
                        width: 5,
                      ),
                      Transform.translate(
                        offset: const Offset(0, 3.5),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.black, width: 1),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            child: TextData(
                                text: 'Verified',
                                fontSize: 8,
                                fontWeight: FontWeight.w500,
                                color: Color(0xff767676)),
                          ),
                        ),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      ProfileDetails(data: "Unit", value: industry),
                      const SizedBox(
                        width: 10,
                      ),
                      ProfileDetails(data: "Age", value: age.toString())
                    ],
                  ),
                  const SizedBox(
                    height: 3,
                  ),
                  Row(
                    children: [
                      ProfileDetails(data: "Gender", value: pronouns),
                      const SizedBox(
                        width: 10,
                      ),
                      ProfileDetails(data: "Experience", value: experience)
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  SizedBox(
                    width: 80,
                    height: 28,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          )),
                      child: const Text(
                        "Edit Profile",
                        style: TextStyle(
                            fontSize: 11,
                            color: Colors.white,
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Sectionheading(text: "Top Skills"),
                  Row(
                    children: [
                      TextData(
                          text: currentPosition,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xff7e7e7e)),
                      const SizedBox(
                        width: 3,
                      ),
                      const Icon(
                        Icons.beach_access,
                        size: 8,
                      ),
                      const SizedBox(
                        width: 3,
                      ),
                      TextData(
                          text: keySkill,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xff3c3c3c))
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: skills.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Experience(
                          skill: skills[index]["skill"],
                          percentage: skills[index]["years"],
                        ),
                      );
                    },
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  const Sectionheading(text: "Scheduled Interviews"),
                  const SizedBox(
                    height: 8,
                  ),
                  const Job(
                    jobTitle: "Node.js Developer",
                    daysLeft: 2,
                    applicants: 101,
                    id: '',
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  const Job(
                    jobTitle: "Node.js Developer",
                    daysLeft: 2,
                    applicants: 101,
                    id: '',
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  const Job(
                    jobTitle: "Node.js Developer",
                    daysLeft: 2,
                    applicants: 101,
                    id: '',
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: [
                      const TextData(
                          text: "3+ more...",
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Color(0xff7e7e7e)),
                      const SizedBox(
                        width: 5,
                      ),
                      InkWell(
                        onTap: () {
                          print("View All");
                        },
                        child: const TextData(
                            text: "View All",
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xff3c3c3c)),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  const Sectionheading(text: "Profile Score"),
                  const SizedBox(
                    height: 8,
                  ),
                  SizedBox(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircularPercentIndicator(
                          radius: 53,
                          lineWidth: 14,
                          percent: profileScore / 100,
                          animateToInitialPercent: true,
                          animationDuration: 1000,
                          progressColor: const Color(0xffDE8F6E),
                          backgroundColor: const Color(0xff2C2C34),
                          animation: true,
                          reverse: true,
                          circularStrokeCap: CircularStrokeCap.round,
                        ),
                        const SizedBox(
                          height: 75,
                          child: VerticalDivider(
                            width: 10,
                            color: Color(0xffCECECE),
                            thickness: 1,
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            TextData(
                                text: "$profileScore / 100",
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xff2C2C34)),
                            const SizedBox(
                              height: 13,
                            ),
                            Column(
                              children: [
                                const TextData(
                                    text: "Best interviewer for",
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xff7E7E7E)),
                                TextData(
                                    text: bestInterviewer,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xff3C3C3C))
                              ],
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  )
                ],
              ),
            )
          ],
        ),
      ),
    ));
  }
}
