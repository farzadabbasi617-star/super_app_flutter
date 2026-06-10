# 🌟 Super App Flutter - Project Interactive Index

This index is a temporary, comprehensive map of the **Super App** codebase. It lists the files, their architecture, their responsibilities, the improvements made so far, and suggestions for future iterations.

---

## 🗺️ Project Architecture Overview

The app is built using **Clean Architecture** combined with **BLoC** for state management, **GoRouter** for routing, and **GetIt** for dependency injection.

```
super_app_flutter/
├── lib/
│   ├── app.dart                   # Main app configuration, providers, and theme hookup
│   ├── main.dart                  # App entrance, secure binding, and DI initialization
│   │
│   ├── core/                      # Shared global resources and system clients
│   │   ├── di/                    # Dependency injection (Service Locator)
│   │   ├── error/                 # Failure models (Server, Connection, Validation, etc.)
│   │   ├── network/               # HTTP client (Dio) and WebSockets (Socket.IO)
│   │   ├── router/                # Central app routing configurations (GoRouter)
│   │   ├── storage/               # Secured encrypted storage (FlutterSecureStorage)
│   │   ├── theme/                 # Light/Dark material color & typography systems
│   │   └── utils/                 # Logging, validation and utility helpers
│   │
│   ├── features/                  # Independent functional modules (Features)
│   │   ├── auth/                  # Authentication & Role Management (Customer/Professional)
│   │   ├── map/                   # Geospatial Hub (Interactive Map & Shop Discovery)
│   │   ├── marketplace/           # Buy & Sell marketplace (Direct Purchase products)
│   │   ├── rental/                # Industrial & Agricultural heavy machinery rentals
│   │   └── services/              # Expert Booking (Offers, Consultations & Live Chat)
│   │
│   └── shared/                    # Core shared UI elements and cross-feature widgets
```

---

## 📂 Comprehensive File Registry & Roles

Here is a detailed breakdown of the critical files in each layer, along with their distinct roles:

### ⚡ 1. Core Services (`lib/core/`)

| File Path | Responsibility | Status / Improvements Made |
| :--- | :--- | :--- |
| `core/di/service_locator.dart` | The central Registry of all features. Resolves and registers Blocs, Repositories, and Use Cases. | 🛠️ **Fixed 3 compile errors:** Corrected typos in profile/payment import paths, and converted a syntax error on `AcceptServiceRequestUseCase` to a proper comment. |
| `core/network/network_client.dart` | Custom HTTP client wrapping the **Dio** package. Handles global timeouts, intercepts authorizations, and intercepts connection issues. | 🛠️ **Fixed 1 compile error:** Corrected a syntax typo where `e.response` was written as `e./response`. |
| `core/network/socket/socket_service.dart` | Configures and handles real-time **Socket.IO** connections, JWT handshakes, and handles keep-alive heartbeats. | 🟢 Fully functional. Connected to backend. |
| `core/router/app_router.dart` | Configures routing using **GoRouter**. | 🟢 Updated with the latest route mappings. |
| `core/storage/secure_storage_service.dart` | Encapsulates **FlutterSecureStorage** to securely save JWT tokens and cache profile data. | 🟢 Optimized with try-catch JSON parsing guards. |

---

### 📦 2. Application Features (`lib/features/`)

#### 🔑 A. Authentication (`features/auth/`)
* **`presentation/bloc/auth_bloc.dart`**: Coordinates Login, Register and Logout flows.
  * 🛠️ **Fixed 1 compile error:** Corrected the typo import `logout_/usecase.dart` to `logout_usecase.dart`.
* **`presentation/pages/login_page.dart` & `register_page.dart`**: Beautiful Material 3 forms with real-time text-input validators.
  * 🟢 Features role choice (Customer vs Professional) during registration.

#### 🗺️ B. Geospatial Hub (`features/map/`)
* **`presentation/pages/map_page.dart`**: Displays nearby physical stores and professionals on an interactive map.
  * 🚀 **HUGE Improvement:** Added a horizontal **Category Filter Chips Row** (All, Electronics, Plants, Cafe) and connected the **Search Bar** to filter markers in real-time.
  * 🚀 **Premium Overlay:** Designed a **Quick View Bottom Sheet** sliding up from the bottom when a marker is tapped, showcasing shop photos, live open/closed badges, hours, ratings, and a button to visit their full profile.
  * 🚀 **Navigation FAB:** Placed a prominent **"Request Expert"** FAB that smoothly triggers the service dispatch flow.

#### 🛒 C. Marketplace (`features/marketplace/`)
* **`presentation/pages/explore_page.dart`**: Buy & Sell hub for direct purchases.
  * 🛠️ **Separated from Rentals:** Following your architectural request, this page now only lists direct-purchase products (`isRental = false`) and displays purchase-related categories.
  * 🛠️ **Fixed Categories Filter Bug:** Created a new `GetCategoriesUseCase` and connected the `ProductBloc` to load categories. Also fixed a key matching bug where the UI passed category IDs instead of names, correcting the filter function.
  * 🚀 **Purchase flow:** Wrapped cards with action handlers; tapping opens a sleek "Confirm Purchase" dialog.

#### 🚜 D. Machinery Rentals (`features/rental/`)
* **`presentation/pages/rental_page.dart`**: Dedicated leasing marketplace for heavy machinery (Industrial & Agricultural).
  * 🚀 **Brand New Separation:** Displays heavy tools and agricultural machinery (`isRental = true`).
  * 🟢 Tapping on any item opens the **`RentalBookingPage`** (calendar booking sheet with cost calculations).

#### 🛠️ E. Expert Services Booking (`features/services/`)
* **`presentation/pages/request_service_page.dart`**: Customer hub for requesting live on-demand specialists.
  * 🚀 **Upgraded Searching UI:** Replaced the loading spinner with the **Offers Hub** (`CustomerOffersView`) to view bids in real-time.
  * 🚀 **Upgraded Assigned UI:** Replaced the simple vehicle icon with an **Expert Tracking Sheet**, detailing the chosen expert's name, verified badge, rating, final confirmed price, and phone/chat shortcuts.
* **`presentation/pages/customer_offers_view.dart`**: **(Brand New Page!)**
  * 🎨 **Offers Pipeline:** Simulates real-time offer arrivals with fading animations.
  * 💬 **Consultation Chat Page:** An immersive, live chat consultation interface between the customer and experts.
  * 🤖 **Context-Aware Automations:** Expert simulates typing and replies intelligently with answers regarding pricing, ETA, or instructions.
  * 💰 **Price Confirmation:** Allows the customer to click "Select & Confirm Price" to finalize.

---

## 🛠️ Summary of Completed Improvements

1. **Compilation Typos Cleared:** Removed accidental slashes (`/`) in import lines, service registrations, and code variables (`e./response`).
2. **Architecture Separation:** Completely split direct purchases (Marketplace) from heavy machinery leases (Rentals) into two dedicated screens.
3. **Interactive Maps:** Fully upgraded the Map page with real-time text searches, category chip filters, and sliding quick-view bottom sheets.
4. **End-to-End Real-Time Services:** Built the entire bidding pipeline from broadcasting to bid arrival, consultation chat with smart bots, selection, and tracking.
5. **Cleaned Dependencies:** Consolidated `pubspec.yaml` by deleting duplicate lines and neatly sorting versions.

---

*This document is created temporarily to help you visualize and inspect your updated Flutter project directly.*
