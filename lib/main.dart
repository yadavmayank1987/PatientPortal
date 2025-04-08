import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'firebase_options.dart';
import 'login_screen.dart';

// Firebase initialization and app entry point
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); // ✅ Initialize Firebase
  runApp(const PatientPortalApp());
}

class PatientPortalApp extends StatelessWidget {
  const PatientPortalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Patient-Doctor Consultation',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginScreen(),
    );
  }
}

// Home screen with blurred background and options
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/homebg.jpg', // ✅ Ensure this image exists in your assets folder
              fit: BoxFit.cover,
            ),
          ),

          // Blur overlay
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
              child: Container(
                color: Colors.black.withAlpha((0.1 * 255).toInt()),
              ),
            ),
          ),

          // Foreground content
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomButton(
                      text: "New Patient",
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const NewPatientPage()),
                      ),
                    ),
                    const SizedBox(height: 20),
                    CustomButton(
                      text: "Existing Patient",
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ExistingPatientPage()),
                      ),
                    ),
                    const SizedBox(height: 20),
                    CustomButton(
                      text: "View Appointments",
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ViewAppointmentsPage()),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Reusable custom button
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.lightBlue[50],
        foregroundColor: Colors.blue[900],
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class NewPatientPage extends StatefulWidget {
  const NewPatientPage({super.key});

  @override
  State<NewPatientPage> createState() => _NewPatientPageState();
}

class _NewPatientPageState extends State<NewPatientPage> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> formData = {};
  String? gender;
  String? pregnant;
  File? _patientImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery); // or camera

    if (pickedFile != null) {
      setState(() {
        _patientImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("New Patient")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // 📸 Patient photo selector
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: _patientImage != null
                            ? FileImage(_patientImage!)
                            : null,
                        child: _patientImage == null
                            ? const Icon(Icons.person, size: 60)
                            : null,
                      ),
                      TextButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.camera_alt),
                        label: const Text("Select Patient Photo"),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                buildTextField("Name", icon: Icons.person),
                buildTextField("Age",
                    keyboardType: TextInputType.number,
                    icon: Icons.calendar_today),
                buildDropdown("Gender", ["Male", "Female", "Other"], (value) {
                  setState(() {
                    gender = value;
                    formData["Gender"] = value;
                  });
                }, icon: Icons.wc),
                buildDropdown("Pregnant", ["Yes", "No"], (value) {
                  setState(() {
                    pregnant = value;
                    formData["Pregnant"] = value;
                  });
                }, icon: Icons.pregnant_woman),
                buildTextField("Address", icon: Icons.home),
                buildTextField("City", icon: Icons.location_city),
                buildTextField("State", icon: Icons.map),
                buildTextField("Pincode",
                    keyboardType: TextInputType.number, icon: Icons.pin),
                buildTextField("Mobile No",
                    keyboardType: TextInputType.phone, icon: Icons.phone),
                buildTextField("Alternate Mobile No",
                    keyboardType: TextInputType.phone,
                    icon: Icons.phone_android),
                buildTextField("Email",
                    keyboardType: TextInputType.emailAddress,
                    icon: Icons.email),
                buildTextField("Marital Status", icon: Icons.group),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      // You can save _patientImage.path to DB if needed
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ViewAppointmentsPage(),
                        ),
                      );
                    }
                  },
                  child: const Text("Submit"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(
    String label, {
    TextInputType keyboardType = TextInputType.text,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null ? Icon(icon) : null,
          border: const OutlineInputBorder(),
        ),
        onSaved: (value) => formData[label] = value,
        validator: (value) => value!.isEmpty ? 'Please enter $label' : null,
      ),
    );
  }

  Widget buildDropdown(
    String label,
    List<String> items,
    Function(String?) onChanged, {
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null ? Icon(icon) : null,
          border: const OutlineInputBorder(),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: formData[label],
            isExpanded: true,
            hint: Text("Select $label"),
            items: items.map((item) {
              return DropdownMenuItem(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: (value) {
              onChanged(value);
              setState(() {
                formData[label] = value;
              });
            },
          ),
        ),
      ),
    );
  }
}

class ViewAppointmentsPage extends StatelessWidget {
  const ViewAppointmentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> doctors = [
      {
        "name": "Dr. A Sharma",
        "qualification": "MBBS, MD",
        "fees": "₹500",
        "image": "https://via.placeholder.com/100x100.png?text=A"
      },
      {
        "name": "Dr. B Verma",
        "qualification": "MBBS, MS",
        "fees": "₹600",
        "image": "https://via.placeholder.com/100x100.png?text=B"
      },
      {
        "name": "Dr. C Gupta",
        "qualification": "BDS, MDS",
        "fees": "₹450",
        "image": "https://via.placeholder.com/100x100.png?text=C"
      },
      {
        "name": "Dr. D Patel",
        "qualification": "MBBS, DNB",
        "fees": "₹700",
        "image": "https://via.placeholder.com/100x100.png?text=D"
      },
      {
        "name": "Dr. E Reddy",
        "qualification": "MBBS, DCH",
        "fees": "₹400",
        "image": "https://via.placeholder.com/100x100.png?text=E"
      },
      {
        "name": "Dr. F Iyer",
        "qualification": "MBBS, DM",
        "fees": "₹800",
        "image": "https://via.placeholder.com/100x100.png?text=F"
      },
      {
        "name": "Dr. G Khan",
        "qualification": "MBBS, MS",
        "fees": "₹550",
        "image": "https://via.placeholder.com/100x100.png?text=G"
      },
      {
        "name": "Dr. H Das",
        "qualification": "MBBS, MD",
        "fees": "₹500",
        "image": "https://via.placeholder.com/100x100.png?text=H"
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("View Online Doctor")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Doctor List",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: doctors.length,
                itemBuilder: (context, index) {
                  final doctor = doctors[index];

                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      title: Text(
                        doctor["name"]!,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(doctor["qualification"]!),
                          const SizedBox(height: 4),
                          Text(
                            "Fees: ${doctor["fees"]}",
                            style: const TextStyle(color: Colors.green),
                          ),
                        ],
                      ),
                      trailing: CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(doctor["image"]!),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookAppointmentPage(
                              selectedDoctor: doctor["name"]!,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MedicalHistoryPage extends StatefulWidget {
  final String patientName;
  final String couponCode;
  final String fees;

  const MedicalHistoryPage({
    super.key,
    required this.patientName,
    required this.couponCode,
    required this.fees,
  });

  @override
  State<MedicalHistoryPage> createState() => _MedicalHistoryPageState();
}

class _MedicalHistoryPageState extends State<MedicalHistoryPage> {
  int _currentStep = 0;

  // Vitals Controllers
  final _chiefProblemController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _bpController = TextEditingController();
  final _diabeticController = TextEditingController();
  final _pulseController = TextEditingController();
  final _oxygenController = TextEditingController();
  final _respirationController = TextEditingController();
  final _temperatureController = TextEditingController();
  String _tempPosition = 'Oral';

  // Lifestyle Controllers
  bool _alcohol = false;
  bool _tobacco = false;
  final _sleepPatternController = TextEditingController();
  final _allergyDescriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Medical History")),
      body: Stepper(
        type: StepperType.vertical,
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < 1) {
            setState(() => _currentStep += 1);
          } else {
            // Navigate to Family History Page
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const FamilyHistoryPage(),
              ),
            );
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() => _currentStep -= 1);
          }
        },
        steps: [
          /// Step 1 - Vitals
          Step(
            title: const Text("Vitals"),
            isActive: _currentStep == 0,
            content: Column(
              children: [
                TextField(
                    controller: _chiefProblemController,
                    decoration:
                        const InputDecoration(labelText: 'Chief Problem')),
                TextField(
                    controller: _weightController,
                    decoration: const InputDecoration(labelText: 'Weight')),
                TextField(
                    controller: _heightController,
                    decoration: const InputDecoration(labelText: 'Height')),
                TextField(
                    controller: _bpController,
                    decoration:
                        const InputDecoration(labelText: 'BP Systolic')),
                TextField(
                    controller: _diabeticController,
                    decoration: const InputDecoration(labelText: 'Diabetic')),
                TextField(
                    controller: _pulseController,
                    decoration: const InputDecoration(labelText: 'Pulse')),
                TextField(
                    controller: _oxygenController,
                    decoration:
                        const InputDecoration(labelText: 'Oxygen (O2)')),
                TextField(
                    controller: _respirationController,
                    decoration:
                        const InputDecoration(labelText: 'Respiration')),
                TextField(
                    controller: _temperatureController,
                    decoration:
                        const InputDecoration(labelText: 'Temperature')),
                DropdownButton<String>(
                  value: _tempPosition,
                  onChanged: (val) => setState(() => _tempPosition = val!),
                  items: ['Oral', 'Axillary', 'Rectal']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                ),
              ],
            ),
          ),

          /// Step 2 - Lifestyle
          Step(
            title: const Text("Lifestyle"),
            isActive: _currentStep == 1,
            content: Column(
              children: [
                SwitchListTile(
                  title: const Text("Alcohol"),
                  value: _alcohol,
                  onChanged: (val) => setState(() => _alcohol = val),
                ),
                SwitchListTile(
                  title: const Text("Tobacco/Cigarette"),
                  value: _tobacco,
                  onChanged: (val) => setState(() => _tobacco = val),
                ),
                TextField(
                    controller: _sleepPatternController,
                    decoration: const InputDecoration(
                        labelText: 'Sleep Pattern (hours)')),
                TextField(
                    controller: _allergyDescriptionController,
                    decoration: const InputDecoration(
                        labelText: 'Allergy Description')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AppointmentPreviewPage extends StatelessWidget {
  final Map<String, dynamic> vitals;
  final Map<String, dynamic> lifestyle;
  final Map<String, dynamic> reports;
  final Map<String, dynamic> appointment;

  const AppointmentPreviewPage({
    super.key,
    required this.vitals,
    required this.lifestyle,
    required this.reports,
    required this.appointment,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preview & Submit')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildSection('Vitals', vitals),
            _buildSection('Lifestyle', lifestyle),
            _buildSection('Reports', reports),
            _buildSection('Appointment Details', appointment),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Appointment submitted!')),
                );
              },
              child: const Text('Submit Appointment'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, Map<String, dynamic> data) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            ...data.entries.map((e) => ListTile(
                  title: Text(e.key),
                  subtitle: Text(e.value.toString()),
                )),
          ],
        ),
      ),
    );
  }
}

class ExistingPatientPage extends StatelessWidget {
  const ExistingPatientPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Existing Patient")),
      body: const Center(
        child: Text("Existing Patient Page"),
      ),
    );
  }
}

class BookAppointmentPage extends StatefulWidget {
  final String selectedDoctor;
  const BookAppointmentPage({super.key, required this.selectedDoctor});

  @override
  State<BookAppointmentPage> createState() => _BookAppointmentPageState();
}

class _BookAppointmentPageState extends State<BookAppointmentPage> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  final String patientName = "John Doe"; // Placeholder
  final String fees = "₹500";
  final TextEditingController couponController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Book an Appointment")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Patient Name: $patientName",
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text("Doctor: ${widget.selectedDoctor}",
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text("Fees: $fees",
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green)),
            const SizedBox(height: 16),
            TextField(
              controller: couponController,
              decoration: const InputDecoration(
                labelText: "Apply Coupon Code (Optional)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              title: const Text("Select Date"),
              subtitle: Text(selectedDate != null
                  ? DateFormat('yyyy-MM-dd').format(selectedDate!)
                  : 'No date selected'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                DateTime? date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (date != null) {
                  setState(() {
                    selectedDate = date;
                  });
                }
              },
            ),
            ListTile(
              title: const Text("Select Time"),
              subtitle: Text(selectedTime != null
                  ? selectedTime!.format(context)
                  : 'No time selected'),
              trailing: const Icon(Icons.access_time),
              onTap: () async {
                TimeOfDay? time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (time != null) {
                  setState(() {
                    selectedTime = time;
                  });
                }
              },
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: selectedDate != null && selectedTime != null
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ConsultationPage(
                                doctorName: widget.selectedDoctor,
                                appointmentDate: selectedDate!,
                                appointmentTime: selectedTime!,
                                patientName: patientName,
                                couponCode: couponController.text,
                                fees: fees,
                              ),
                            ),
                          );
                        }
                      : null,
                  icon: const Icon(Icons.check),
                  label: const Text("Book Appointment"),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.cancel),
                  label: const Text("Cancel"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ConsultationPage extends StatelessWidget {
  final String doctorName;
  final DateTime appointmentDate;
  final TimeOfDay appointmentTime;
  final String patientName;
  final String couponCode;
  final String fees;

  const ConsultationPage({
    super.key,
    required this.doctorName,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.patientName,
    required this.couponCode,
    required this.fees,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Consultation Details")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Patient: $patientName"),
            Text("Doctor: $doctorName"),
            Text("Date: ${DateFormat('yyyy-MM-dd').format(appointmentDate)}"),
            Text("Time: ${appointmentTime.format(context)}"),
            Text("Fees: $fees"),
            Text("Coupon Code: ${couponCode.isNotEmpty ? couponCode : 'None'}"),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MedicalHistoryPage(
                      patientName: patientName,
                      couponCode: couponCode,
                      fees: fees,
                    ),
                  ),
                );
              },
              child: const Text("Continue to Medical History"),
            )
          ],
        ),
      ),
    );
  }
}

// Make sure this file exists

class FamilyHistoryPage extends StatelessWidget {
  const FamilyHistoryPage({super.key});

  Widget buildSection(String relation) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text("$relation's Health History",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            labelText: "$relation's Disease Name",
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          maxLines: 3,
          decoration: InputDecoration(
            labelText: "$relation's Description",
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            labelText: "$relation's Current Treatment (if any)",
            border: const OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Family History")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              buildSection("Father"),
              buildSection("Mother"),
              buildSection("Sibling"),
              buildSection("Spouse"),
              buildSection("Children"),
              buildSection("Grandfather"),
              buildSection("Grandmother"),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ReportUploadPage(),
                  ),
                ),
                child: const Text("Next: Upload Reports"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ReportUploadPage extends StatefulWidget {
  const ReportUploadPage({super.key});

  @override
  State<ReportUploadPage> createState() => _ReportUploadPageState();
}

class _ReportUploadPageState extends State<ReportUploadPage> {
  final ImagePicker _picker = ImagePicker();

  List<XFile>? _pathologyReports = [];
  List<XFile>? _radiologyReports = [];
  List<XFile>? _prescriptionReports = [];

  Future<void> _pickReports(
      List<XFile>? existingList, Function(List<XFile>) updateList) async {
    final picked = await _picker.pickMultiImage();
    if (picked.isNotEmpty) {
      updateList([...?existingList, ...picked]);
    }
  }

  Widget _displayImages(List<XFile>? images) {
    if (images == null || images.isEmpty) {
      return const Text("No files selected");
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: images
          .map((file) => Image.file(
                File(file.path),
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ))
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload Medical Reports")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Pathology Reports",
                style: TextStyle(fontWeight: FontWeight.bold)),
            ElevatedButton(
              onPressed: () => _pickReports(_pathologyReports,
                  (val) => setState(() => _pathologyReports = val)),
              child: const Text("Upload Pathology Reports"),
            ),
            _displayImages(_pathologyReports),
            const SizedBox(height: 24),
            const Text("Radiology Reports",
                style: TextStyle(fontWeight: FontWeight.bold)),
            ElevatedButton(
              onPressed: () => _pickReports(_radiologyReports,
                  (val) => setState(() => _radiologyReports = val)),
              child: const Text("Upload Radiology Reports"),
            ),
            _displayImages(_radiologyReports),
            const SizedBox(height: 24),
            const Text("Doctor Prescriptions",
                style: TextStyle(fontWeight: FontWeight.bold)),
            ElevatedButton(
              onPressed: () => _pickReports(_prescriptionReports,
                  (val) => setState(() => _prescriptionReports = val)),
              child: const Text("Upload Prescriptions"),
            ),
            _displayImages(_prescriptionReports),
            const SizedBox(height: 32),
            Center(
                child: ElevatedButton.icon(
              icon: const Icon(Icons.check),
              label: const Text("Submit"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PreviewPage(
                      patientName: 'John Doe',
                      doctorName: 'Dr. Smith',
                      appointmentDate: '2025-04-07',
                      appointmentTime: '10:30 AM',
                      couponCode: 'HEALTH10',
                      fees: '₹500',

                      chiefProblem: 'Headache',
                      weight: '70kg',
                      height: '170cm',
                      bp: '120/80',
                      diabetic: 'No',
                      pulse: '72',
                      oxygen: '98%',
                      respiration: '16',
                      temperature: '98.6',
                      tempPosition: 'Oral',

                      alcohol: false,
                      tobacco: false,
                      sleepPattern: '7-8',
                      allergyDescription: 'None',

                      allergyReports: [], // connect your actual variables here
                      pathologyReports: _pathologyReports,
                      radiologyReports: _radiologyReports,
                      prescriptionReports: _prescriptionReports,

                      familyHistory: {
                        'Father': {
                          'disease': 'Diabetes',
                          'description': 'Managed with medication',
                          'treatment': 'Metformin',
                        },
                        'Mother': {
                          'disease': 'Hypertension',
                          'description': 'Controlled with diet',
                          'treatment': 'None',
                        },
                      },
                    ),
                  ),
                );
              },
            ))
          ],
        ),
      ),
    );
  }
}

class PreviewPage extends StatelessWidget {
  final String patientName;
  final String doctorName;
  final String appointmentDate;
  final String appointmentTime;
  final String couponCode;
  final String fees;

  final String chiefProblem;
  final String weight;
  final String height;
  final String bp;
  final String diabetic;
  final String pulse;
  final String oxygen;
  final String respiration;
  final String temperature;
  final String tempPosition;

  final bool alcohol;
  final bool tobacco;
  final String sleepPattern;
  final String allergyDescription;

  final List<XFile>? allergyReports;
  final List<XFile>? pathologyReports;
  final List<XFile>? radiologyReports;
  final List<XFile>? prescriptionReports;

  final Map<String, Map<String, String>> familyHistory;

  const PreviewPage({
    super.key,
    required this.patientName,
    required this.doctorName,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.couponCode,
    required this.fees,
    required this.chiefProblem,
    required this.weight,
    required this.height,
    required this.bp,
    required this.diabetic,
    required this.pulse,
    required this.oxygen,
    required this.respiration,
    required this.temperature,
    required this.tempPosition,
    required this.alcohol,
    required this.tobacco,
    required this.sleepPattern,
    required this.allergyDescription,
    required this.allergyReports,
    required this.pathologyReports,
    required this.radiologyReports,
    required this.prescriptionReports,
    required this.familyHistory,
  });

  Widget _buildImageSection(String title, List<XFile>? images) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        images != null && images.isNotEmpty
            ? Wrap(
                spacing: 8,
                runSpacing: 8,
                children: images
                    .map((file) => Image.file(
                          File(file.path),
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ))
                    .toList(),
              )
            : const Text("No files uploaded"),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildFamilyHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: familyHistory.entries.map((entry) {
        final rel = entry.key;
        final details = entry.value;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("$rel's History",
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Text("Disease: ${details['disease'] ?? ''}"),
            Text("Description: ${details['description'] ?? ''}"),
            Text("Treatment: ${details['treatment'] ?? ''}"),
            const SizedBox(height: 12),
          ],
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Preview All Details")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Patient Name: $patientName"),
            Text("Doctor: $doctorName"),
            Text("Appointment: $appointmentDate at $appointmentTime"),
            Text("Fees: $fees"),
            Text("Coupon: ${couponCode.isEmpty ? 'None' : couponCode}"),
            const Divider(),
            const Text("Vitals", style: TextStyle(fontWeight: FontWeight.bold)),
            Text("Chief Problem: $chiefProblem"),
            Text("Weight: $weight"),
            Text("Height: $height"),
            Text("BP: $bp"),
            Text("Diabetic: $diabetic"),
            Text("Pulse: $pulse"),
            Text("Oxygen: $oxygen"),
            Text("Respiration: $respiration"),
            Text("Temperature: $temperature ($tempPosition)"),
            const Divider(),
            const Text("Lifestyle",
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text("Alcohol: ${alcohol ? 'Yes' : 'No'}"),
            Text("Tobacco: ${tobacco ? 'Yes' : 'No'}"),
            Text("Sleep Pattern: $sleepPattern hrs"),
            Text("Allergy: $allergyDescription"),
            _buildImageSection("Allergy Reports", allergyReports),
            const Divider(),
            const Text("Family History",
                style: TextStyle(fontWeight: FontWeight.bold)),
            _buildFamilyHistorySection(),
            const Divider(),
            _buildImageSection("Pathology Reports", pathologyReports),
            _buildImageSection("Radiology Reports", radiologyReports),
            _buildImageSection("Prescriptions", prescriptionReports),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("All data previewed. Ready to submit.")),
                  );
                },
                icon: const Icon(Icons.check_circle),
                label: const Text("Confirm & Submit"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
