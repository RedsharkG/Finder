import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'study_room_detail_page.dart'; // Import the details page

// Define fetchStudyRooms function
Future<List<Map<String, dynamic>>> fetchStudyRooms() async {
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('Study_Rooms').get();
  return querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
}

// Function to fetch booker's name by UID
Future<String> fetchBookerName(String? uid) async {
  if (uid == null) return 'Available'; // Handle null UID for available rooms
  DocumentSnapshot docSnapshot = await FirebaseFirestore.instance.collection('Person').doc(uid).get();
  if (docSnapshot.exists) {
    return '${docSnapshot['First_Name']} ${docSnapshot['Last_Name']}';
  } else {
    return 'Unknown';
  }
}

class StudyRoomListPage extends StatefulWidget {
  @override
  _StudyRoomListPageState createState() => _StudyRoomListPageState();
}

class _StudyRoomListPageState extends State<StudyRoomListPage> {
  final Future<List<Map<String, dynamic>>> studyRoomsFuture = fetchStudyRooms();
  String searchQuery = ""; // Track the search query

  // Developed By,
// Imesh Sanjana - 30137 - 10953245
// Gaveen Ranasinghe - 29934 - 10952369
// Sehara Gishan - 26041 - 10953243
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffeee7da), // Beige background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Book Your Study Room", style: TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold)),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Bar
            TextField(
              decoration: InputDecoration(
                hintText: "Search study rooms...",
                prefixIcon: Icon(Icons.search, color: Colors.black),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.black),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase(); // Update search query
                });
              },
            ),
            SizedBox(height: 16), // Spacing between search bar and list
            // Study Rooms List
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: studyRoomsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No study rooms available.'));
                  } else {
                    List<Map<String, dynamic>> studyRooms = snapshot.data!;

                    // Sort study rooms alphabetically by name
                    studyRooms.sort((a, b) => a['Name'].compareTo(b['Name']));

                    // Filter study rooms based on search query
                    List<Map<String, dynamic>> filteredRooms = studyRooms
                        .where((room) =>
                        room['Name'].toLowerCase().contains(searchQuery))
                        .toList();

                    // Developed By,
// Imesh Sanjana - 30137 - 10953245
// Gaveen Ranasinghe - 29934 - 10952369
// Sehara Gishan - 26041 - 10953243
                    return ListView.builder(
                      itemCount: filteredRooms.length,
                      itemBuilder: (context, index) {
                        var studyRoom = filteredRooms[index];
                        return _buildRoomCard(context, studyRoom['Name'], studyRoom);
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomCard(BuildContext context, String title, Map<String, dynamic> studyRoom) {
    bool isBooked = studyRoom['isBooked'] ?? false;
    String? bookedByUid = studyRoom['bookedBy']; // Handle null bookedBy

    return Card(
      elevation: 4, // Add shadow to the card
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15), // Rounded corners
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StudyRoomDetailPage(studyRoom: studyRoom),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Status Indicator
              Container(
                width: 10,
                height: 50,
                decoration: BoxDecoration(
                  color: isBooked ? Colors.red : Colors.green,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              SizedBox(width: 16), // Spacing between indicator and content
              // Room Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      isBooked ? "Booked" : "Available",
                      style: TextStyle(
                        fontSize: 14,
                        color: isBooked ? Colors.red : Colors.green,
                      ),
                    ),
                    if (isBooked)
                      FutureBuilder<String>(
                        future: fetchBookerName(bookedByUid),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Text('Loading...', style: TextStyle(fontSize: 14, color: Colors.grey));
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}', style: TextStyle(fontSize: 14, color: Colors.red));
                          } else {
                            return Text('Booked by: ${snapshot.data}', style: TextStyle(fontSize: 14, color: Colors.black));
                          }
                        },
                      ),
                    //Developed By,
//Nethsara Weerasooriya - 29733 - 10953304
//Dinuwara Wijerathne - 30406 - 10953246
//Dihansie Weerasinghe - 30223 - 10952372
//Chaga Kodikara - 30296 - 10952374
                  ],
                ),
              ),
              // Icon
              Icon(
                isBooked ? Icons.lock : Icons.lock_open,
                color: isBooked ? Colors.red : Colors.green,
              ),
            ],
          ),
        ),
      ),
    );
  }
}