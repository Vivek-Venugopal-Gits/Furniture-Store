# Furniture Store — Premium Flutter Mobile Application

A state-of-the-art Flutter e-commerce shopping experience for handcrafted furniture. Built with clean architecture, unidirectional data flow via BLoC, dynamic JSON-driven discovery, local persistence, responsive design, and smooth infinite scrolling.

---

## 1. Project Overview

**Furniture Store** is a mobile shopping experience crafted to reflect modern artisanal furniture houses. It showcases natural timber joinery, tactile fabrics, and architectural silhouettes within a warm, high-contrast palette of Deep Walnut, Warm Brown, Cream, and Soft Beige.

Key Highlights:
* **Zero Hardcoded Categories**: All categories and subcategories are dynamically derived at runtime from the product JSON dataset. Adding a new category to the dataset requires zero UI modifications.
* **Pure Clean Architecture**: Strict separation of concerns across Presentation (BLoC/UI), Domain (Repository contracts), and Data (Local Data Sources and strongly-typed models).
* **Local User Persistence**: Complete authentication cycle (Signup with duplicate email checks, Indian mobile number validation, Login, Session Persistence, and Logout) operating entirely offline via local device storage.
* **Smooth Infinite Scrolling**: Lazy grid loading with configurable batch sizing (8 items initial and incremental), debounced bottom detection, and visual indicators.
* **Explainable Implementation**: Transparent code design adhering strictly to industry standards without unnecessary abstraction or obscure dependencies.

---

## 2. Features

### Discovery & Marketplace
- **Dynamic Category Pills**: Horizontally scrollable chips generated reactively from loaded products.
- **Search**: Fast, case-insensitive search matching against `Product.name`.
- **Dynamic Multi-Factor Filtering**:
  - Category filter (extracted dynamically).
  - Subcategory filter (dynamically reacts to the selected category).
  - Price Range Slider (minimum and maximum bounds calculated dynamically from loaded product dataset).
  - Customer Rating filter (3.5+, 4.0+, 4.5+, All).
- **Dataset-Preserving Sorting**:
  - *Newest Arrivals*: Preserves original JSON dataset order (satisfying strict schema without artificial date fields).
  - *Price: Low to High*.
  - *Price: High to Low*.
  - *Customer Rating*.
- **Responsive 2-Column Product Grid**: Product cards with Hero image transitions, formatted Indian Rupee pricing (`₹5,499`), strikethrough original prices, discount percentage pills, and rating badges.
- **Infinite Scrolling**: Lazy rendering via `GridView.builder` triggering automatic batch fetch upon reaching bottom threshold.
- **Product Details Showcase**: Full presentation of dimensions (Width, Depth, Height in a 3-box layout), material, color finish, suitable rooms, features checklist, and remaining stock indicator.
- **Visual Cart & Explore Tabs**: Decorative shopping bag page emphasizing showroom concept, alongside curated collection carousels.

### Authentication & Profile
- **Registration**: Form collecting Full Name, Email, Indian Phone Number (10 digits starting with 6-9), Password, and Confirm Password with real-time validation.
- **Duplicate Email Prevention**: Prevents duplicate accounts with user-friendly error messages.
- **Local Persistence**: Stores registered users locally in serialized device storage (`SharedPreferences`).
- **Session Continuity**: Remembers logged-in user on subsequent app restarts.
- **Read-Only Profile**: Displays user initials, Full Name, Email, and Phone number with safe logout dialog.

---

## 3. Technology Stack

* **Framework**: Flutter 3.41+ / Dart 3.11+
* **State Management**: `flutter_bloc` (v9.1.1)
* **Value Equality**: `equatable` (v3.0.0)
* **Local Storage**: `shared_preferences` (v2.5.5)
* **Typography**: `google_fonts` (Playfair Display for luxury serif headings, Inter for clean modern body)
* **Testing**: `flutter_test` (Full suite covering Validators, Models, Repositories, BLoCs, and Widgets)

---

## 4. Architecture

The application strictly implements Clean Architecture with unidirectional data flow:

```
┌─────────────────────────────────────────────────────────────┐
│                       Presentation Layer                    │
│   (Widgets, Pages, Responsive Layouts, Navigation)          │
└──────────────────────────────▲──────────────────────────────┘
                               │ State / Events
┌──────────────────────────────▼──────────────────────────────┐
│                    State Management (BLoC)                  │
│       • AuthBloc: AuthState (Session, Login, Register)       │
│       • ProductBloc: ProductState (Catalog, Infinite Scroll) │
└──────────────────────────────▲──────────────────────────────┘
                               │ Domain Entities / Contracts
┌──────────────────────────────▼──────────────────────────────┐
│                      Repository Layer                       │
│       • AuthRepository / AuthRepositoryImpl                 │
│       • ProductRepository / ProductRepositoryImpl           │
└──────────────────────────────▲──────────────────────────────┘
                               │ Raw DTOs / JSON Maps
┌──────────────────────────────▼──────────────────────────────┐
│                    Local Data Source Layer                  │
│       • UserLocalDataSource (Asset seed + SharedPreferences)│
│       • ProductLocalDataSource (Asset `products.json`)      │
└─────────────────────────────────────────────────────────────┘
```

---

## 5. Folder Structure

```text
lib/
│
├── core/
│   ├── constants/
│   │   └── app_constants.dart          # Asset paths, storage keys, batch size
│   ├── theme/
│   │   ├── app_colors.dart             # Walnut, Warm Brown, Cream, Sage, Terracotta
│   │   └── app_theme.dart              # Centralized ThemeData, typography, and buttons
│   └── utils/
│       └── validators.dart             # Name, Email, India Phone, Password rules
│
├── data/
│   ├── datasources/
│   │   ├── product_local_data_source.dart   # Asset bundle reader for products.json
│   │   └── user_local_data_source.dart      # Local persistence with SharedPreferences
│   ├── models/
│   │   ├── dimensions.dart             # Nested dimensions (width, depth, height)
│   │   ├── product.dart                # Strict 17-field Product model
│   │   └── user.dart                   # Full name, email, phone, password
│   └── repositories/
│       ├── auth_repository_impl.dart   # Auth validation and session management
│       └── product_repository_impl.dart# Filter, sort, and dynamic category extraction
│
├── domain/
│   └── repositories/
│       ├── auth_repository.dart        # Domain contract for authentication
│       └── product_repository.dart     # Domain contract for catalog discovery
│
├── features/
│   ├── auth/
│   │   ├── bloc/
│   │   │   ├── auth_bloc.dart
│   │   │   ├── auth_event.dart
│   │   │   └── auth_state.dart
│   │   └── pages/
│   │       ├── login_page.dart
│   │       └── signup_page.dart
│   ├── home/
│   │   ├── pages/
│   │   │   ├── home_page.dart
│   │   │   ├── explore_page.dart
│   │   │   └── cart_placeholder_page.dart
│   │   └── widgets/
│   │       ├── category_selector.dart  # Dynamic horizontal category pills
│   │       ├── filter_bottom_sheet.dart# Dynamic multi-criteria modal sheet
│   │       ├── hero_banner.dart        # Visual architectural showcase banner
│   │       ├── home_header.dart        # Personalized greeting, branding & icons
│   │       ├── product_card.dart       # Card with image, pricing, and discount badge
│   │       └── search_bar_widget.dart  # Clearable search with filter trigger
│   ├── navigation/
│   │   └── main_screen.dart            # BottomNavigationBar shell (Home, Explore, Cart, Profile)
│   ├── products/
│   │   ├── bloc/
│   │   │   ├── product_bloc.dart
│   │   │   ├── product_event.dart
│   │   │   └── product_state.dart
│   │   └── pages/
│   │       └── product_details_page.dart # Full specification layout
│   └── profile/
│       └── pages/
│           └── profile_page.dart       # Read-only user details & logout action
│
├── app.dart                            # MultiBlocProvider, MaterialApp, and Gatekeeper
└── main.dart                           # Entrypoint initializing storage & services
│
assets/
├── data/
│   ├── products.json                   # Curated dataset of 25 furniture items
│   └── users.json                      # Seed empty user dataset
└── images/
    └── products/                       # Local offline photography assets (JPEGs)
```

---

## 6. Data Flow

### Product Catalog Discovery
```text
assets/data/products.json
            ↓
ProductLocalDataSourceImpl
            ↓
ProductRepositoryImpl (Dynamic Categories, Dynamic Subcategories, Price Bounds)
            ↓
ProductBloc (Search -> Filter -> Sort -> Pagination Slice)
            ↓
Presentation UI (HomePage, ProductCard, FilterBottomSheet, ProductDetailsPage)
```

### User Authentication & Local Storage
```text
assets/data/users.json (seed fallback) / SharedPreferences (persisted JSON)
            ↓
UserLocalDataSourceImpl
            ↓
AuthRepositoryImpl (Duplicate Email Check, Credential Verification, Session Tracking)
            ↓
AuthBloc (Emits Authenticated, Unauthenticated, or AuthFailure)
            ↓
AuthGatekeeper (Directs to MainScreen or LoginPage)
```

---

## 7. Infinite Scrolling Explanation

1. **Lazy Viewport Rendering**: The home page uses a `CustomScrollView` with `SliverGrid.builder`. Only visible product widgets are painted in memory.
2. **Scroll Threshold Listener**: A `ScrollController` monitors viewport offset. When:
   ```dart
   scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200
   ```
   a `LoadMoreProducts` event is dispatched to `ProductBloc`.
3. **Pagination Guard**: `ProductBloc` checks `state.hasMore` and `!state.isLoadingMore` to prevent redundant concurrent dispatches.
4. **State Batch Increment**:
   - Initial visible count: `8 items`.
   - Batch increment: `+8 items` on each scroll reach.
   - When all filtered items are visible (`visibleCount >= filteredProducts.length`), `hasMore` becomes `false`.
5. **Filter & Search Integration**: Whenever search text or filter criteria change, the visible count immediately resets to 8, recalculates the filtered subset, and resets the scroll position.

---

## 8. Search, Filtering, and Sorting Pipeline

Filtering and sorting logic are cleanly separated inside `ProductRepositoryImpl`:

1. **Search**: Matches query string against `Product.name` using case-insensitive substring search.
2. **Category**: Evaluates whether `product.category.toLowerCase() == selectedCategory.toLowerCase()`.
3. **Subcategory**: Evaluates whether `product.subcategory.toLowerCase() == selectedSubcategory.toLowerCase()`.
4. **Price Range**: Restricts results between dynamic `selectedMinPrice` and `selectedMaxPrice`.
5. **Rating**: Checks `product.rating >= selectedMinRating`.
6. **Sorting**:
   - `Newest`: Preserves the original JSON dataset index order (interpreting earlier items in the file as newest arrivals).
   - `Price: Low to High`: Ascending numeric sort on `product.price`.
   - `Price: High to Low`: Descending numeric sort on `product.price`.
   - `Rating`: Descending numeric sort on `product.rating`.

---

## 9. Local Storage & Offline Authentication

- **No Remote Backend**: As specified, the application contains no remote servers or external authentication endpoints.
- **Initial Dataset**: Bundled initially as an empty list inside `assets/data/users.json`.
- **Runtime Persistence**: When a user registers:
  1. The user record is validated (Full Name format, RFC email regex, Indian 10-digit phone format, minimum 6-character password).
  2. Uniqueness check verifies email does not already exist.
  3. The user list is serialized to JSON string and committed to local device `SharedPreferences`.
  4. The active session email key is persisted.
- **App Launch Lifecycle**:
  `AuthBloc` automatically queries the stored session token/email. If a valid user matches the key, the app bypasses login and proceeds directly to the home screen.

---

## 10. How Product JSON Works

Each product object in `assets/data/products.json` strictly adheres to the schema:

```json
{
  "id": 1,
  "name": "Malabar Cane Inset Dining Chair",
  "category": "Chair",
  "subcategory": "Dining Chair",
  "price": 5499,
  "originalPrice": 7499,
  "discountPercentage": 27,
  "description": "Crafted to elevate any dining area, this chair blends solid rubberwood joinery with a breathable natural cane-woven backrest. A cushioned foam seat upholstered in textured beige linen offers lasting support for lengthy dinner conversations.",
  "material": "Solid Rubberwood and Natural Cane",
  "color": "Honey Oak and Muted Beige",
  "dimensions": {
    "width": "48 cm",
    "depth": "53 cm",
    "height": "88 cm"
  },
  "suitableFor": "Dining Room",
  "features": [
    "Hand-stretched natural octagonal cane backrest",
    "Solid plantation-grown rubberwood structure",
    "High-resilience foam seat with linen upholstery",
    "Mortise and tenon joinery for structural stability",
    "Felt floor pads to prevent floor scuffs"
  ],
  "rating": 4.4,
  "reviewCount": 89,
  "stock": 38,
  "imageUrl": "assets/images/products/chair_01.jpg"
}
```

> **Strict Constraint Compliance**: No external fields (e.g. `brand`, `sku`, `tags`, `isFeatured`, `createdAt`, `updatedAt`, `wishlist`, `colorCode`) were added.

---

## 11. How to Add New Products

To add a new product:
1. Place a corresponding local image file inside `assets/images/products/` (e.g., `bench_01.jpg`).
2. Open `assets/data/products.json` and append a new JSON object following the schema above:
   ```json
   {
     "id": 26,
     "name": "Artisanal Entryway Storage Bench",
     "category": "Bench",
     "subcategory": "Storage Bench",
     "price": 7999,
     "originalPrice": 9999,
     "discountPercentage": 20,
     "description": "Solid oak entryway bench with shoe storage rack.",
     "material": "Solid Oak Wood",
     "color": "Natural Matte Oak",
     "dimensions": {
       "width": "110 cm",
       "depth": "40 cm",
       "height": "48 cm"
     },
     "suitableFor": "Entryway or Hallway",
     "features": [
       "Lower slatted shoe tier",
       "Solid mortise and tenon construction"
     ],
     "rating": 4.6,
     "reviewCount": 18,
     "stock": 12,
     "imageUrl": "assets/images/products/bench_01.jpg"
   }
   ```
3. Restart or hot reload the app. **"Bench"** will automatically appear as a distinct category tab and filter choice without any UI code changes.

---

## 12. How to Run

### Prerequisites
* Flutter SDK (version 3.20+ or 3.41+)
* Dart SDK (version 3.4+ or 3.11+)
* Connected Android/iOS emulator, Chrome browser, or Windows desktop device.

### Running the App
1. Clone or navigate to the repository directory:
   ```bash
   cd White_Matrix_Round_1
   ```
2. Install packages:
   ```bash
   flutter pub get
   ```
3. Run code analysis (verifies zero lint warnings):
   ```bash
   flutter analyze
   ```
4. Run comprehensive test suite (all 31 unit, BLoC, and widget tests):
   ```bash
   flutter test
   ```
5. Launch the application:
   ```bash
   flutter run -d <device-id>

   # Run on connected Windows desktop
   flutter run -d windows

   # Or run on Chrome Web
   flutter run -d chrome
   ```

---

## 13. Test Coverage Summary

The project includes 31 thorough automated tests:
* `Validators Tests`: Full name length/characters, RFC-compliant email, Indian mobile number constraints (10 digits starting with 6-9), password length, and password match.
* `Model Tests`: Complete `Product`, `Dimensions`, and `User` serialization and deserialization roundtrips.
* `Repository Discovery Tests`: Dynamic category extraction, dynamic subcategories, dataset price boundary computation, case-insensitive search on `Product.name`, category and subcategory filtering, and all 4 sorting modes.
* `Auth Persistence Tests`: Offline user creation, duplicate email rejection, invalid credential handling, session initialization, and session clearing on logout.
* `ProductBloc Tests`: Initial 8-item batch emission, pagination batch expansion (+8 on scroll), category filtering resetting visible count.
* `Widget Tests`: App launch, splash sequence, and unauthenticated gatekeeper routing.

---

## 14. Screenshots & Design Showcase

* **Palette**: Walnut (`#3E2723`), Warm Brown (`#795548`), Cream (`#FBF9F5`), Soft Beige (`#F3EFEA`), Sage (`#7A9A8B`), Terracotta (`#C27D68`), Dark Espresso (`#1F1610`).
* **Visual Hierarchy**: High-contrast product imagery with rounded container clipping, subtle elevation shadows, and clear typography.
* **Layouts**: Responsive grid adapts cleanly to phone aspect ratios without overflowing text or clipping.
