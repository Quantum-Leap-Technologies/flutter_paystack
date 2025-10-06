# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is **flutter_paystack**, a Flutter plugin for integrating Paystack payment gateway. It provides card and bank payment methods with complete Android and iOS support. The plugin handles payment flows including OTP verification, PIN input, 3D Secure authentication, and birthday verification for bank payments.

## Development Commands

### Testing
```bash
flutter test                           # Run all tests
flutter test test/path/to/test.dart   # Run a specific test file
```

### Running the Example App
```bash
cd example
flutter run                           # Run example app on connected device
```

### Code Analysis
```bash
flutter analyze                       # Run Dart analyzer
```

### Building
```bash
flutter pub get                       # Get dependencies
cd example && flutter build apk       # Build Android APK
cd example && flutter build ios       # Build iOS (requires macOS)
```

## Architecture

### Core Components

1. **PaystackPlugin** (`lib/src/common/paystack.dart`)
   - Main entry point for the plugin
   - Must be initialized with `publicKey` (preferably in `initState()`)
   - Provides two payment methods: `chargeCard()` and `checkout()`
   - Validates SDK initialization and public key format (must start with `pk_`)

2. **Transaction Managers** (`lib/src/transaction/`)
   - `BaseTransactionManager`: Abstract base class handling common transaction flow
   - `CardTransactionManager`: Handles card payment flows (PIN, OTP, 3DS)
   - `BankTransactionManager`: Handles bank payment flows (birthday, tokens)
   - Transaction managers coordinate between UI widgets and API services

3. **API Services** (`lib/src/api/service/`)
   - `BaseApiService`: Mixin providing base URL (`https://standard.paystack.co`) and headers
   - `CardService`: Card payment API calls
   - `BankService`: Bank payment API calls
   - Services use contracts (interfaces) for dependency injection

4. **Payment Flow**
   - **Checkout Method** (Recommended): Plugin handles entire flow via `CheckoutWidget`
   - **Charge Card Method**: Developer controls flow manually via `chargeCard()`
   - Both methods require either `accessCode` (from backend initialization) or `reference`

### Key Models

- **Charge** (`lib/src/models/charge.dart`): Payment request with amount, email, card/bank details
- **PaymentCard** (`lib/src/models/card.dart`): Card details with validation methods
- **CheckoutResponse** (`lib/src/models/checkout_response.dart`): Payment result with status, message, reference
- **Transaction** (`lib/src/models/transaction.dart`): Server transaction state

### Widget Architecture

- **CheckoutWidget** (`lib/src/widgets/checkout/checkout_widget.dart`): Main checkout dialog
  - Manages tabbed interface for Card/Bank selection
  - Handles success/error states
  - Coordinates between `CardCheckout` and `BankCheckout` widgets
- **Input Widgets** (`lib/src/widgets/input/`): Reusable form fields with validation
- **Dialog Widgets**: `PinWidget`, `OtpWidget`, `BirthdayWidget` for user input during transaction flow

## Important Notes

- **Always use `debugPrint` instead of `print` statements** (as per global CLAUDE.md)
- The Paystack API base URL is `https://standard.paystack.co` (defined in `base_service.dart:17`)
- All amounts are in **base currency** (kobo for NGN, cents for USD, etc.)
- Card numbers are nullified after transactions for security
- Access codes are required for bank payments and selectable checkout methods
- Transaction verification should always be done on the backend after checkout

## Testing

Tests are located in `test/` directory with the same structure as `lib/`:
- `test/src/common/`: Utility and validation tests
- `test/src/models/`: Model tests (especially card validation)
- `test/src/widgets/`: Widget tests

Test utilities available:
- `test/src/common/widget_builder.dart`: Helper for building test widgets
- `test/src/common/case.dart`: Test case utilities

## Backend Integration

The example app (`example/lib/main.dart`) demonstrates backend integration:
- Initialize transaction on backend to get `accessCode`
- Pass `accessCode` to `Charge` object
- Verify transaction on backend after checkout completes
- See sample backend: https://github.com/PaystackHQ/sample-charge-card-backend
