import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data'; // For Binary Video Data

// --- SOCKET IO IMPORT ---
import 'package:socket_io_client/socket_io_client.dart' as IO;

// --- FIREBASE IMPORTS ---
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'firebase_options.dart'; // Ensure this file exists from FlutterFire setup

// --- Safe data helpers ---
int _safeInt(dynamic v, [int d = 0]) {
if (v == null) return d;
if (v is int) return v;
if (v is num) return v.toInt();
if (v is String) return int.tryParse(v) ?? d;
return d;
}

double _safeDouble(dynamic v, [double d = 0.0]) {
if (v == null) return d;
if (v is double) return v;
if (v is num) return v.toDouble();
if (v is String) return double.tryParse(v) ?? d;
return d;
}

// --- MAIN FUNCTION ---
void main() async {
WidgetsFlutterBinding.ensureInitialized();

await Firebase.initializeApp(
options: DefaultFirebaseOptions.currentPlatform,
);

runApp(FarmRobotApp());
}

// --- APP ROOT ---
class FarmRobotApp extends StatelessWidget {
@override
Widget build(BuildContext context) {
return MaterialApp(
debugShowCheckedModeBanner: false,
title: 'ASTRA',
theme: ThemeData.light().copyWith(
primaryColor: Colors.green,
scaffoldBackgroundColor: Colors.white,
appBarTheme: AppBarTheme(
backgroundColor: Colors.green,
foregroundColor: Colors.white,
),
),
home: AuthWrapper(),
);
}
}

// --- AUTH WRAPPER ---
class AuthWrapper extends StatelessWidget {
@override
Widget build(BuildContext context) {
return StreamBuilder<User?>(
stream: FirebaseAuth.instance.authStateChanges(),
builder: (context, snapshot) {
if (snapshot.connectionState == ConnectionState.waiting) {
return Scaffold(body: Center(child: CircularProgressIndicator()));
}
if (snapshot.hasData) {
return MainNavigationScreen();
}
return SplashScreen();
},
);
}
}

// ---------------- Splash Screen ----------------
class SplashScreen extends StatefulWidget {
@override
_SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
with SingleTickerProviderStateMixin {
late AnimationController _controller;
late Animation<double> _scale;
late Animation<double> _fade;

@override
void initState() {
super.initState();
_controller = AnimationController(
vsync: this,
duration: const Duration(seconds: 2),
);
_scale = Tween<double>(begin: 0.7, end: 1.0).animate(
CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
);
_fade = Tween<double>(begin: 0.0, end: 1.0).animate(
CurvedAnimation(parent: _controller, curve: Curves.easeIn),
);
_controller.forward();
Future.delayed(const Duration(seconds: 3), () {
if (mounted) {
Navigator.pushReplacement(
context,
PageRouteBuilder(
transitionDuration: const Duration(milliseconds: 700),
pageBuilder: (_, __, ___) => LanguageSelectionScreen(),
transitionsBuilder: (_, animation, __, child) =>
FadeTransition(opacity: animation, child: child),
),
);
}
});
}

@override
void dispose() {
_controller.dispose();
super.dispose();
}

@override
Widget build(BuildContext context) {
return Scaffold(
body: Container(
decoration: const BoxDecoration(
gradient: LinearGradient(
colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
begin: Alignment.topLeft,
end: Alignment.bottomRight,
),
),
child: Center(
child: FadeTransition(
opacity: _fade,
child: ScaleTransition(
scale: _scale,
child: Column(
mainAxisSize: MainAxisSize.min,
children: const [
Icon(Icons.agriculture, size: 110, color: Colors.white),
SizedBox(height: 20),
Text(
"ASTRA",
style: TextStyle(
fontSize: 32,
fontWeight: FontWeight.bold,
letterSpacing: 2,
color: Colors.white,
),
),
],
),
),
),
),
),
);
}
}

// ---------------- Language Selection Screen ----------------
class LanguageSelectionScreen extends StatefulWidget {
@override
_LanguageSelectionScreenState createState() =>
_LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen>
with SingleTickerProviderStateMixin {
late AnimationController _controller;
late Animation<double> _fadeAnimation;
late Animation<double> _scaleAnimation;
final List<Map<String, dynamic>> _languages = [
{"text": "English", "flag": "🇬🇧"},
{"text": "हिन्दी", "flag": "🇮🇳"},
{"text": "मराठी", "flag": "🌾"},
{"text": "தமிழ்", "flag": "🌿"},
];
@override
void initState() {
super.initState();
_controller = AnimationController(
vsync: this,
duration: const Duration(milliseconds: 1000),
);
_fadeAnimation =
CurvedAnimation(parent: _controller, curve: Curves.easeIn);
_scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
);
_controller.forward();
}

@override
void dispose() {
_controller.dispose();
super.dispose();
}

void _selectLanguage(String language) {
Navigator.pushReplacement(
context,
PageRouteBuilder(
transitionDuration: const Duration(milliseconds: 700),
pageBuilder: (_, __, ___) => LoginScreen(),
transitionsBuilder: (_, animation, __, child) =>
FadeTransition(opacity: animation, child: child),
),
);
}

@override
Widget build(BuildContext context) {
return Scaffold(
body: FadeTransition(
opacity: _fadeAnimation,
child: Container(
decoration: BoxDecoration(
gradient: LinearGradient(
colors: [Colors.green.shade800, Colors.green.shade400],
begin: Alignment.topLeft,
end: Alignment.bottomRight,
),
),
child: Center(
child: ScaleTransition(
scale: _scaleAnimation,
child: Card(
elevation: 12,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(20)),
margin:
const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
child: Padding(
padding: const EdgeInsets.all(24.0),
child: Column(
mainAxisSize: MainAxisSize.min,
children: [
const Icon(Icons.language,
size: 60, color: Colors.green),
const SizedBox(height: 12),
const Text(
"Select Your Language 🌍",
style: TextStyle(
fontSize: 22, fontWeight: FontWeight.bold),
),
const SizedBox(height: 20),
..._languages.map((lang) {
return Padding(
padding: const EdgeInsets.symmetric(vertical: 6.0),
child: ElevatedButton.icon(
onPressed: () => _selectLanguage(lang["text"]),
icon: Text(
lang["flag"],
style: const TextStyle(fontSize: 20),
),
label: Text(
lang["text"],
style: const TextStyle(fontSize: 18),
),
style: ElevatedButton.styleFrom(
minimumSize: const Size(double.infinity, 50),
backgroundColor: Colors.green,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(12),
),
elevation: 5,
shadowColor: Colors.green.withOpacity(0.3),
),
),
);
}).toList(),
const SizedBox(height: 10),
Text(
"You can change language later in settings",
style: TextStyle(color: Colors.grey.shade700),
textAlign: TextAlign.center,
),
],
),
),
),
),
),
),
),
);
}
}

// ---------------- Login Screen ----------------
class LoginScreen extends StatefulWidget {
@override
_LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
with SingleTickerProviderStateMixin {
final _emailController = TextEditingController();
final _passwordController = TextEditingController();
bool _isLoading = false;
late AnimationController _controller;
late Animation<double> _fadeAnimation;
late Animation<double> _scaleAnimation;

@override
void initState() {
super.initState();
_controller =
AnimationController(vsync: this, duration: Duration(seconds: 2));
_fadeAnimation =
Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
parent: _controller,
curve: Curves.easeIn,
));
_scaleAnimation =
Tween<double>(begin: 0.8, end: 1.0).animate(CurvedAnimation(
parent: _controller,
curve: Curves.elasticOut,
));
_controller.forward();
}

@override
void dispose() {
_controller.dispose();
_emailController.dispose();
_passwordController.dispose();
super.dispose();
}

void _login() async {
if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(content: Text("⚠️ Please enter email and password")),
);
return;
}
setState(() {
_isLoading = true;
});

try {
final UserCredential userCredential =
await FirebaseAuth.instance.signInWithEmailAndPassword(
email: _emailController.text.trim(),
password: _passwordController.text.trim(),
);

if (mounted && userCredential.user != null) {
Navigator.pushReplacement(
context,
MaterialPageRoute(builder: (_) => MainNavigationScreen()),
);
}
} on FirebaseAuthException catch (e) {
String message = 'Invalid credentials! Please try again.';
if (e.code == 'user-not-found') {
message = 'No user found for that email.';
} else if (e.code == 'wrong-password') {
message = 'Wrong password provided for that user.';
}
if (mounted) {
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text("❌ $message"), backgroundColor: Colors.red),
);
}
} catch (e) {
if (mounted) {
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text("❌ An unknown error occurred: $e"),
backgroundColor: Colors.red),
);
}
}

if (mounted) {
setState(() {
_isLoading = false;
});
}
}

@override
Widget build(BuildContext context) {
return Scaffold(
body: AnimatedBuilder(
animation: _controller,
builder: (context, child) {
return Container(
decoration: BoxDecoration(
gradient: LinearGradient(
colors: [Colors.green.shade800, Colors.green.shade400],
begin: Alignment.topLeft,
end: Alignment.bottomRight,
),
),
child: Center(
child: FadeTransition(
opacity: _fadeAnimation,
child: ScaleTransition(
scale: _scaleAnimation,
child: Card(
elevation: 12,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(20)),
margin: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
child: Padding(
padding: const EdgeInsets.all(24.0),
child: Column(
mainAxisSize: MainAxisSize.min,
children: [
Icon(Icons.agriculture,
size: 60, color: Colors.green),
SizedBox(height: 12),
Text("Welcome Farmer 👨‍🌾",
style: TextStyle(
fontSize: 22, fontWeight: FontWeight.bold)),
SizedBox(height: 20),
TextField(
controller: _emailController,
decoration: InputDecoration(
labelText: "Email",
prefixIcon:
Icon(Icons.email, color: Colors.green),
border: OutlineInputBorder(
borderRadius: BorderRadius.circular(12),
),
),
keyboardType: TextInputType.emailAddress,
),
SizedBox(height: 12),
TextField(
controller: _passwordController,
obscureText: true,
decoration: InputDecoration(
labelText: "Password",
prefixIcon:
Icon(Icons.lock, color: Colors.green),
border: OutlineInputBorder(
borderRadius: BorderRadius.circular(12),
),
),
),
SizedBox(height: 20),
_isLoading
? CircularProgressIndicator()
: ElevatedButton.icon(
onPressed: _login,
style: ElevatedButton.styleFrom(
backgroundColor: Colors.green,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(12),
),
padding: EdgeInsets.symmetric(
horizontal: 40, vertical: 12),
),
icon: Icon(Icons.login, color: Colors.white),
label: Text("Login",
style: TextStyle(
fontSize: 16, color: Colors.white)),
),
SizedBox(height: 12),
TextButton(
onPressed: () {
Navigator.push(
context,
MaterialPageRoute(
builder: (_) => RegisterScreen(),
),
);
},
child:
Text("🌱 Don’t have an account? Register"),
),
],
),
),
),
),
),
),
);
},
),
);
}
}

// ---------------- Register Screen ----------------
class RegisterScreen extends StatefulWidget {
@override
_RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
with SingleTickerProviderStateMixin {
final _emailController = TextEditingController();
final _passwordController = TextEditingController();
bool _isLoading = false;
late AnimationController _controller;
late Animation<double> _slideAnimation;

@override
void initState() {
super.initState();
_controller =
AnimationController(vsync: this, duration: Duration(milliseconds: 800));
_slideAnimation =
Tween<double>(begin: 100, end: 0).animate(CurvedAnimation(
parent: _controller,
curve: Curves.easeOut,
));
_controller.forward();
}

@override
void dispose() {
_controller.dispose();
_emailController.dispose();
_passwordController.dispose();
super.dispose();
}

void _register() async {
if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(content: Text("⚠️ Please fill in all fields")),
);
return;
}
setState(() {
_isLoading = true;
});

try {
final UserCredential userCredential =
await FirebaseAuth.instance.createUserWithEmailAndPassword(
email: _emailController.text.trim(),
password: _passwordController.text.trim(),
);
String? userId = userCredential.user?.uid;
if (userId != null) {
DatabaseReference userRef =
FirebaseDatabase.instance.ref('users/$userId');
await userRef.set({
'uid': userId,
'email': _emailController.text.trim(),
'farmerName': 'New Farmer',
'phoneNumber': '',
'role': 'Farmer',
'joinedAt': ServerValue.timestamp
});
}
if (mounted) {
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text("✅ Registration Successful! Please log in."),
backgroundColor: Colors.green,
),
);
Navigator.pop(context);
}
} on FirebaseAuthException catch (e) {
String message = 'An error occurred';
if (e.code == 'weak-password') {
message = 'The password provided is too weak.';
} else if (e.code == 'email-already-in-use') {
message = 'The account already exists for that email.';
}
if (mounted) {
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text("❌ $message"), backgroundColor: Colors.red),
);
}
} catch (e) {
if (mounted) {
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text("❌ An unknown error occurred: $e"),
backgroundColor: Colors.red),
);
}
}

setState(() {
_isLoading = false;
});
}

@override
Widget build(BuildContext context) {
return Scaffold(
body: AnimatedBuilder(
animation: _controller,
builder: (_, __) {
return Transform.translate(
offset: Offset(0, _slideAnimation.value),
child: Container(
decoration: BoxDecoration(
gradient: LinearGradient(
colors: [Colors.green.shade400, Colors.green.shade700],
begin: Alignment.topCenter,
end: Alignment.bottomCenter,
),
),
child: Center(
child: Card(
elevation: 12,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(20)),
margin: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
child: Padding(
padding: const EdgeInsets.all(24.0),
child: Column(
mainAxisSize: MainAxisSize.min,
children: [
Icon(Icons.person_add, size: 60, color: Colors.green),
SizedBox(height: 12),
Text("Register Farmer 🌾",
style: TextStyle(
fontSize: 22, fontWeight: FontWeight.bold)),
SizedBox(height: 20),
TextField(
controller: _emailController,
decoration: InputDecoration(
labelText: "Email",
prefixIcon:
Icon(Icons.email, color: Colors.green),
border: OutlineInputBorder(
borderRadius: BorderRadius.circular(12),
),
),
keyboardType: TextInputType.emailAddress,
),
SizedBox(height: 12),
TextField(
controller: _passwordController,
obscureText: true,
decoration: InputDecoration(
labelText: "Password",
prefixIcon:
Icon(Icons.lock, color: Colors.green),
border: OutlineInputBorder(
borderRadius: BorderRadius.circular(12),
),
),
),
SizedBox(height: 20),
_isLoading
? CircularProgressIndicator()
: ElevatedButton.icon(
onPressed: _register,
style: ElevatedButton.styleFrom(
backgroundColor: Colors.green,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(12),
),
padding: EdgeInsets.symmetric(
horizontal: 40, vertical: 12),
),
icon: Icon(Icons.check, color: Colors.white),
label: Text("Register",
style: TextStyle(
fontSize: 16, color: Colors.white)),
),
],
),
),
),
),
),
);
},
),
);
}
}

// ---------------- Main Navigation ----------------
class MainNavigationScreen extends StatefulWidget {
@override
_MainNavigationScreenState createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
int _selectedIndex = 0;
final List<Widget> _screens = [
DashboardScreen(),
StatsScreen(),
SoilHealthScreen(),
ProfileScreen(),
];

void _onItemTapped(int index) {
setState(() {
_selectedIndex = index;
});
}

@override
Widget build(BuildContext context) {
return Scaffold(
body: _screens[_selectedIndex],
bottomNavigationBar: BottomNavigationBar(
type: BottomNavigationBarType.fixed,
currentIndex: _selectedIndex,
selectedItemColor: Colors.green,
unselectedItemColor: Colors.grey,
onTap: _onItemTapped,
items: [
BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Home"),
BottomNavigationBarItem(icon: Icon(Icons.analytics), label: "Stats"),
BottomNavigationBarItem(icon: Icon(Icons.grass), label: "Soil"),
BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
],
),
);
}
}

// ---------------- Dashboard ----------------
class DashboardScreen extends StatelessWidget {
final DatabaseReference _dashboardRef =
FirebaseDatabase.instance.ref('robot/dashboard');

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(title: const Text("ASTRA Dashboard")),
body: StreamBuilder(
stream: _dashboardRef.onValue,
builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
if (snapshot.connectionState == ConnectionState.waiting) {
return const Center(child: CircularProgressIndicator());
}
if (snapshot.hasError) {
return const Center(child: Text('Error loading data.'));
}

// Default values if no data exists
int robotBattery = 0;
int totalPlants = 0;
int affectedPlants = 0;
int diseasesDetected = 0;
int pesticideLeft = 0;

if (snapshot.hasData &&
snapshot.data!.snapshot.value != null &&
snapshot.data!.snapshot.value is Map) {
final Map<dynamic, dynamic> data =
snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
robotBattery = _safeInt(data['robotBattery']);
totalPlants = _safeInt(data['totalPlants']);
affectedPlants = _safeInt(data['affectedPlants']);
diseasesDetected = _safeInt(data['diseasesDetected']);
pesticideLeft = _safeInt(data['pesticideLeft']);
}

// --- Dashboard Summary Cards ---
final summaryItems = [
{
"title": "Total Plants",
"value": "$totalPlants",
"color": Colors.green.shade700,
"isCircular": false,
},
{
"title": "Affected Plants",
"value": "$affectedPlants",
"color": Colors.red.shade700,
"isCircular": true,
"percent":
totalPlants > 0 ? (affectedPlants / totalPlants) : 0.0,
},
{
"title": "Diseases Detected",
"value": "$diseasesDetected",
"color": Colors.orange.shade700,
"isCircular": false,
},
{
"title": "Pesticide Left",
"value": "$pesticideLeft%",
"color": Colors.blue.shade700,
"isCircular": true,
"percent": pesticideLeft / 100.0,
},
{
"title": "Robot Battery",
"value": "$robotBattery%",
"color": robotBattery > 30 ? Colors.green : Colors.red,
"isCircular": true,
"percent": robotBattery / 100.0,
},
];

// --- Main UI Layout ---
return Padding(
padding: const EdgeInsets.all(16.0),
child: Column(
children: [
// --- Summary Cards Grid ---
Expanded(
flex: 2,
child: GridView.builder(
gridDelegate:
const SliverGridDelegateWithFixedCrossAxisCount(
crossAxisCount: 2,
crossAxisSpacing: 10,
mainAxisSpacing: 10,
),
itemCount: summaryItems.length,
itemBuilder: (context, index) {
final item = summaryItems[index];
return AnimatedSummaryCard(
title: item["title"] as String,
value: item["value"] as String,
color: item["color"] as Color,
delayMilliseconds: index * 200,
isCircular: item["isCircular"] as bool,
percent: item["percent"] != null
? item["percent"] as double
: 0.0,
);
},
),
),

const SizedBox(height: 20),

// --- Quick Action Buttons Row ---
Expanded(
flex: 1,
child: Row(
mainAxisAlignment: MainAxisAlignment.spaceEvenly,
children: [
QuickButton(
icon: Icons.videocam,
label: "Live Video",
onTap: () {
Navigator.push(
context,
MaterialPageRoute(
builder: (_) => const LiveVideoScreen(),
),
);
},
),
QuickButton(
icon: Icons.map,
label: "Map",
onTap: () {
Navigator.push(
context,
MaterialPageRoute(
builder: (_) => RobotMapScreen(),
),
);
},
),
// Place holder for future weather screen
QuickButton(
icon: Icons.cloud,
label: "Weather",
onTap: () {
ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Weather Feature Coming Soon!")));
},
),
],
),
),
],
),
);
},
),
);
}
}

// ---------------- Animated Summary Card ----------------
class AnimatedSummaryCard extends StatefulWidget {
final String title;
final String value;
final Color color;
final int delayMilliseconds;
final bool isCircular;
final double percent;
AnimatedSummaryCard({
required this.title,
required this.value,
required this.color,
required this.delayMilliseconds,
this.isCircular = false,
this.percent = 0.0,
});
@override
_AnimatedSummaryCardState createState() => _AnimatedSummaryCardState();
}

class _AnimatedSummaryCardState extends State<AnimatedSummaryCard>
with SingleTickerProviderStateMixin {
late AnimationController _controller;
late Animation<double> _scaleAnimation;
late Animation<double> _progressAnimation;
@override
void initState() {
super.initState();
_controller =
AnimationController(vsync: this, duration: Duration(milliseconds: 700));
_scaleAnimation =
Tween<double>(begin: 0.8, end: 1.0).animate(CurvedAnimation(
parent: _controller,
curve: Curves.elasticOut,
));
_progressAnimation =
Tween<double>(begin: 0.0, end: widget.percent).animate(CurvedAnimation(
parent: _controller,
curve: Curves.easeOut,
));
Future.delayed(Duration(milliseconds: widget.delayMilliseconds), () {
if (mounted) _controller.forward();
});
}

@override
void dispose() {
_controller.dispose();
super.dispose();
}

@override
Widget build(BuildContext context) {
return ScaleTransition(
scale: _scaleAnimation,
child: Card(
elevation: 4,
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
child: Padding(
padding: const EdgeInsets.all(16.0),
child: widget.isCircular
? AnimatedBuilder(
animation: _progressAnimation,
builder: (context, child) {
return Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
SizedBox(
width: 60,
height: 60,
child: CircularProgressIndicator(
value: _progressAnimation.value,
color: widget.color,
backgroundColor: widget.color.withOpacity(0.2),
strokeWidth: 6,
),
),
SizedBox(height: 10),
Text(widget.title,
style: TextStyle(
color: Colors.grey[800], fontSize: 16)),
SizedBox(height: 5),
Text(widget.value,
style: TextStyle(
color: widget.color,
fontSize: 20,
fontWeight: FontWeight.bold)),
],
);
},
)
: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
Text(widget.title,
style:
TextStyle(color: Colors.grey[800], fontSize: 16)),
SizedBox(height: 10),
Text(widget.value,
style: TextStyle(
color: widget.color,
fontSize: 28,
fontWeight: FontWeight.bold)),
],
),
),
),
);
}
}

// ---------------- Quick Button ----------------
class QuickButton extends StatefulWidget {
final IconData icon;
final String label;
final VoidCallback onTap;
QuickButton({required this.icon, required this.label, required this.onTap});

@override
_QuickButtonState createState() => _QuickButtonState();
}

class _QuickButtonState extends State<QuickButton>
with SingleTickerProviderStateMixin {
late AnimationController _controller;
late Animation<double> _scale;
late Animation<double> _rotation;
bool _pressed = false;
@override
void initState() {
super.initState();
_controller = AnimationController(
vsync: this,
duration: Duration(milliseconds: 150),
lowerBound: 0.0,
upperBound: 0.1,
);
_scale = Tween<double>(begin: 1.0, end: 0.9).animate(
CurvedAnimation(parent: _controller, curve: Curves.easeOut));
_rotation = Tween<double>(begin: 0.0, end: 0.15).animate(
CurvedAnimation(parent: _controller, curve: Curves.easeOut));
}

@override
void dispose() {
_controller.dispose();
super.dispose();
}

void _onTapDown(TapDownDetails details) {
_controller.forward();
setState(() {
_pressed = true;
});
}

void _onTapUp(TapUpDetails details) {
_controller.reverse();
setState(() {
_pressed = false;
});
widget.onTap();
}

void _onTapCancel() {
_controller.reverse();
setState(() {
_pressed = false;
});
}

@override
Widget build(BuildContext context) {
return GestureDetector(
onTapDown: _onTapDown,
onTapUp: _onTapUp,
onTapCancel: _onTapCancel,
child: AnimatedBuilder(
animation: _controller,
builder: (context, child) {
return Transform.scale(
scale: _scale.value,
child: Transform.rotate(
angle: _rotation.value * (_pressed ? 1 : 0),
child: Column(
children: [
AnimatedContainer(
duration: Duration(milliseconds: 200),
curve: Curves.easeInOut,
decoration: BoxDecoration(
color: _pressed ? Colors.green.shade800 : Colors.green,
shape: BoxShape.circle,
boxShadow: [
if (!_pressed)
BoxShadow(
color: Colors.green.withOpacity(0.4),
blurRadius: 8,
offset: Offset(0, 4),
),
],
),
child: CircleAvatar(
radius: 28,
backgroundColor: Colors.transparent,
child: Icon(widget.icon, color: Colors.white, size: 28),
),
),
SizedBox(height: 8),
Text(widget.label,
style: TextStyle(
color:
_pressed ? Colors.green.shade800 : Colors.black87,
fontWeight: FontWeight.w600)),
],
),
),
);
},
),
);
}
}

// ---------------- Stats Screen ----------------
class StatsScreen extends StatefulWidget {
@override
_StatsScreenState createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen>
with TickerProviderStateMixin {
final Query _statsQuery =
FirebaseDatabase.instance.ref('robot/plant-stats').orderByChild('name');
@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(title: Text("Plant Statistics")),
body: FirebaseAnimatedList(
query: _statsQuery,
padding: EdgeInsets.all(16),
itemBuilder: (context, DataSnapshot snapshot,
Animation<double> animation, int index) {
if (snapshot.value == null || snapshot.value is! Map) {
return SizedBox.shrink();
}
Map<dynamic, dynamic> plantData =
snapshot.value as Map<dynamic, dynamic>;
return _AnimatedPlantCard(
name: plantData['name'] ?? 'Unknown Plant',
disease: plantData['disease'] ?? 'N/A',
severity: _safeDouble(plantData['severity']),
delay: index * 150,
);
},
),
);
}
}

class _AnimatedPlantCard extends StatefulWidget {
final String name;
final String disease;
final double severity;
final int delay;
_AnimatedPlantCard({
required this.name,
required this.disease,
required this.severity,
required this.delay,
});

@override
__AnimatedPlantCardState createState() => __AnimatedPlantCardState();
}

class __AnimatedPlantCardState extends State<_AnimatedPlantCard>
with SingleTickerProviderStateMixin {
late AnimationController _controller;
late Animation<double> _scaleAnimation;
late Animation<Offset> _slideAnimation;
@override
void initState() {
super.initState();
_controller = AnimationController(
vsync: this, duration: Duration(milliseconds: 500));
_scaleAnimation =
Tween<double>(begin: 0.9, end: 1.0).animate(CurvedAnimation(
parent: _controller,
curve: Curves.elasticOut,
));
_slideAnimation =
Tween<Offset>(begin: Offset(0, 0.3), end: Offset.zero).animate(
CurvedAnimation(parent: _controller, curve: Curves.easeOut));
Future.delayed(Duration(milliseconds: widget.delay), () {
if (mounted) _controller.forward();
});
}

@override
void dispose() {
_controller.dispose();
super.dispose();
}

void _onTap() async {
await _controller.forward();
await _controller.reverse();
_controller.forward();
}

@override
Widget build(BuildContext context) {
Color severityColor;
if (widget.severity > 0.7) {
severityColor = Colors.red;
} else if (widget.severity > 0.4) {
severityColor = Colors.orange;
} else {
severityColor = Colors.green;
}
return GestureDetector(
onTap: _onTap,
child: SlideTransition(
position: _slideAnimation,
child: ScaleTransition(
scale: _scaleAnimation,
child: Card(
elevation: 3,
shape:
RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
margin: EdgeInsets.symmetric(vertical: 8),
child: Padding(
padding: const EdgeInsets.all(16.0),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(widget.name,
style:
TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
SizedBox(height: 6),
Text("Disease: ${widget.disease}",
style: TextStyle(fontSize: 16, color: severityColor)),
SizedBox(height: 10),
LinearProgressIndicator(
value: widget.severity,
color: severityColor,
backgroundColor: severityColor.withOpacity(0.2),
minHeight: 8,
),
],
),
),
),
),
),
);
}
}

// ---------------- Soil Health Screen ----------------
class SoilHealthScreen extends StatelessWidget {
final DatabaseReference _soilRef =
FirebaseDatabase.instance.ref('robot/soil-health');
@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(title: Text("Soil Health")),
body: StreamBuilder(
stream: _soilRef.onValue,
builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
if (snapshot.connectionState == ConnectionState.waiting) {
return Center(child: CircularProgressIndicator());
}
if (snapshot.hasError) {
return Center(child: Text('Error loading soil data.'));
}

double moisturePercent = 0.0;
double phValue = 0.0;
String nitrogen = 'N/A';
String potassium = 'N/A';

if (snapshot.hasData &&
snapshot.data!.snapshot.value != null &&
snapshot.data!.snapshot.value is Map) {
Map<dynamic, dynamic> data =
snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
moisturePercent = _safeDouble(data['moisture']);
phValue = _safeDouble(data['ph']);
nitrogen = (data['nitrogen'] ?? 'N/A').toString();
potassium = (data['potassium'] ?? 'N/A').toString();
}

final List<Map<String, dynamic>> soilMetrics = [
{
"title": "Moisture Level",
"value": "${(moisturePercent * 100).toStringAsFixed(0)}%",
"icon": Icons.water_drop,
"color": Colors.blue,
"percent": moisturePercent
},
{
"title": "Soil pH",
"value": "$phValue (Optimal)",
"icon": Icons.eco,
"color": Colors.green,
"percent": (phValue / 14.0)
},
{
"title": "Nutrient Level",
"value": "Nitrogen: $nitrogen, Potassium: $potassium",
"icon": Icons.energy_savings_leaf,
"color": Colors.orange,
"percent": 0.75
},
];
return Padding(
padding: const EdgeInsets.all(16.0),
child: ListView.builder(
itemCount: soilMetrics.length,
itemBuilder: (context, index) {
final item = soilMetrics[index];
return _AnimatedSoilCard(
icon: item["icon"],
title: item["title"],
value: item["value"],
color: item["color"],
percent: (item["percent"] as double),
delay: index * 200,
);
},
),
);
},
),
);
}
}

class _AnimatedSoilCard extends StatefulWidget {
final IconData icon;
final String title;
final String value;
final Color color;
final double percent;
final int delay;
_AnimatedSoilCard({
required this.icon,
required this.title,
required this.value,
required this.color,
required this.percent,
required this.delay,
});

@override
__AnimatedSoilCardState createState() => __AnimatedSoilCardState();
}

class __AnimatedSoilCardState extends State<_AnimatedSoilCard>
with SingleTickerProviderStateMixin {
late AnimationController _controller;
late Animation<double> _scaleAnimation;
late Animation<Offset> _slideAnimation;
@override
void initState() {
super.initState();
_controller = AnimationController(
vsync: this, duration: Duration(milliseconds: 500));
_scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(CurvedAnimation(
parent: _controller,
curve: Curves.elasticOut,
));
_slideAnimation =
Tween<Offset>(begin: Offset(0, 0.3), end: Offset.zero).animate(
CurvedAnimation(parent: _controller, curve: Curves.easeOut));
Future.delayed(Duration(milliseconds: widget.delay), () {
if (mounted) _controller.forward();
});
}

@override
void dispose() {
_controller.dispose();
super.dispose();
}

void _onTap() async {
await _controller.forward();
await _controller.reverse();
_controller.forward();
}

@override
Widget build(BuildContext context) {
return GestureDetector(
onTap: _onTap,
child: SlideTransition(
position: _slideAnimation,
child: ScaleTransition(
scale: _scaleAnimation,
child: Card(
elevation: 4,
shape:
RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
margin: EdgeInsets.symmetric(vertical: 8),
child: Padding(
padding: const EdgeInsets.all(16.0),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Row(
children: [
Icon(widget.icon, color: widget.color, size: 30),
SizedBox(width: 12),
Text(widget.title,
style: TextStyle(
fontSize: 18, fontWeight: FontWeight.bold)),
],
),
SizedBox(height: 8),
Text(widget.value,
style: TextStyle(fontSize: 16, color: Colors.grey[700])),
SizedBox(height: 12),
LinearProgressIndicator(
value: widget.percent,
color: widget.color,
backgroundColor: widget.color.withOpacity(0.2),
minHeight: 8,
),
],
),
),
),
),
),
);
}
}

// ---------------- Profile Screen ----------------
class ProfileScreen extends StatefulWidget {
@override
_ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
with TickerProviderStateMixin {
File? _profileImage;
final picker = ImagePicker();
final User? currentUser = FirebaseAuth.instance.currentUser;
late DatabaseReference _userRef;
late AnimationController _screenController;
late Animation<double> _screenFade;
late Animation<Offset> _slideAnimation;
late AnimationController _profilePicController;
late Animation<double> _profileScale;

@override
void initState() {
super.initState();
if (currentUser != null) {
_userRef = FirebaseDatabase.instance.ref('users/${currentUser!.uid}');
}
_screenController =
AnimationController(vsync: this, duration: Duration(milliseconds: 800));
_screenFade =
CurvedAnimation(parent: _screenController, curve: Curves.easeIn);
_slideAnimation =
Tween<Offset>(begin: Offset(0, 0.2), end: Offset.zero).animate(
CurvedAnimation(parent: _screenController, curve: Curves.easeOut));
_screenController.forward();
_profilePicController =
AnimationController(vsync: this, duration: Duration(milliseconds: 200));
_profileScale =
Tween<double>(begin: 1.0, end: 1.1).animate(_profilePicController);
}

@override
void dispose() {
_screenController.dispose();
_profilePicController.dispose();
super.dispose();
}

Future<void> _pickImage() async {
final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
if (pickedFile != null) {
File imageFile = File(pickedFile.path);
setState(() {
_profileImage = imageFile;
});
try {
String? userId = currentUser?.uid;
if (userId == null) return;
final storageRef = FirebaseStorage.instance
.ref()
.child('user_profile_pics')
.child('$userId.jpg');
final uploadTask = storageRef.putFile(imageFile);
final snapshot = await uploadTask.whenComplete(() => null);
final downloadUrl = await snapshot.ref.getDownloadURL();
await currentUser?.updatePhotoURL(downloadUrl);
await _userRef.update({'photoUrl': downloadUrl});
if (mounted) {
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text("✅ Profile image updated!"),
backgroundColor: Colors.green,
),
);
}
} catch (e) {
if (mounted) {
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text("❌ Failed to upload image: $e"),
backgroundColor: Colors.red,
),
);
}
}
}
}

Future<void> _logout() async {
await FirebaseAuth.instance.signOut();
}

Widget _bounceWidget({required Widget child, required VoidCallback onTap}) {
return _BounceAnimation(child: child, onTap: onTap);
}

Widget _buildInfoCard(
IconData icon, String title, String value, {VoidCallback? onTap}) {
Widget card = Card(
elevation: 3,
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
child: ListTile(
leading: Icon(icon, color: Colors.green),
title: Text(title),
subtitle: Text(value),
trailing: onTap != null ? Icon(Icons.edit, color: Colors.green) : null,
),
);
return onTap != null ? _bounceWidget(child: card, onTap: onTap) : card;
}

Widget _buildDeviceCard(String deviceName) {
return _bounceWidget(
child: Card(
elevation: 2,
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
child: ListTile(
leading: Icon(Icons.devices, color: Colors.blue),
title: Text(deviceName),
),
),
onTap: () {
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(content: Text("Tapped on $deviceName")),
);
},
);
}

@override
Widget build(BuildContext context) {
if (currentUser == null) {
return Scaffold(
appBar: AppBar(title: Text("Profile")),
body: Center(
child: Text("Error: Not logged in."),
),
);
}
return StreamBuilder(
stream: _userRef.onValue,
builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
if (snapshot.connectionState == ConnectionState.waiting) {
return Scaffold(appBar: AppBar(title: Text("Profile")), body: Center(child: CircularProgressIndicator()));
}
if (snapshot.hasError) {
return Scaffold(appBar: AppBar(title: Text("Profile")), body: Center(child: Text("Error loading profile.")));
}

String farmerName = 'No Name Set';
String phoneNumber = 'No Phone Set';
String role = 'Farmer';
String? photoUrl;

if (snapshot.hasData && snapshot.data!.snapshot.value != null && snapshot.data!.snapshot.value is Map) {
Map<dynamic, dynamic> userData =
snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
farmerName = userData['farmerName'] ?? 'No Name Set';
phoneNumber = userData['phoneNumber'] ?? 'No Phone Set';
role = userData['role'] ?? 'Farmer';
photoUrl = userData['photoUrl'];
}

String email = currentUser!.email!;
List<String> connectedDevices = ["Robot-01", "Soil Sensor"];

return Scaffold(
appBar: AppBar(title: Text("Profile")),
body: FadeTransition(
opacity: _screenFade,
child: SlideTransition(
position: _slideAnimation,
child: SingleChildScrollView(
padding: const EdgeInsets.all(24.0),
child: Column(
children: [
GestureDetector(
onTap: () async {
_profilePicController.forward().then((_) {
_profilePicController.reverse();
});
await _pickImage();
},
child: ScaleTransition(
scale: _profileScale,
child: CircleAvatar(
radius: 60,
backgroundColor: Colors.green[100],
backgroundImage: _profileImage != null
? FileImage(_profileImage!)
: (photoUrl != null && photoUrl!.isNotEmpty)
? NetworkImage(photoUrl!)
: null as ImageProvider?,
child: (_profileImage == null && (photoUrl == null || photoUrl!.isEmpty))
? const Icon(Icons.person, size: 50, color: Colors.green)
: null,
),
),
),
SizedBox(height: 16),
Text(farmerName,
style:
TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
SizedBox(height: 6),
Text(email, style: TextStyle(color: Colors.grey[700])),
SizedBox(height: 20),
_buildInfoCard(Icons.phone, "Phone Number", phoneNumber,
onTap: () {
}),
_buildInfoCard(Icons.person, "Role", role),
SizedBox(height: 10),
Align(
alignment: Alignment.centerLeft,
child: Text(
"Connected Devices",
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.bold,
color: Colors.green.shade700),
),
),
SizedBox(height: 6),
Column(
children: connectedDevices
.map((device) => _buildDeviceCard(device))
.toList(),
),
SizedBox(height: 30),
Row(
mainAxisAlignment: MainAxisAlignment.spaceEvenly,
children: [
ElevatedButton.icon(
onPressed: () {
},
icon: Icon(Icons.edit, color: Colors.white),
label: Text("Edit Profile", style: TextStyle(color: Colors.white)),
style: ElevatedButton.styleFrom(
backgroundColor: Colors.green.shade700),
),
ElevatedButton.icon(
onPressed: _logout,
icon: Icon(Icons.logout, color: Colors.white),
label: Text("Logout", style: TextStyle(color: Colors.white)),
style: ElevatedButton.styleFrom(
backgroundColor: Colors.red),
),
],
),
],
),
),
),
),
);
},
);
}
}

// ---------------- Bounce animation widget ----------------
class _BounceAnimation extends StatefulWidget {
final Widget child;
final VoidCallback onTap;
_BounceAnimation({required this.child, required this.onTap});

@override
__BounceAnimationState createState() => __BounceAnimationState();
}

class __BounceAnimationState extends State<_BounceAnimation>
with SingleTickerProviderStateMixin {
late AnimationController _controller;
late Animation<double> _animation;

@override
void initState() {
super.initState();
_controller = AnimationController(
vsync: this, duration: Duration(milliseconds: 100));
_animation = Tween<double>(begin: 1.0, end: 0.95).animate(
CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
}

@override
void dispose() {
_controller.dispose();
super.dispose();
}

@override
Widget build(BuildContext context) {
return GestureDetector(
onTap: () async {
await _controller.forward();
await _controller.reverse();
widget.onTap();
},
child: AnimatedBuilder(
animation: _animation,
builder: (context, child) {
return Transform.scale(scale: _animation.value, child: widget.child);
},
),
);
}
}

// -----------------------------------------------------
// ---------------- NEW LIVE VIDEO SCREEN -----------------
// -----------------------------------------------------

class LiveVideoScreen extends StatefulWidget {
const LiveVideoScreen({Key? key}) : super(key: key);

@override
State<LiveVideoScreen> createState() => _LiveVideoScreenState();
}

class _LiveVideoScreenState extends State<LiveVideoScreen> {
// 1. CONFIGURATION
// IP from your setup
final String serverUrl = 'http://192.168.0.149:5000';
final String robotId = 'robot_1';

late IO.Socket socket;
Uint8List? _videoFrame;
bool _isConnected = false;
String _statusText = "Connecting to ASTRA...";

@override
void initState() {
super.initState();
_connectToSocket();
}

// 2. SOCKET CONNECTION LOGIC
void _connectToSocket() {
try {
socket = IO.io(serverUrl, IO.OptionBuilder()
.setTransports(['websocket'])
.disableAutoConnect()
.build());

socket.connect();

socket.onConnect((_) {
print("✅ Connected to Server");
if (mounted) {
setState(() {
_isConnected = true;
_statusText = "Connected - Waiting for Video";
});
}
socket.emit('join_device', {'id': robotId, 'type': 'app'});
});

socket.on('app_video_update', (data) {
if (mounted && data != null) {
setState(() {
_videoFrame = Uint8List.fromList(List<int>.from(data));
_statusText = "Live Feed Active";
});
}
});

socket.onDisconnect((_) {
if (mounted) {
setState(() {
_isConnected = false;
_statusText = "Disconnected";
});
}
});

} catch (e) {
print("Socket Error: $e");
setState(() => _statusText = "Connection Error: $e");
}
}

// 3. SEND COMMANDS
void _sendCommand(String cmd) {
if (_isConnected) {
print("Sending Command: $cmd");
socket.emit('app_command', {'id': robotId, 'command': cmd});
} else {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(content: Text("⚠️ Not connected to Robot"), duration: Duration(milliseconds: 500)),
);
}
}

@override
void dispose() {
socket.disconnect();
super.dispose();
}

@override
Widget build(BuildContext context) {
return Scaffold(
body: Container(
decoration: const BoxDecoration(
gradient: LinearGradient(
colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
begin: Alignment.topLeft,
end: Alignment.bottomRight,
),
),
child: SafeArea(
child: Column(
children: [
// --- HEADER ---
Padding(
padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
child: Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
const Text(
"🤖 Live ASTRA View",
style: TextStyle(
color: Colors.white,
fontSize: 22,
fontWeight: FontWeight.bold,
),
),
Container(
padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
decoration: BoxDecoration(
color: Colors.black26,
borderRadius: BorderRadius.circular(12)
),
child: Row(
children: [
Icon(Icons.circle, color: _isConnected ? Colors.greenAccent : Colors.red, size: 12),
SizedBox(width: 5),
Text(_isConnected ? "ONLINE" : "OFFLINE", style: TextStyle(color: Colors.white, fontSize: 10)),
],
),
)
],
),
),

const SizedBox(height: 10),

// --- VIDEO FEED CONTAINER ---
Expanded(
child: Center(
child: AnimatedContainer(
duration: const Duration(seconds: 1),
margin: const EdgeInsets.symmetric(horizontal: 16),
decoration: BoxDecoration(
color: Colors.black,
borderRadius: BorderRadius.circular(22),
border: Border.all(color: Colors.greenAccent, width: 2),
boxShadow: [
BoxShadow(
color: Colors.black45,
blurRadius: 15,
spreadRadius: 2,
),
],
),
child: ClipRRect(
borderRadius: BorderRadius.circular(20),
child: _videoFrame == null
? Center(
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
CircularProgressIndicator(color: Colors.greenAccent),
SizedBox(height: 10),
Text(_statusText, style: TextStyle(color: Colors.white70)),
],
),
)
: Image.memory(
_videoFrame!,
gaplessPlayback: true,
fit: BoxFit.contain,
width: double.infinity,
),
),
),
),
),

const SizedBox(height: 18),

// --- ROBOT CONTROLS ---
Padding(
padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
child: Column(
children: [
_controlButton(Icons.arrow_upward, "FORWARD"),
Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
_controlButton(Icons.arrow_back, "LEFT"),
_controlButton(Icons.stop_circle_outlined, "STOP", isStop: true),
_controlButton(Icons.arrow_forward, "RIGHT"),
],
),
_controlButton(Icons.arrow_downward, "BACKWARD"),
],
),
),
],
),
),
),
);
}

Widget _controlButton(IconData icon, String command, {bool isStop = false}) {
return GestureDetector(
onTapDown: (_) => _sendCommand(command),
onTapUp: (_) => isStop ? {} : _sendCommand("STOP"),
child: Container(
margin: const EdgeInsets.all(8),
padding: const EdgeInsets.all(15),
decoration: BoxDecoration(
color: isStop ? Colors.redAccent : Colors.green.shade800,
shape: BoxShape.circle,
boxShadow: [
BoxShadow(color: Colors.black26, blurRadius: 5, offset: Offset(0, 3))
]
),
child: Icon(icon, color: Colors.white, size: 30),
),
);
}
}

// ---------------- Robot Map Screen ----------------
class RobotMapScreen extends StatelessWidget {
RobotMapScreen({Key? key}) : super(key: key);

final DatabaseReference _locationRef =
FirebaseDatabase.instance.ref('robot/location');

@override
Widget build(BuildContext context) {
return Scaffold(
body: Container(
decoration: const BoxDecoration(
gradient: LinearGradient(
colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
begin: Alignment.topLeft,
end: Alignment.bottomRight,
),
),
child: SafeArea(
child: StreamBuilder(
stream: _locationRef.onValue,
builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
if (snapshot.connectionState == ConnectionState.waiting) {
return const Center(child: CircularProgressIndicator());
}
if (snapshot.hasError) {
return const Center(child: Text("Error loading location data"));
}

double lat = 0.0;
double lon = 0.0;

if (snapshot.hasData &&
snapshot.data!.snapshot.value != null &&
snapshot.data!.snapshot.value is Map) {
final Map<dynamic, dynamic> locationData =
snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
lat = double.tryParse(locationData['latitude'].toString()) ?? 0.0;
lon = double.tryParse(locationData['longitude'].toString()) ?? 0.0;
}

return Center(
child: Padding(
padding: const EdgeInsets.all(24.0),
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
const Icon(Icons.location_on,
size: 80, color: Colors.white),
const SizedBox(height: 20),
const Text(
"Robot Live Location",
style: TextStyle(
fontSize: 24,
color: Colors.white,
fontWeight: FontWeight.bold),
),
const SizedBox(height: 16),
Container(
padding: const EdgeInsets.all(20),
decoration: BoxDecoration(
color: Colors.white.withOpacity(0.1),
borderRadius: BorderRadius.circular(16),
boxShadow: [
BoxShadow(
color: Colors.greenAccent.withOpacity(0.3),
blurRadius: 12,
),
],
),
child: Column(
children: [
Text(
"Latitude: ${lat.toStringAsFixed(6)}",
style: const TextStyle(
color: Colors.white70, fontSize: 16),
),
const SizedBox(height: 6),
Text(
"Longitude: ${lon.toStringAsFixed(6)}",
style: const TextStyle(
color: Colors.white70, fontSize: 16),
),
],
),
),
const SizedBox(height: 30),
ElevatedButton.icon(
onPressed: () {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content:
Text("🗺️ Map integration coming soon"),
),
);
},
icon: const Icon(Icons.map),
label: const Text("View on Map"),
style: ElevatedButton.styleFrom(
backgroundColor: Colors.green.shade700,
padding: const EdgeInsets.symmetric(
horizontal: 40, vertical: 14),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(16)),
),
),
],
),
),
);
},
),
),
),
);
}
}


this is live video screen.dart file 

// lib/live_video_screen.dart

import 'package:flutter/material.dart';
// NOTE: Make sure you have added flutter_vlc_player to your pubspec.yaml
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

class LiveVideoScreen extends StatefulWidget {
final String url;
const LiveVideoScreen({Key? key, required this.url}) : super(key: key);

@override
_LiveVideoScreenState createState() => _LiveVideoScreenState();
}

class _LiveVideoScreenState extends State<LiveVideoScreen> {
late VlcPlayerController _vlcController;

@override
void initState() {
super.initState();
// Initialize the VlcPlayerController with the streaming URL
_vlcController = VlcPlayerController.network(
widget.url,
autoPlay: true,
options: VlcPlayerOptions(),
);
}

@override
void dispose() {
_vlcController.dispose();
super.dispose();
}

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
title: const Text('Live Robot Feed'),
backgroundColor: Colors.black,
),
body: Center(
// FIX: Added the required 'aspectRatio' parameter (16/9 is standard)
child: VlcPlayer(
controller: _vlcController,
aspectRatio: 16 / 9,
placeholder: const Center(child: CircularProgressIndicator(color: Colors.green)),
),
),
);
}
}


this is mapScreen.dart


import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class RobotMapScreen extends StatefulWidget {
const RobotMapScreen({Key? key}) : super(key: key);

@override
State<RobotMapScreen> createState() => _RobotMapScreenState();
}

class _RobotMapScreenState extends State<RobotMapScreen> {
final DatabaseReference _locationRef =
FirebaseDatabase.instance.ref('robot/location');

late GoogleMapController _mapController;
LatLng? _robotPosition;
bool _isMapVisible = false;

@override
void initState() {
super.initState();
_listenToLiveLocation();
}

void _listenToLiveLocation() {
_locationRef.onValue.listen((event) {
final data = event.snapshot.value;
if (data is Map) {
final lat = double.tryParse(data['latitude'].toString()) ?? 0.0;
final lon = double.tryParse(data['longitude'].toString()) ?? 0.0;
setState(() {
_robotPosition = LatLng(lat, lon);
});
if (_isMapVisible && _mapController != null) {
_mapController.animateCamera(
CameraUpdate.newLatLng(_robotPosition!),
);
}
}
});
}

void _onMapCreated(GoogleMapController controller) {
_mapController = controller;
}

@override
Widget build(BuildContext context) {
return Scaffold(
body: AnimatedContainer(
duration: const Duration(milliseconds: 500),
decoration: const BoxDecoration(
gradient: LinearGradient(
colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
begin: Alignment.topLeft,
end: Alignment.bottomRight,
),
),
child: SafeArea(
child: _isMapVisible
? _buildMapView()
: _buildInfoCard(context),
),
),
);
}

Widget _buildInfoCard(BuildContext context) {
return Center(
child: Padding(
padding: const EdgeInsets.all(24.0),
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
const Icon(Icons.location_on, size: 80, color: Colors.white),
const SizedBox(height: 20),
const Text(
"Robot Live Location",
style: TextStyle(
fontSize: 24,
color: Colors.white,
fontWeight: FontWeight.bold),
),
const SizedBox(height: 16),
if (_robotPosition != null)
Container(
padding: const EdgeInsets.all(20),
decoration: BoxDecoration(
color: Colors.white.withOpacity(0.1),
borderRadius: BorderRadius.circular(16),
),
child: Column(
children: [
Text(
"Latitude: ${_robotPosition!.latitude.toStringAsFixed(6)}",
style: const TextStyle(color: Colors.white70, fontSize: 16),
),
Text(
"Longitude: ${_robotPosition!.longitude.toStringAsFixed(6)}",
style: const TextStyle(color: Colors.white70, fontSize: 16),
),
],
),
),
const SizedBox(height: 30),
ElevatedButton.icon(
onPressed: _robotPosition == null
? null
: () {
setState(() {
_isMapVisible = true;
});
},
icon: const Icon(Icons.map),
label: const Text("View on Map"),
style: ElevatedButton.styleFrom(
backgroundColor: Colors.green.shade700,
padding:
const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(16)),
),
),
],
),
),
);
}

Widget _buildMapView() {
return Stack(
children: [
GoogleMap(
onMapCreated: _onMapCreated,
initialCameraPosition: CameraPosition(
target: _robotPosition ?? const LatLng(0.0, 0.0),
zoom: 16,
),
markers: _robotPosition != null
? {
Marker(
markerId: const MarkerId("robot"),
position: _robotPosition!,
infoWindow: const InfoWindow(title: "🤖 ASTRA Robot"),
icon: BitmapDescriptor.defaultMarkerWithHue(
BitmapDescriptor.hueGreen),
),
}
: {},
),
Positioned(
top: 16,
left: 16,
child: FloatingActionButton(
backgroundColor: Colors.green.shade700,
child: const Icon(Icons.arrow_back),
onPressed: () {
setState(() {
_isMapVisible = false;
});
},
),
),
],
);
}
}



this is robot map screen.dart


import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class RobotMapScreen extends StatelessWidget {
RobotMapScreen({Key? key}) : super(key: key);

final DatabaseReference _locationRef =
FirebaseDatabase.instance.ref('robot/location');

@override
Widget build(BuildContext context) {
return Scaffold(
body: Container(
decoration: const BoxDecoration(
gradient: LinearGradient(
colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
begin: Alignment.topLeft,
end: Alignment.bottomRight,
),
),
child: SafeArea(
child: StreamBuilder(
stream: _locationRef.onValue,
builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
if (snapshot.connectionState == ConnectionState.waiting) {
return const Center(child: CircularProgressIndicator());
}
if (snapshot.hasError) {
return const Center(child: Text("Error loading location data"));
}
if (!snapshot.hasData ||
snapshot.data!.snapshot.value == null ||
snapshot.data!.snapshot.value is! Map) {
return const Center(
child: Text("No live location data from robot."));
}

final Map<dynamic, dynamic> locationData =
snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
final double lat =
double.tryParse(locationData['latitude'].toString()) ?? 0.0;
final double lon =
double.tryParse(locationData['longitude'].toString()) ?? 0.0;

return Center(
child: Padding(
padding: const EdgeInsets.all(24.0),
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
const Icon(Icons.location_on,
size: 80, color: Colors.white),
const SizedBox(height: 20),
const Text(
"Robot Live Location",
style: TextStyle(
fontSize: 24,
color: Colors.white,
fontWeight: FontWeight.bold),
),
const SizedBox(height: 16),
Container(
padding: const EdgeInsets.all(20),
decoration: BoxDecoration(
color: Colors.white.withOpacity(0.1),
borderRadius: BorderRadius.circular(16),
boxShadow: [
BoxShadow(
color: Colors.greenAccent.withOpacity(0.3),
blurRadius: 12,
),
],
),
child: Column(
children: [
Text(
"Latitude: ${lat.toStringAsFixed(6)}",
style: const TextStyle(
color: Colors.white70, fontSize: 16),
),
const SizedBox(height: 6),
Text(
"Longitude: ${lon.toStringAsFixed(6)}",
style: const TextStyle(
color: Colors.white70, fontSize: 16),
),
],
),
),
const SizedBox(height: 30),
ElevatedButton.icon(
onPressed: () {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text("🗺️ Map integration coming soon"),
),
);
},
icon: const Icon(Icons.map),
label: const Text("View on Map"),
style: ElevatedButton.styleFrom(
backgroundColor: Colors.green.shade700,
padding: const EdgeInsets.symmetric(
horizontal: 40, vertical: 14),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(16)),
),
),
],
),
),
);
},
),
),
),
);
}
}



this is weather screen.dart

// --- 🌦️ AUTO LOCATION + LIVE WEATHER (OpenWeather API Integrated) ---
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class WeatherScreen extends StatefulWidget {
const WeatherScreen({Key? key}) : super(key: key);

@override
State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen>
with SingleTickerProviderStateMixin {
late AnimationController _controller;
bool _isLoading = true;
Map<String, dynamic>? _weatherData;
double? _latitude;
double? _longitude;

final String apiKey = "2e8389bccfbc3c639438d13b31a5157d";

@override
void initState() {
super.initState();
_controller =
AnimationController(vsync: this, duration: const Duration(seconds: 2))
..forward();
_determinePosition();
}

// --- 📍 Get Current Location ---
Future<void> _determinePosition() async {
bool serviceEnabled;
LocationPermission permission;

serviceEnabled = await Geolocator.isLocationServiceEnabled();
if (!serviceEnabled) {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text('❌ Location services are disabled.'),
backgroundColor: Colors.red,
),
);
return;
}

permission = await Geolocator.checkPermission();
if (permission == LocationPermission.denied) {
permission = await Geolocator.requestPermission();
if (permission == LocationPermission.denied) {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text('⚠️ Location permission denied.'),
backgroundColor: Colors.orange,
),
);
return;
}
}

if (permission == LocationPermission.deniedForever) {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text('⚠️ Location permissions are permanently denied.'),
backgroundColor: Colors.orange,
),
);
return;
}

final position = await Geolocator.getCurrentPosition(
desiredAccuracy: LocationAccuracy.high);

setState(() {
_latitude = position.latitude;
_longitude = position.longitude;
});

_fetchWeather();
}

// --- ☁️ Fetch Weather Data ---
Future<void> _fetchWeather() async {
if (_latitude == null || _longitude == null) return;

setState(() => _isLoading = true);

try {
final url =
"https://api.openweathermap.org/data/2.5/weather?lat=$_latitude&lon=$_longitude&appid=$apiKey&units=metric";
final response = await http.get(Uri.parse(url));

if (response.statusCode == 200) {
final data = json.decode(response.body);
setState(() {
_weatherData = data;
_isLoading = false;
});
} else {
throw Exception("Failed to fetch weather");
}
} catch (e) {
setState(() {
_isLoading = false;
_weatherData = null;
});
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text("❌ Failed to load weather data: $e"),
backgroundColor: Colors.red,
),
);
}
}

@override
void dispose() {
_controller.dispose();
super.dispose();
}

// --- 🌤️ Weather Card ---
Widget _buildWeatherCard() {
if (_isLoading) {
return const Center(child: CircularProgressIndicator(color: Colors.white));
}

if (_weatherData == null) {
return const Center(
child: Text(
"⚠️ Unable to fetch weather data.",
style: TextStyle(color: Colors.white70, fontSize: 16),
),
);
}

final main = _weatherData!['weather'][0]['main'];
final description = _weatherData!['weather'][0]['description'];
final icon = _weatherData!['weather'][0]['icon'];
final temp = _weatherData!['main']['temp'].toStringAsFixed(1);
final humidity = _weatherData!['main']['humidity'];
final windSpeed = _weatherData!['wind']['speed'];

return Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
Image.network(
"https://openweathermap.org/img/wn/$icon@2x.png",
width: 100,
height: 100,
),
Text(
"$main",
style: const TextStyle(
color: Colors.white,
fontSize: 26,
fontWeight: FontWeight.bold,
),
),
const SizedBox(height: 4),
Text(
description.toString().toUpperCase(),
style: const TextStyle(color: Colors.white70, fontSize: 16),
),
const SizedBox(height: 16),
Text(
"$temp°C",
style: const TextStyle(
color: Colors.white, fontSize: 44, fontWeight: FontWeight.bold),
),
const SizedBox(height: 16),
Row(
mainAxisAlignment: MainAxisAlignment.spaceEvenly,
children: [
_infoTile(Icons.water_drop, "Humidity", "$humidity%"),
_infoTile(Icons.air, "Wind", "${windSpeed} m/s"),
],
),
const SizedBox(height: 20),
if (_latitude != null && _longitude != null)
Text(
"📍 Lat: ${_latitude!.toStringAsFixed(3)}, Lon: ${_longitude!.toStringAsFixed(3)}",
style: const TextStyle(color: Colors.white70, fontSize: 14),
),
],
);
}

Widget _infoTile(IconData icon, String label, String value) {
return Column(
children: [
Icon(icon, color: Colors.white, size: 26),
const SizedBox(height: 6),
Text(label, style: const TextStyle(color: Colors.white70)),
Text(value,
style: const TextStyle(
color: Colors.white, fontWeight: FontWeight.bold)),
],
);
}

@override
Widget build(BuildContext context) {
return Scaffold(
body: Container(
decoration: const BoxDecoration(
gradient: LinearGradient(
colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
begin: Alignment.topLeft,
end: Alignment.bottomRight,
),
),
child: SafeArea(
child: FadeTransition(
opacity: _controller,
child: Column(
children: [
const Padding(
padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
child: Row(
mainAxisAlignment: MainAxisAlignment.center,
children: [
Icon(Icons.cloud, color: Colors.white, size: 28),
SizedBox(width: 8),
Text(
"Live Weather Info",
style: TextStyle(
color: Colors.white,
fontSize: 22,
fontWeight: FontWeight.bold,
letterSpacing: 0.6,
),
),
],
),
),
Lottie.asset(
'assets/animations/weather.json',
height: 140,
repeat: true,
),
const SizedBox(height: 8),
Expanded(
child: Center(
child: Container(
margin: const EdgeInsets.symmetric(horizontal: 24),
padding: const EdgeInsets.all(20),
decoration: BoxDecoration(
color: Colors.white.withOpacity(0.1),
borderRadius: BorderRadius.circular(20),
boxShadow: [
BoxShadow(
color: Colors.greenAccent.withOpacity(0.3),
blurRadius: 16,
spreadRadius: 2,
),
],
),
child: _buildWeatherCard(),
),
),
),
Padding(
padding: const EdgeInsets.only(bottom: 30, top: 20),
child: ElevatedButton.icon(
onPressed: () {
_latitude == null
? _determinePosition()
: _fetchWeather();
},
icon: const Icon(Icons.refresh, color: Colors.white),
label: const Text(
"Refresh Weather",
style: TextStyle(fontSize: 16, color: Colors.white),
),
style: ElevatedButton.styleFrom(
backgroundColor: Colors.green.shade700,
padding: const EdgeInsets.symmetric(
horizontal: 36, vertical: 14),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(16),
),
elevation: 6,
),
),
),
],
),
),
),
),
);
}
}


this is firebase.dart file

// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
/// options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
static FirebaseOptions get currentPlatform {
if (kIsWeb) {
return web;
}
switch (defaultTargetPlatform) {
case TargetPlatform.android:
return android;
case TargetPlatform.iOS:
return ios;
case TargetPlatform.macOS:
return macos;
case TargetPlatform.windows:
return windows;
case TargetPlatform.linux:
throw UnsupportedError(
'DefaultFirebaseOptions have not been configured for linux - '
'you can reconfigure this by running the FlutterFire CLI again.',
);
default:
throw UnsupportedError(
'DefaultFirebaseOptions are not supported for this platform.',
);
}
}

static const FirebaseOptions web = FirebaseOptions(
apiKey: 'AIzaSyDpEx4_SpiiYLtFd_0FFVBVim0qxgRcLsw',
appId: '1:955512461911:web:7fd6b5044413b1d811e112',
messagingSenderId: '955512461911',
projectId: 'astra-farm-robot',
authDomain: 'astra-farm-robot.firebaseapp.com',
databaseURL: 'https://astra-farm-robot-default-rtdb.asia-southeast1.firebasedatabase.app',
storageBucket: 'astra-farm-robot.firebasestorage.app',
measurementId: 'G-7822DKYGQ6',
);

static const FirebaseOptions android = FirebaseOptions(
apiKey: 'AIzaSyB0ZfZtDxZ1n4-EAsmMwhNigwymVwWnnJg',
appId: '1:955512461911:android:9c0534679f5d217b11e112',
messagingSenderId: '955512461911',
projectId: 'astra-farm-robot',
databaseURL: 'https://astra-farm-robot-default-rtdb.asia-southeast1.firebasedatabase.app',
storageBucket: 'astra-farm-robot.firebasestorage.app',
);

static const FirebaseOptions ios = FirebaseOptions(
apiKey: 'AIzaSyCYiy3xfpgAfX_giPIGoop469zEFnq4o7M',
appId: '1:955512461911:ios:e8a73d5ab418986611e112',
messagingSenderId: '955512461911',
projectId: 'astra-farm-robot',
databaseURL: 'https://astra-farm-robot-default-rtdb.asia-southeast1.firebasedatabase.app',
storageBucket: 'astra-farm-robot.firebasestorage.app',
iosBundleId: 'com.example.brahmastra',
);

static const FirebaseOptions macos = FirebaseOptions(
apiKey: 'AIzaSyCYiy3xfpgAfX_giPIGoop469zEFnq4o7M',
appId: '1:955512461911:ios:e8a73d5ab418986611e112',
messagingSenderId: '955512461911',
projectId: 'astra-farm-robot',
databaseURL: 'https://astra-farm-robot-default-rtdb.asia-southeast1.firebasedatabase.app',
storageBucket: 'astra-farm-robot.firebasestorage.app',
iosBundleId: 'com.example.brahmastra',
);

static const FirebaseOptions windows = FirebaseOptions(
apiKey: 'AIzaSyDpEx4_SpiiYLtFd_0FFVBVim0qxgRcLsw',
appId: '1:955512461911:web:ae79541caa85b8fe11e112',
messagingSenderId: '955512461911',
projectId: 'astra-farm-robot',
authDomain: 'astra-farm-robot.firebaseapp.com',
databaseURL: 'https://astra-farm-robot-default-rtdb.asia-southeast1.firebasedatabase.app',
storageBucket: 'astra-farm-robot.firebasestorage.app',
measurementId: 'G-04EBY0C855',
);

}
