import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../models/passport_result.dart';
import '../repositories/passport_repository.dart';

export '../models/passport_result.dart'; // re-export so views don't need a separate import



class PassportViewModel extends ChangeNotifier {
  final _repo = const PassportRepository();

  // ── State ────────────────────────────────────────────────────────────────────
  PassportState _state = PassportState.idle;
  String _error = '';
  PassportResult? _result;
  List<String> _availablePassports = [];

  // ── Manual lookup ────────────────────────────────────────────────────────────
  String _selectedCountry = '';

  // ── OCR scan ─────────────────────────────────────────────────────────────────
  File? _pickedImage;
  bool _scanLoading = false;
  String _scanError = '';

  // Getters
  PassportState get state => _state;
  String get error => _error;
  PassportResult? get result => _result;
  List<String> get availablePassports => _availablePassports;
  String get selectedCountry => _selectedCountry;
  bool get loading => _state == PassportState.loading;
  bool get loadingCountries => _state == PassportState.loadingCountries;

  File? get pickedImage => _pickedImage;
  bool get scanLoading => _scanLoading;
  String get scanError => _scanError;

  void setSelectedCountry(String c) {
    _selectedCountry = c;
    notifyListeners();
  }

  // ── GET /api/passport/countries ───────────────────────────────────────────────
  // Response (flat): { "countries": [ "India", "USA", ... ] }
  Future<void> loadCountries() async {
    _state = PassportState.loadingCountries;
    notifyListeners();

    final response = await _repo.getCountries();
    if (response.success && response.data != null) {
      final raw = response.data!['countries'];
      _availablePassports =
          raw is List ? raw.map((e) => e.toString()).toList() : [];
    } else {
      // Graceful fallback when network is unavailable
      _availablePassports = [
        'India', 'United States', 'United Kingdom', 'Canada',
        'Australia', 'Germany', 'France', 'Japan', 'Singapore',
        'UAE', 'China', 'Brazil', 'South Korea', 'Netherlands',
        'Italy', 'Spain', 'New Zealand', 'Switzerland', 'Sweden',
      ];
    }
    _state = PassportState.idle;
    notifyListeners();
  }

  // ── POST /api/passport/visa-free ─────────────────────────────────────────────
  // Body: { country }
  // Response (flat): { country, visaFreeCountries[], regionBreakdown{}, flags{},
  //                    availablePassports[] }
  Future<void> lookup() async {
    if (_selectedCountry.isEmpty) return;
    _state = PassportState.loading;
    _error = '';
    _result = null;
    notifyListeners();

    final response =
        await _repo.lookupVisaFree(country: _selectedCountry);

    if (response.success && response.data != null) {
      // response.data IS the full flat json map (our decoder normalises this)
      _result = PassportResult.fromJson(response.data!);
      // Ensure country field is filled even if backend omits it
      if (_result!.country.isEmpty) {
        _result = PassportResult(
          country: _selectedCountry,
          confidence: _result!.confidence,
          visaFreeCountries: _result!.visaFreeCountries,
          regionBreakdown: _result!.regionBreakdown,
          flags: _result!.flags,
          availablePassports: _result!.availablePassports,
        );
      }
      _state = PassportState.success;
    } else {
      _state = PassportState.error;
      _error = response.message.isNotEmpty
          ? response.message
          : 'Could not fetch visa information. Please try again.';
    }
    notifyListeners();
  }

  // ── Image picker ─────────────────────────────────────────────────────────────
  Future<void> pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        imageQuality: 90,
        maxWidth: 1920,
      );
      if (picked != null) {
        _pickedImage = File(picked.path);
        _scanError = '';
        notifyListeners();
      }
    } catch (e) {
      _scanError =
          'Could not access ${source == ImageSource.camera ? "camera" : "gallery"}. Check permissions.';
      notifyListeners();
    }
  }

  // ── POST /api/passport/scan (multipart) ───────────────────────────────────────
  // Field name: "image" (JPG/PNG/WEBP)
  // Response (flat — no 'data' wrapper):
  //   { country, confidence, visaFreeCountries[], regionBreakdown{}, flags{} }
  // Errors: 400 no file; 422 OCR failed; 500 server error
  Future<void> scanPassport() async {
    if (_pickedImage == null) return;
    _scanLoading = true;
    _scanError = '';
    _result = null;
    _state = PassportState.idle;
    notifyListeners();

    try {
      final bytes = await _pickedImage!.readAsBytes();
      final filename = _pickedImage!.path.split(RegExp(r'[/\\]')).last;

      final response = await _repo.scanPassport(
        imageBytes: bytes,
        filename: filename,
      );

      if (response.success && response.data != null) {
        // response.data is the full flat map from the scan response
        _result = PassportResult.fromJson(response.data!);
        _state = PassportState.success;
      } else {
        _scanError = response.message.isNotEmpty
            ? response.message
            : 'Could not scan the passport. Please try a clearer image.';
      }
    } catch (e) {
      _scanError = 'Failed to upload image. Please try again.';
    }

    _scanLoading = false;
    notifyListeners();
  }

  void reset() {
    _state = PassportState.idle;
    _result = null;
    _error = '';
    _selectedCountry = '';
    _pickedImage = null;
    _scanError = '';
    _scanLoading = false;
    notifyListeners();
  }
}
