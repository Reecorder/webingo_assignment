# Flight Booking App

A Flutter-based flight booking application that allows users to search for flights, view flight details, and manage bookings.

## Getting Started

### Prerequisites

- Flutter SDK (version 3.7.2 or higher)
- Dart SDK 
- Android Studio or VS Code with Flutter extensions
- Android/iOS emulator or physical device

### Installation

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd booking_app
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

### Building for Production

- For Android APK:
  ```bash
  flutter build apk --release
  ```

- For iOS (on macOS):
  ```bash
  flutter build ios --release
  ```

## Dependencies

The app uses the following key dependencies:

- **GetX (^4.7.3)**: State management and navigation
- **Dio (^5.9.2)**: HTTP client for API calls
- **Intl (^0.20.2)**: Internationalization and localization
- **Lucide Icons Flutter (^3.1.10)**: Icon library
- **Barcode Widget (^2.0.4)**: For generating barcodes
- **Screenshot (^3.0.0)**: For capturing screenshots
- **Permission Handler (^12.0.1)**: For handling device permissions
- **Gal (^2.3.2)**: For accessing device gallery

## Architecture and Approach

### Project Structure

The app follows a modular architecture:

- `lib/app/`: Core app components (constants, routes, theme, widgets)
- `lib/data/`: Data layer (models, providers)
- `lib/modules/`: Feature modules (flight booking functionality)
- `lib/services/`: API services and utilities

### Thought Process

1. **Modular Design**: Organized the codebase into modules for better maintainability and scalability.

2. **State Management**: Used GetX for reactive state management and dependency injection, providing a clean and efficient way to manage app state.

3. **API Integration**: Implemented Dio for robust HTTP requests with error handling through custom API exception classes.

4. **UI Components**: Created reusable widgets and followed Material Design principles for consistent UI.

## API Routes

The app talks to a backend API for airport lookups, flight search, and flight details.

- `flight_api.php/airports/from` — Used when selecting the departure airport. **Note:** the current backend implementation only returns Jakarta airports on this route.
- `flight_api.php/airports/to` — Used when selecting the destination airport. This route returns all supported airports.
- `flight_api.php/search` — Used to search for available flights. The request includes `from`, `to`, `date`, `passengers`, pagination, and filter parameters.
- `flight_api.php/flight` — Used to fetch detailed information for a specific flight ID.
- `flight_api.php/airlines` — Used to populate the airline filter dropdown.
- `flight_api.php/aircraft-types` — Used to populate the aircraft type filter dropdown.

## Architecture Pattern

The app follows an **MVC-like** structure using GetX:

- **Models**: Represent the API payloads (see below).
- **Views**: Flutter widgets in `lib/modules/flight` show the UI.
- **Controllers**: GetX controllers (e.g., `FlightController`) hold state, business logic, and call services.
- **Services**: `lib/services/*` contains API clients and helper logic.

## Data Models

The main models used by the app are:

- `AirportModel` — represents airports returned from the `/airports/from` and `/airports/to` endpoints.
- `FlightModel` — used for flight listings (departure/arrival info, pricing, airline, stops, etc.).
- `FlightDetailsModel` — used for the full booking/flight details view; it wraps:
  - `FlightDetails` (detailed flight schedule and gate/terminal info)
  - `Passengers` (passenger list & seats)
  - `BookingInfo` (booking reference, date, barcode)

## Key Features Implemented

- **Splash Screen**: Animated branding screen with "Webingo" logo and tagline for app launch experience.
- Airport lookup (departure + destination)
- Flight search with filters (airline, price range, stops, aircraft type)
- Paginated flight listings
- Flight details view (including passenger & booking information)
- Booking summary with barcode generation
- Screenshot capture + gallery saving

## Screens

The app consists of the following main screens:

- **Splash Screen** (`lib/modules/splash/presentation/splash_screen.dart`): Displays the app logo ("Webingo") with a gradient background and animation. Serves as the initial loading screen before navigating to the main app.
- **Flight Search** (`lib/modules/flight/presentations/flight_search.dart`): Main search interface where users select departure/destination airports, travel date, number of passengers, and initiate flight search. Includes saved trips section.
- **Flight List** (`lib/modules/flight/presentations/flight_list.dart`): Displays paginated list of available flights based on search criteria. Includes filters for airline, price, stops, and aircraft type. Supports load more functionality.
- **Flight Details** (`lib/modules/flight/presentations/flight_details_ui.dart`): Shows comprehensive flight information including schedule, passenger details, booking reference, and barcode for the selected flight.

## Error Handling

The app implements comprehensive error handling to ensure a smooth user experience:

- **API Errors**: Uses Dio for HTTP requests with custom `ApiException` class to wrap API failures (e.g., network issues, invalid responses). Services throw these exceptions, which are caught in controllers.
- **User Feedback**: Errors are displayed via GetX snackbars (e.g., "No flights found" or "Failed to fetch airports").
- **Graceful Degradation**: If API calls fail, the app shows appropriate messages without crashing. For example, empty states are handled in flight listings.
- **Validation**: Input validation prevents invalid requests, and UI states (loading indicators) inform users during async operations.

## Development Time

Approximate total hours taken to build the app with all listed functionality: **40–50 hours**

Breakdown:
- Project setup and architecture design: 5 hours
- Implementing flight search, results list, and pagination: 15 hours
- UI/UX development (screens, widgets, navigation): 15 hours
- API integration, models, and data handling: 8 hours
- Testing, bug fixes, and polish: 7 hours

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request


