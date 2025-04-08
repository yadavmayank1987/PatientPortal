// doctor_panel.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'patient_details.dart'; // A new screen to show patient details

class DoctorPanel extends StatefulWidget {
  final String doctorId; // Doctor's ID, passed from the previous screen

  const DoctorPanel({super.key, required this.doctorId});

  @override
  DoctorPanelState createState() => DoctorPanelState();
}

class DoctorPanelState extends State<DoctorPanel> {
  late String doctorId;

  @override
  void initState() {
    super.initState();
    doctorId = widget.doctorId;
  }

  // Fetch appointments for the doctor
  Future<List<Map<String, dynamic>>> fetchDoctorAppointments() async {
    // Fetching appointments for the specific doctor from Firestore
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(
            'appointments') // Ensure you have a collection for appointments
        .where('doctorId', isEqualTo: doctorId)
        .get();

    // Map the query snapshot to a list of appointments
    List<Map<String, dynamic>> appointments = querySnapshot.docs.map((doc) {
      return {
        'appointmentId': doc.id,
        'patientName': doc['patientName'],
        'date': doc['date'],
        'status': doc['status'],
      };
    }).toList();

    return appointments;
  }

  // Update appointment status (complete, pending, etc.)
  Future<void> updateAppointmentStatus(
      String appointmentId, String status) async {
    await FirebaseFirestore.instance
        .collection('appointments')
        .doc(appointmentId)
        .update({'status': status});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Doctor Panel'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              // Add your logout logic here (e.g., FirebaseAuth sign out)
              // FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: fetchDoctorAppointments(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error fetching data.'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No appointments available.'));
          }

          List<Map<String, dynamic>> appointments =
              snapshot.data as List<Map<String, dynamic>>;

          return ListView.builder(
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              var appointment = appointments[index];

              return ListTile(
                title: Text('Appointment with ${appointment['patientName']}'),
                subtitle: Text(
                    'Date: ${appointment['date']} - Status: ${appointment['status']}'),
                onTap: () {
                  // Navigate to patient details page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PatientDetailsPage(
                          appointmentId: appointment['appointmentId']),
                    ),
                  );
                },
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    // Update appointment status based on user selection
                    if (value == 'Complete') {
                      updateAppointmentStatus(
                          appointment['appointmentId'], 'Completed');
                    } else if (value == 'Pending') {
                      updateAppointmentStatus(
                          appointment['appointmentId'], 'Pending');
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    return ['Complete', 'Pending']
                        .map((status) => PopupMenuItem<String>(
                              value: status,
                              child: Text(status),
                            ))
                        .toList();
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
