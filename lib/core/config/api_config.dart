// Flip to false to route every service through the real Spring Boot backend.
const bool kUseMock = false;

// Android AVD maps 10.0.2.2 → host-machine localhost.
// Change port to match your Spring Boot server (default: 8080).
// For iOS Simulator use http://localhost:8080.
// For a physical device on the same LAN use http://<host-LAN-IP>:8080.
const String kBaseUrl = 'http://10.0.2.2:8080';
