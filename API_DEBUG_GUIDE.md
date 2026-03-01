# API Testing & Debug Summary

## Backend Status
- ✅ **Port**: 3000
- ✅ **ngrok URL**: https://endorsable-eda-inobservantly.ngrok-free.dev
- ✅ **Flutter App**: Already configured to use ngrok URL

---

## All API Endpoints

### 1. **Travel Planning** ✈️
**Endpoint**: `POST /api/travel/plan`
```dart
Body: {
  "source": "New York",
  "destination": "Paris",
  "departureDate": "2025-06-01",
  "returnDate": "2025-06-15",
  "budget": "5000",
  "flightClass": "Economy",
  "preferences": "Beach, Museums"
}

Response IDs:
- Flights: Array with airline details
- Hotels: Array with hotel details  
- Restaurants: Array with restaurant details
```

---

### 2. **Passport & Visa** 🛂
#### a) Get Supported Countries
**Endpoint**: `GET /api/passport/countries`
```dart
Response IDs:
- countries: ["India", "USA", "UK", ...]
```

#### b) Visa-Free Lookup
**Endpoint**: `POST /api/passport/visa-free`
```dart
Body: {
  "country": "India"
}

Response IDs:
- country: "India"
- visaFreeCountries: [list of countries]
- regionBreakdown: {continent: count}
- flags: {country: emoji}
- availablePassports: [list]
```

#### c) Passport Scan (OCR)
**Endpoint**: `POST /api/passport/scan`
```dart
Body: multipart/form-data (image file)

Response IDs:
- country: "India"
- confidence: 0.95
- visaFreeCountries: [list]
- regionBreakdown: {continent: count}
```

---

### 3. **IVR / Phone Calls** 📞
**Endpoint**: `POST /api/ivr/call`
```dart
Body: {
  "toNumber": "+919876543210"
}

Response IDs:
- success: true
- sid: "SM1234567890" (Twilio Call SID)
- message: "Call initiated successfully!"
```

---

### 4. **Emergency Alerts** 🚨
#### a) Flight Cancellation Alert
**Endpoint**: `POST /api/emergency/flight-cancellation`
```dart
Body: {
  "whatsappNumber": "+919876543210"
}

Response IDs:
- success: true
- sid: "WM1234567890" (WhatsApp Message SID)
- status: "sent"
- message: "Emergency alert sent!"
```

#### b) Offline Fallback Alert
**Endpoint**: `POST /api/emergency/offline-fallback`
```dart
Body: {
  "whatsappNumber": "+919876543210"
}

Response IDs:
- success: true
- sid: "WM0987654321"
- status: "sent"
```

---

### 5. **Contact Form** 📝
**Endpoint**: `POST /api/contact/submit`
```dart
Body: {
  "firstName": "John",
  "lastName": "Doe",
  "email": "john@example.com",
  "phone": "+919876543210"
}

Response IDs:
- success: true
- message: "Info sent to our CRM successfully!"
```

---

### 6. **Health Check** 🏥
**Endpoint**: `GET /health`
```dart
Response:
{
  "status": "ok",
  "service": "RoamGenie Backend",
  "timestamp": "2025-02-22T..."
}
```

---

## How to Use the API Test Screen

### Access the Test Screen
Add this route to your `main.dart`:
```dart
// In MaterialApp routes:
'/api-test': (context) => const ApiTestScreen(),

// Or navigate:
context.push('/api-test');
```

### Or Add Debug Button to Homepage
```dart
FloatingActionButton(
  onPressed: () => Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => const ApiTestScreen()),
  ),
  child: const Icon(Icons.bug_report),
)
```

---

## Debug Logger Output

Every API call now logs:
```
╔═══════════════════════════════════════════════════════════════════════════╗
🔵 [API] Call #1 — 2025-02-22 10:30:45.123456
╠═══════════════════════════════════════════════════════════════════════════╣
│ Endpoint:  POST /api/travel/plan
│ Duration:  2450ms
│ Status:    ✅ SUCCESS
├─ Request ────────────────────────────────────────────────────────────────
│ {source: New York, destination: Paris, ...}
├─ Response ───────────────────────────────────────────────────────────────
│ {success: true, message: "Travel plan...", data: {...}}
├─ IDs Extracted ──────────────────────────────────────────────────────────
│ No IDs found
╚═══════════════════════════════════════════════════════════════════════════╝
```

---

## What's Configured ✅

1. **ApiConfig** - Centralized ngrok URL
2. **ApiService** - All methods (POST, GET, multipart) with logging  
3. **ApiDebugLogger** - Captures all API hits and extracts IDs
4. **Feature Services** - All features use centralized ApiService:
   - TravelApi (Travel Planning)
   - PassportApiService (Passport & Visa)
   - IvrApiService (IVR Calls)
   - EmergencyApiService (Emergency Alerts)
   - ContactApiService (Contact Form)

5. **ApiTestScreen** - Comprehensive test UI with live logging

---

## Running Tests

1. **Start Backend**:
   ```bash
   cd D:\flutter projects\realProjects\Paradox\backend\Backend_Roam_genie
   npm start
   ```

2. **Verify ngrok is Running**:
   ```bash
   ngrok http 3000
   ```

3. **Run Flutter App**:
   ```bash
   flutter run
   ```

4. **Navigate to API Test Screen** and tap each button to verify all endpoints

5. **Check Console/Logcat** for detailed API call logs with IDs

---

## Expected Results

All endpoints should show:
- ✅ Call succeeded (HTTP 200)
- ✅ Relevant IDs extracted (SID, country, etc.)
- ✅ Duration logged (should be <5s for most calls)
- ✅ Response data with all required fields

If any fails, check:
1. Backend is running (`npm start`)
2. ngrok tunnel is active
3. Network connectivity
4. API request body is valid
