// patient_details.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PatientDetailsPage extends StatelessWidget {
  final String appointmentId; // Appointment ID to fetch patient details

  const PatientDetailsPage({super.key, required this.appointmentId});

  // Fetch patient details from Firestore
  Future<Map<String, dynamic>> fetchPatientDetails() async {
    DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
        .collection(
            'appointments') // Collection where appointment details are stored
        .doc(appointmentId)
        .get();

    return docSnapshot.data() as Map<String, dynamic>;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Patient Details'),
      ),
      body: FutureBuilder(
        future: fetchPatientDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error fetching patient data.'));
          }

          Map<String, dynamic> patientData =
              snapshot.data as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Patient Name: ${patientData['patientName']}',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Text('Age: ${patientData['patientAge']}'),
                Text('Gender: ${patientData['patientGender']}'),
                SizedBox(height: 20),
                Text('Medical History:'),
                SizedBox(height: 10),
                Text(patientData['medicalHistory'] ?? 'Not available'),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Here you can add actions to update patient details or other functionality
                  },
                  child: Text('Update Patient Info'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
