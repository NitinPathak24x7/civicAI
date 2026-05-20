🏛️ CivicAI: Smart Urban Governance Platform
CivicAI is a centralized, AI-powered bridge between the citizens of Delhi and the Municipal Corporation of Delhi (MCD). It transforms how civic issues (potholes, sanitation, water logging) are reported, tracked, and resolved by introducing brutal transparency, predictive analytics, and gamified citizen engagement.

🛑 The Problem
Currently, citizens navigate a fragmented system to report local issues—using Twitter, phone calls, or outdated paper applications. There is no central, intelligent system for the government to prioritize, track, and predict these issues. This communication gap leads to delayed resolutions, inefficient resource allocation, and frustrated citizens.

💡 Our Solution
CivicAI replaces friction with intelligence.

For Citizens: A 10-second reporting tool, a live community feed, and gamified civic scores.

For Authorities: A unified command center with a God's-eye map view, contractor tracking, and AI-driven predictive insights to deploy resources before a crisis escalates.

✨ Key Features
👤 Citizen App
Smart Issue Reporting: Snap a photo, auto-fetch exact GPS coordinates, and categorize the issue in seconds.

Live Community Feed: Upvote, comment, and view "Critical Alerts" in your local neighborhood.

My Region Dashboard: Live environmental data pulling from Google Air Quality (AQI), Pollen APIs, and Open-Meteo weather data.

Gamification & Badges: Earn "Civic Scores" and badges for active community participation.

Native Integrations: One-tap MCD helpline dialer and an "Auto-Write Email" generator that forces the native mail app open with pre-filled GPS data.

🏢 Admin Command Center
Live Analytics Hub: Real-time counters for Pending, Active, and Resolved complaints.

Predictive AI Insights: Identifies complaint density spikes to predict hotspots and suggest resource reallocation.

Contractor Management: Assign tasks directly to contractors, track their resolution times, and view public ratings.

Zone Distribution Map: Visual heat-map of Delhi/Ghaziabad highlighting areas with poor "Civic Health" scores.

Duplicate Control & Severity Moderation: Automatically groups identical reports into manageable master tickets.

🛠 Tech Stack
Frontend: Flutter & Dart

Backend: Firebase (Firestore NoSQL, Firebase Auth, Cloud Storage)

APIs & Services:

Google Maps Platform (Maps SDK)

Google Air Quality API & Pollen API

Open-Meteo API (Live Weather)

Groq API (AI Chatbot Integration)

Native Packages: geolocator, image_picker, url_launcher

🚀 Getting Started
Prerequisites
Flutter SDK (Version 3.19.0 or higher)

Android Studio (For emulator and build tools)

A Firebase Project with Firestore and Storage enabled (Rules set to allow read/write for testing).

Installation
1. Clone the repository

Bash
git clone https://github.com/NitinPathak24x7/civicAI.git
cd civicAI

2. Install dependencies

Bash
flutter pub get
3. Setup Firebase
Download your google-services.json from your Firebase Console and place it in the android/app/ directory.

4. Setup Environment Variables
Create a .env.local file in the root directory of your project and add your API keys:

Code snippet
GROQ_API_KEY= YourGroqApiKeyHere
GOOGLE_MAPS_API_KEY= YourGoogleMapsKeyHere

5. Setup Native Android Maps Key
Open android/app/src/main/AndroidManifest.xml and replace the placeholder with your actual Google Maps API Key:

6. Run the App

Bash
flutter clean
flutter run
