# Epic 3: Currency Converter Feature

## Overview
Build a currency converter with live exchange rates from a free API, supporting 30+ currencies with offline caching.

**Priority:** High - Part of MVP for App Store resubmission
**Estimated Effort:** 3 days
**Dependencies:** Epic 1 (Foundation) must be complete

## User Stories
- As a traveler, I want to convert currencies using live exchange rates
- As a user, I want the app to work offline using cached rates
- As a user, I want to know when rates were last updated
- As a shopper, I want to quickly compare prices in different currencies

## Acceptance Criteria
- [ ] Integration with Frankfurter API (free, no key required)
- [ ] 30+ currencies supported
- [ ] Live rates updated automatically
- [ ] Offline mode with cached rates (24hr cache)
- [ ] Display last update timestamp
- [ ] Bidirectional conversion
- [ ] Clean UI matching app theme
- [ ] Error handling for network issues

---

## Tickets

### Ticket 3.1: Add Dependencies
**Type:** Setup
**Priority:** High
**Effort:** 15 minutes

**Description:**
Add required packages for HTTP requests and local storage.

**Tasks:**
- [ ] Update `pubspec.yaml`:
  ```yaml
  dependencies:
    # Existing dependencies...
    http: ^1.1.0                    # API calls
    shared_preferences: ^2.2.2      # Cache exchange rates
    intl: ^0.19.0                   # Currency formatting
    connectivity_plus: ^5.0.2       # Network detection
  ```
- [ ] Run `flutter pub get`
- [ ] Verify packages installed

**Files:**
- Modify: `pubspec.yaml`

**Acceptance:**
- All packages installed
- No dependency conflicts
- App builds successfully

---

### Ticket 3.2: Create Currency Models
**Type:** New Feature
**Priority:** High
**Effort:** 1 hour

**Description:**
Define currency data models and constants.

**Tasks:**
- [ ] Create `lib/features/currency_converter/models/currency.dart`
- [ ] Define Currency class:
  ```dart
  class Currency {
    final String code;       // USD, EUR, etc.
    final String name;       // US Dollar, Euro, etc.
    final String symbol;     // $, €, etc.
    final String? flag;      // Emoji flag (optional)

    const Currency({
      required this.code,
      required this.name,
      required this.symbol,
      this.flag,
    });

    static const usd = Currency(code: 'USD', name: 'US Dollar', symbol: '\$', flag: '🇺🇸');
    static const eur = Currency(code: 'EUR', name: 'Euro', symbol: '€', flag: '🇪🇺');
    static const gbp = Currency(code: 'GBP', name: 'British Pound', symbol: '£', flag: '🇬🇧');
    // ... add 30+ currencies
  }
  ```
- [ ] Create list of supported currencies
- [ ] Create `lib/features/currency_converter/models/exchange_rate.dart`
- [ ] Define ExchangeRate class:
  ```dart
  class ExchangeRate {
    final String baseCurrency;
    final Map<String, double> rates;
    final DateTime timestamp;

    const ExchangeRate({
      required this.baseCurrency,
      required this.rates,
      required this.timestamp,
    });

    factory ExchangeRate.fromJson(Map<String, dynamic> json) {
      return ExchangeRate(
        baseCurrency: json['base'] as String,
        rates: Map<String, double>.from(json['rates']),
        timestamp: DateTime.parse(json['date']),
      );
    }

    Map<String, dynamic> toJson() => {
      'base': baseCurrency,
      'rates': rates,
      'date': timestamp.toIso8601String(),
    };
  }
  ```

**Files:**
- Create: `lib/features/currency_converter/models/currency.dart`
- Create: `lib/features/currency_converter/models/exchange_rate.dart`

**Acceptance:**
- Currency model with 30+ currencies
- ExchangeRate model with JSON serialization
- Models ready for API integration

**Supported Currencies (minimum 30):**
USD, EUR, GBP, JPY, AUD, CAD, CHF, CNY, SEK, NZD, MXN, SGD, HKD, NOK, KRW, TRY, RUB, INR, BRL, ZAR, DKK, PLN, THB, IDR, HUF, CZK, ILS, CLP, PHP, AED

---

### Ticket 3.3: Implement API Service
**Type:** New Feature
**Priority:** Critical
**Effort:** 2.5 hours

**Description:**
Create service to fetch exchange rates from Frankfurter API.

**Tasks:**
- [ ] Create `lib/features/currency_converter/data/currency_api_service.dart`
- [ ] Implement API service:
  ```dart
  class CurrencyApiService {
    static const String baseUrl = 'https://api.frankfurter.app';
    final http.Client client;

    CurrencyApiService({http.Client? client}) : client = client ?? http.Client();

    Future<ExchangeRate> getLatestRates(String baseCurrency) async {
      try {
        final url = Uri.parse('$baseUrl/latest?from=$baseCurrency');
        final response = await client.get(url).timeout(Duration(seconds: 10));

        if (response.statusCode == 200) {
          final json = jsonDecode(response.body);
          return ExchangeRate.fromJson(json);
        } else {
          throw CurrencyApiException('Failed to fetch rates: ${response.statusCode}');
        }
      } on SocketException {
        throw CurrencyApiException('No internet connection');
      } on TimeoutException {
        throw CurrencyApiException('Request timed out');
      } catch (e) {
        throw CurrencyApiException('Error fetching rates: $e');
      }
    }

    Future<List<String>> getSupportedCurrencies() async {
      try {
        final url = Uri.parse('$baseUrl/currencies');
        final response = await client.get(url).timeout(Duration(seconds: 10));

        if (response.statusCode == 200) {
          final json = jsonDecode(response.body) as Map<String, dynamic>;
          return json.keys.toList();
        } else {
          throw CurrencyApiException('Failed to fetch currencies');
        }
      } catch (e) {
        throw CurrencyApiException('Error fetching currencies: $e');
      }
    }
  }

  class CurrencyApiException implements Exception {
    final String message;
    CurrencyApiException(this.message);
    @override
    String toString() => message;
  }
  ```
- [ ] Add error handling for network issues
- [ ] Add timeout handling (10 seconds)

**Files:**
- Create: `lib/features/currency_converter/data/currency_api_service.dart`

**Acceptance:**
- API service fetches rates successfully
- Error handling for network issues
- Timeout after 10 seconds
- Returns ExchangeRate model

**API Documentation:**
- Endpoint: `https://api.frankfurter.app/latest?from=USD`
- Free, no API key required
- Rate limit: Reasonable usage
- Updates daily (European Central Bank data)

---

### Ticket 3.4: Implement Caching Layer
**Type:** New Feature
**Priority:** High
**Effort:** 2 hours

**Description:**
Cache exchange rates locally to enable offline mode.

**Tasks:**
- [ ] Create `lib/features/currency_converter/data/currency_repository.dart`
- [ ] Implement repository with caching:
  ```dart
  class CurrencyRepository {
    final CurrencyApiService _apiService;
    final SharedPreferences _prefs;
    static const String _cacheKey = 'exchange_rates_cache';
    static const String _timestampKey = 'exchange_rates_timestamp';
    static const Duration _cacheExpiry = Duration(hours: 24);

    CurrencyRepository({
      required CurrencyApiService apiService,
      required SharedPreferences prefs,
    }) : _apiService = apiService, _prefs = prefs;

    Future<ExchangeRate> getExchangeRates(String baseCurrency, {bool forceRefresh = false}) async {
      // Check if cache is valid
      if (!forceRefresh && _isCacheValid()) {
        final cached = _getCachedRates();
        if (cached != null && cached.baseCurrency == baseCurrency) {
          return cached;
        }
      }

      // Fetch fresh rates
      try {
        final rates = await _apiService.getLatestRates(baseCurrency);
        await _cacheRates(rates);
        return rates;
      } catch (e) {
        // If fetch fails, try to return cached rates
        final cached = _getCachedRates();
        if (cached != null) {
          return cached;
        }
        rethrow;
      }
    }

    bool _isCacheValid() {
      final timestamp = _prefs.getInt(_timestampKey);
      if (timestamp == null) return false;

      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      return DateTime.now().difference(cacheTime) < _cacheExpiry;
    }

    ExchangeRate? _getCachedRates() {
      final jsonString = _prefs.getString(_cacheKey);
      if (jsonString == null) return null;

      try {
        final json = jsonDecode(jsonString);
        return ExchangeRate.fromJson(json);
      } catch (e) {
        return null;
      }
    }

    Future<void> _cacheRates(ExchangeRate rates) async {
      final jsonString = jsonEncode(rates.toJson());
      await _prefs.setString(_cacheKey, jsonString);
      await _prefs.setInt(_timestampKey, DateTime.now().millisecondsSinceEpoch);
    }

    DateTime? getLastUpdateTime() {
      final timestamp = _prefs.getInt(_timestampKey);
      if (timestamp == null) return null;
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    }
  }
  ```
- [ ] Implement cache validation (24hr expiry)
- [ ] Implement fallback to cache on network error

**Files:**
- Create: `lib/features/currency_converter/data/currency_repository.dart`

**Acceptance:**
- Rates cached after fetch
- Cache used when valid (< 24hr old)
- Cache falls back on network error
- Last update time tracked

---

### Ticket 3.5: Create Currency Converter State
**Type:** New Feature
**Priority:** High
**Effort:** 1.5 hours

**Description:**
State management for currency converter.

**Tasks:**
- [ ] Create `lib/features/currency_converter/models/currency_state.dart`
- [ ] Define state:
  ```dart
  @immutable
  class CurrencyState {
    final Currency fromCurrency;
    final Currency toCurrency;
    final String fromAmount;
    final String toAmount;
    final ExchangeRate? rates;
    final DateTime? lastUpdate;
    final bool isLoading;
    final String? error;
    final bool isOffline;

    const CurrencyState({
      required this.fromCurrency,
      required this.toCurrency,
      this.fromAmount = '1',
      this.toAmount = '',
      this.rates,
      this.lastUpdate,
      this.isLoading = false,
      this.error,
      this.isOffline = false,
    });

    CurrencyState copyWith({ /* ... */ }) { /* ... */ }
  }
  ```
- [ ] Create `lib/features/currency_converter/providers/currency_provider.dart`
- [ ] Implement notifier with conversion logic
- [ ] Add provider initialization with dependency injection

**Files:**
- Create: `lib/features/currency_converter/models/currency_state.dart`
- Create: `lib/features/currency_converter/providers/currency_provider.dart`

**Acceptance:**
- State management working
- Conversion calculates correctly
- Loading states handled
- Error states handled

---

### Ticket 3.6: Build Currency Converter UI
**Type:** New Feature
**Priority:** High
**Effort:** 3 hours

**Description:**
Create the currency converter screen.

**Tasks:**
- [ ] Create `lib/features/currency_converter/presentation/currency_converter_screen.dart`
- [ ] Implement UI with:
  - Currency selector dropdowns (from/to)
  - Amount input fields
  - Swap button
  - Last update timestamp display
  - Refresh button
  - Loading indicator
  - Offline indicator
  - Error message display
- [ ] Style to match app theme (purple gradient)
- [ ] Add currency flags in dropdown (optional)
- [ ] Format amounts with intl package

**Files:**
- Create: `lib/features/currency_converter/presentation/currency_converter_screen.dart`

**Acceptance:**
- UI clean and intuitive
- Currency selectors work
- Amount updates in real-time
- Last update time shown
- Offline indicator visible when offline
- Loading spinner during API call

---

### Ticket 3.7: Implement Network Connectivity Detection
**Type:** New Feature
**Priority:** Medium
**Effort:** 1 hour

**Description:**
Detect network status and show offline indicator.

**Tasks:**
- [ ] Use connectivity_plus package
- [ ] Add connectivity check to provider
- [ ] Show offline banner when no network
- [ ] Use cached rates automatically when offline
- [ ] Add "Using cached rates" message

**Acceptance:**
- Offline mode detected
- Cached rates used when offline
- User informed of offline status

---

### Ticket 3.8: Update Navigation & iOS Privacy
**Type:** Integration
**Priority:** High
**Effort:** 30 minutes

**Description:**
Integrate currency converter and update iOS privacy settings.

**Tasks:**
- [ ] Update `lib/main.dart` - replace placeholder with CurrencyConverterScreen
- [ ] Update `ios/Runner/Info.plist`:
  ```xml
  <key>NSAppTransportSecurity</key>
  <dict>
    <key>NSAllowsArbitraryLoads</key>
    <false/>
  </dict>
  <!-- Add description for network usage -->
  <key>NSLocalNetworkUsageDescription</key>
  <string>This app fetches live currency exchange rates from a public API.</string>
  ```
- [ ] Test on iOS simulator

**Files:**
- Modify: `lib/main.dart`
- Modify: `ios/Runner/Info.plist`

**Acceptance:**
- Currency tab shows converter
- Network requests work on iOS
- No privacy warnings

---

### Ticket 3.9: Testing & Validation
**Type:** Testing
**Priority:** High
**Effort:** 2 hours

**Test Cases:**
- [ ] API fetches rates successfully
- [ ] Conversion calculations accurate (1 USD to EUR, etc.)
- [ ] Cache saves rates correctly
- [ ] Cache loads when offline
- [ ] Cache expires after 24 hours
- [ ] Refresh button refetches rates
- [ ] Swap button works
- [ ] Currency dropdowns show all 30+ currencies
- [ ] Last update time displays correctly
- [ ] Loading indicator shows during fetch
- [ ] Error messages display on API failure
- [ ] Offline mode works (airplane mode test)
- [ ] Network reconnection refreshes rates
- [ ] Large amounts formatted correctly
- [ ] Decimal precision appropriate

**Acceptance:**
- All tests passing
- No crashes or bugs
- Offline mode reliable

---

### Ticket 3.10: Git Commit
**Type:** Documentation
**Priority:** Medium
**Effort:** 10 minutes

**Tasks:**
- [ ] Commit:
  ```bash
  git commit -m "Epic 3: Add currency converter with live rates

  - Integrated Frankfurt API for exchange rates
  - 30+ currencies supported
  - Offline caching (24hr expiry)
  - Network detection and offline mode
  - Last update timestamp
  - iOS privacy configuration

  Resolves Epic 3 tickets 3.1-3.9"
  ```

---

## Definition of Done

- [ ] All 10 tickets completed
- [ ] API integration working
- [ ] 30+ currencies supported
- [ ] Caching implemented
- [ ] Offline mode functional
- [ ] UI complete and styled
- [ ] iOS privacy configured
- [ ] All tests passing
- [ ] Code committed

## Next Steps
After completing Epic 3, you'll have 3 functional calculators ready for App Store resubmission. Consider resubmitting at this point while continuing with Epics 4-5.
