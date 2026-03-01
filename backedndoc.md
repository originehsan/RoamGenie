# RoamGenie Backend — API Documentation

This document describes the HTTP API implemented in the repository `src/` so you (or an automation like Antigravity) can generate client code and Flutter integrations.

Base URL: http://{host}:{PORT}/api

Summary
- Express-based JSON API with these route groups:
  - `/api/travel` — travel planning (AI + flights)
  - `/api/passport` — passport OCR and visa lookups
  - `/api/ivr` — IVR / call initiation (forwards to n8n)
  - `/api/contact` — contact form forwarding to Vendasta CRM
  - `/api/emergency` — WhatsApp emergency / fallback notifications via Twilio

Security & behavior
- No built-in authentication — endpoints are public.
- CORS: allows no-origin (mobile), `null`, and configured origins via `ALLOWED_ORIGINS` env var.
- Rate limiting: 100 requests per 15 minutes per IP.
- Request body size limit: 10 MB for JSON and form data.

Environment variables
- `PORT` — server port (default 3000)
- `NODE_ENV` — development | production
- `LOG_LEVEL` — winston log level (error|warn|info|debug)
- `GOOGLE_API_KEY` — Google Generative AI (Gemini) API key
- `SERPAPI_KEY` — SerpAPI key for Google Flights engine
- `TWILIO_ACCOUNT_SID`, `TWILIO_AUTH_TOKEN` — Twilio credentials
- `TWILIO_PHONE_NUMBER` — Twilio number for voice calls
- `TWILIO_WHATSAPP` — Twilio WhatsApp from (defaults to sandbox)
- `VENDASTA_CRM_URL` — webhook URL for contact form forwarding
- `N8N_WEBHOOK_URL` — webhook URL used by `/api/ivr/call`
- `PASSPORT_DATASET_URL` — optional CSV URL for passport/visa dataset
- `ALLOWED_ORIGINS` — optional comma-separated origins for CORS

Routes

1) Travel

- POST /api/travel/plan
  - Body (JSON):
    {
      "source": "BOM",
      "destination": "BKK",
      "departureDate": "2026-03-10",
      "returnDate": "2026-03-20",
      "budget": "Standard",            // optional
      "flightClass": "Economy",        // optional
      "preferences": "Sightseeing"     // optional
    }
  - Response (200):
    {
      "success": true,
      "message": "Travel plan generated successfully",
      "data": {
        "flights": [ { "airline", "price", "departureTime", "arrivalTime", "totalDuration", "bookingLink", "airlineLogo" } ],
        "hotels": [ {name, location, price_per_night, rating, review_count, description, amenities[]} ],
        "restaurants": [ {name, cuisine, price_range, rating, description} ],
        "itinerary": "## Day 1 ...",
        "visaStatus": "...",
        "destinationCountry": "Thailand"
      }
    }
  - Errors: 400 for missing required fields; 500 for internal failures.

- GET /api/travel/health
  - Response: { success: true, message, data: { service: 'travel', status: 'online' } }

- GET /api/travel/iata-map
  - Response: map of IATA codes to countries (used for visa checks)

2) Passport

- POST /api/passport/scan
  - Content-Type: multipart/form-data
  - Field name: `image` (file). Accepted mimetypes: image/jpeg, image/png, image/webp
  - Response (200):
    {
      "country": "India",
      "confidence": 0.8,
      "visaFreeCountries": ["Nepal", "Maldives", ...],
      "regionBreakdown": { "Asia": 10, ... },
      "flags": { "Nepal": "🇳🇵", ... }
    }
  - Errors: 400 if no file; 422 if OCR failed; 500 on server error.

- POST /api/passport/visa-free
  - Body: { "country": "India" }
  - Response: same structure as scan (visa-free lookup + availablePassports)

- GET /api/passport/countries
  - Response: { "countries": [ ... ] }

3) IVR

- POST /api/ivr/call
  - Body: { "toNumber": "+919876543210" }
  - Behavior: forwards to `N8N_WEBHOOK_URL` with payload { to_number } and returns the n8n result (expects `{ success, sid }`).
  - Errors: 400 for invalid number; 500 for n8n errors.

4) Contact

- POST /api/contact/submit
  - Body: { firstName, lastName, email, phone }
  - Behavior: validates input and forwards to `VENDASTA_CRM_URL`.
  - Response: { success: true, message } on 200, or appropriate error status.

5) Emergency

- POST /api/emergency/flight-cancellation
  - Body: { "whatsappNumber": "+919876543210" }
  - Behavior: validates Indian whatsapp number (+91) and sends WhatsApp via Twilio
  - Response: { success: true, sid, status, message }

- POST /api/emergency/offline-fallback
  - Body: { "whatsappNumber": "+919876543210" }
  - Same behavior as above with different message body.

Notes on validation and formats
- Indian phone numbers MUST start with `+91` and have length 13 (e.g. +919876543210).
- Many endpoints return a `{ success: boolean, message: string, data: ... }` envelope for easy client parsing.

Examples — curl

- Travel plan
```bash
curl -X POST http://localhost:3000/api/travel/plan \
  -H 'Content-Type: application/json' \
  -d '{"source":"BOM","destination":"BKK","departureDate":"2026-03-10","returnDate":"2026-03-20"}'
```

- Passport scan (multipart)
```bash
curl -X POST http://localhost:3000/api/passport/scan \
  -F "image=@/path/to/passport.jpg"
```

Flutter integration notes (Dart)

- Simple JSON POST using `http` package:

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

final base = 'http://your.backend.host:3000/api';

Future<void> planTrip() async {
  final resp = await http.post(Uri.parse('$base/travel/plan'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'source': 'BOM',
      'destination': 'BKK',
      'departureDate': '2026-03-10',
      'returnDate': '2026-03-20',
    }),
  );
  final json = jsonDecode(resp.body);
  // handle json['success'] and json['data']
}
```

- Multipart file upload (passport scan) using `http` package:

```dart
import 'package:http/http.dart' as http;

Future<void> uploadPassport(File file) async {
  final uri = Uri.parse('http://your.backend.host:3000/api/passport/scan');
  final req = http.MultipartRequest('POST', uri);
  req.files.add(await http.MultipartFile.fromPath('image', file.path));
  final res = await req.send();
  final body = await res.stream.bytesToString();
  final json = jsonDecode(body);
  // parse json
}
```

Tips for Antigravity / codegen
- Provide the tool with the endpoint list, request/response examples above, and note the lack of authentication.
- Indicate that the Flutter client should handle:
  - Rate limit errors (429) and retry/backoff
  - File uploads for passport scanning (multipart)
  - Phone-number formatting for Indian numbers

Server run & development
- To run locally:
  - Install dependencies: `npm install` (if PowerShell policy blocks scripts, use `npm.cmd install` or `cmd /c "npm install"`)
  - Start: `npm start` or `node ./src/server.js`

Logging & monitoring
- Winston logs to console and `logs/combined.log`; `logs/error.log` contains error-level logs.

Open questions (for implementers)
- Add authentication (Bearer token / API key) if public access is not intended.
- Add request/response schemas (OpenAPI) if Antigravity requires strict typing.

Contact
- Repo path: src/ (server.js, routes/*, services/*)
