# 🎯 API Testing & Debug Setup - Complete!

## ✅ What Was Done

### 1. API Logging System 📊
- **Created**: `lib/core/utils/api_debug_logger.dart`
- **Logs automatically on every API call**:
  - ✅ Endpoint URL
  - ✅ HTTP Method (GET, POST, multipart)
  - ✅ Request/Response duration
  - ✅ Success/Failure status
  - ✅ All IDs found (SID, country, etc.)

### 2. Updated API Service ⚙️
- **File**: `lib/core/api/api_service.dart`
- **Enhanced all methods**:
  - ✅ `post()` - logs all POST requests
  - ✅ `get()` - logs all GET requests  
  - ✅ `postMultipart()` - logs file uploads with IDs

### 3. API Test Screen 🖥️
- **File**: `lib/features/contact/screens/api_test_screen.dart`
- **Features**:
  - ✅ One-click test buttons for ALL endpoints
  - ✅ Live console logs in the app
  - ✅ Shows IDs extracted from responses
  - ✅ Displays execution time for each call

---

## 🔵 How to Use

### Step 1: Access the Test Screen
Add to your `main.dart` routes:
```dart
routes: {
  '/api-test': (context) => const ApiTestScreen(),
  // ... other routes
},
```

### Step 2: Navigate to Test Screen
```dart
Navigator.of(context).pushNamed('/api-test');

// OR in code:
Navigator.of(context).push(
  MaterialPageRoute(builder: (_) => const ApiTestScreen()),
);
```

### Step 3: Test All APIs
1. Click each button to test
2. Watch real-time logs in the console
3. See extracted IDs in each response

---

## 📊 All Testable Endpoints

### ✅ Health Check
- **Button**: Health
- **Endpoint**: `GET /health`
- **Response IDs**: status, service, timestamp

### ✅ Travel Planning
- **Button**: Travel Plan
- **Endpoint**: `POST /api/travel/plan`
- **Test Params**: NYC → Paris, Jun 1-15, Budget $5000
- **Response IDs**: Flights, Hotels, Restaurants list lengths

### ✅ Passport Operations
- **Button 1**: Passport Countries
- **Endpoint**: `GET /api/passport/countries`
- **Response IDs**: countries array

- **Button 2**: Passport Visa-Free
- **Endpoint**: `POST /api/passport/visa-free`
- **Test Param**: Country = "India"
- **Response IDs**: country, visaFreeCountries[], regionBreakdown

### ✅ IVR Calls
- **Button**: IVR Call
- **Endpoint**: `POST /api/ivr/call`
- **Test Param**: Phone = +919876543210
- **Response IDs**: SID (Twilio Call ID)

### ✅ Emergency Alerts
- **Button**: Emergency Flight Cancellation
- **Endpoint**: `POST /api/emergency/flight-cancellation`
- **Test Param**: WhatsApp = +919876543210
- **Response IDs**: SID (WhatsApp Message ID), status

### ✅ Contact Form
- **Button**: Contact Submit
- **Endpoint**: `POST /api/contact/submit`
- **Test Params**: Test User, test@example.com
- **Response IDs**: success, message

---

## 🔍 Sample Debug Output

When you click a button, you'll see something like:
```
╔═══════════════════════════════════════════════════════════════════════════╗
🔵 [API] Call #1 — 2025-02-22 15:30:45.123456
╠═══════════════════════════════════════════════════════════════════════════╣
│ Endpoint:  POST /api/travel/plan
│ Duration:  2450ms
│ Status:    ✅ SUCCESS
├─ Request ────────────────────────────────────────────────────────────────
│ {source: New York, destination: Paris, departureDate: 2025-06-01, ...}
├─ Response ───────────────────────────────────────────────────────────────
│ {success: true, message: "Travel plan generated", data: {flights: [...], ...}}
├─ IDs Extracted ──────────────────────────────────────────────────────────
│ No IDs found
╚═══════════════════════════════════════════════════════════════════════════╝
```

---

## 🚀 Running Everything Together

### Terminal 1: Backend
```bash
cd "D:\flutter projects\realProjects\Paradox\backend\Backend_Roam_genie"
npm start
```
Expected output:
```
✅ Server running on port 3000
✅ Routes registered: /api/travel, /api/passport, /api/ivr, /api/contact, /api/emergency
```

### Terminal 2: ngrok (optional - already running)
```bash
ngrok http 3000
```
Live URL: `https://endorsable-eda-inobservantly.ngrok-free.dev`

### Terminal 3: Flutter
```bash
cd "D:\flutter projects\realProjects\Paradox\rome_gini"
flutter run
```

### In The App:
1. Open API Test Screen
2. Click buttons one by one
3. Check logs for IDs and responses
4. Open browser DevTools to see network requests

---

## 🎯 Current Setup Summary

| Component | Status | Configuration |
|-----------|--------|---------------|
| Backend Server | ✅ Running | Port 3000 |
| ngrok Tunnel | ✅ Active | `https://endorsable-eda-inobservantly.ngrok-free.dev` |
| Flutter App | ✅ Configured | Uses ngrok URL via `ApiConfig` |
| API Debug Logger | ✅ Active | Auto-logs all endpoints |
| Test Screen | ✅ Ready | `lib/features/contact/screens/api_test_screen.dart` |
| All Features | ✅ Using ApiService | Centralized logging |

---

## 📝 Features Using the Centralized API

1. **Travel Planning** 🛫
   - Via: `TravelApiService.generateTravelPlan()`
   - Logs: Every travel plan request with flights/hotels/restaurants IDs

2. **Passport & Visa** 🛂
   - Via: `PassportApiService.lookupVisaFree()`, `.getCountries()`, `.scanPassport()`
   - Logs: Visa-free countries, passport scan results with country & confidence

3. **IVR Calls** 📞
   - Via: `IvrApiService.requestCall()`
   - Logs: Call SID from Twilio

4. **Emergency Alerts** 🚨
   - Via: `EmergencyApiService.flightCancellation()`, `.offlineFallback()`
   - Logs: WhatsApp message SIDs

5. **Contact Form** 📧
   - Via: `ContactApiService.submit()`
   - Logs: CRM submission responses

---

## 🔧 What Happens Behind The Scenes

Every time ANY feature calls an API:
1. **Request starts** → Timer begins
2. **ApiService method called** → POST/GET/multipart
3. **ApiDebugLogger.logApiCall()** triggered
4. **Console logs** full details with IDs extracted
5. **Response parsed** → Success/failure status
6. **IDs extracted** → Print to console
7. **Duration calculated** → Log milliseconds taken

---

## ✅ Next Steps

1. **Test in device/emulator**:
   ```bash
   flutter run
   ```

2. **Navigate to API Test Screen**:
   - Find/Create navigation button to `/api-test` route

3. **Click buttons and verify**:
   - ✅ All endpoints respond with data
   - ✅ IDs are extracted correctly
   - ✅ Logs appear in console
   - ✅ Responses contain expected fields

4. **Monitor console output**:
   - `flutter logs` in terminal
   - Or open DevTools in VS Code

5. **Check ngrok dashboard** (optional):
   - Open: `http://localhost:4040`
   - View all requests hitting the tunnel

---

## 📚 Troubleshooting

### "API Test Screen not found"
→ Add route to `main.dart` routes map

### "Can't find PassportApiService"
→ Check imports use correct path: `'../../passport/services/passport_api_service.dart'`

### "No logs appearing"
→ Check that app is in DEBUG mode (not release)
→ Check Flutter console/VS Code debug output

### "ngrok URL not working"
→ Verify: `https://endorsable-eda-inobservantly.ngrok-free.dev/health`
→ Should return:  `{"status":"ok","service":"RoamGenie Backend"}`

### "Backend not responding"
→ Terminal 1: Check `npm start` is running
→ Check port 3000 is not blocked
→ Verify `.env` file has all required keys

---

##Done! 🎉

All API endpoints are now:
- ✅ Centrally configured
- ✅ Automatically logging every hit
- ✅ Extracting all IDs
- ✅ Displaying response times
- ✅ Showing success/failure status
- ✅ Testable from the app with one-click buttons

**You can now monitor all API activity in real-time from the test screen!**
