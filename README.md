# InShelf

InShelf is an iOS application designed to organize and manage household pantry items, track product quantities, and monitor expiration dates to reduce food waste.

## Overview

InShelf helps users keep an accurate record of food items at home. It categorizes products into stock or shopping lists, provides expiration alerts, and organizes inventory with a visual food icon catalog.

## Features

- **Stock Tracking**: View all items currently in stock with quantities, location tags, and expiration dates.
- **Expiration Alerts**: Color-coded expiration indicators:
  - Green: Safe / within valid period
  - Orange: Expiring soon (within 3 days)
  - Red: Expired items (grouped with a summary alert)
- **Item Management**:
  - Add and edit items with custom food icons.
  - Measure in units, kilograms (Kg), or grams.
  - Switch item states between "To buy" and "In Stock".
  - Add notes and expiration dates with localized date pickers.
  - Delete items with swipe-to-delete.
- **Creations Hub**: Quick access to manage items, recipes, and featured suggestions.
- **Local Persistence**: Built with SwiftData for fast, offline-first data storage on the device.

## Tech Stack

- **Language**: Swift 5.0+
- **Framework**: SwiftUI
- **Database**: SwiftData
- **Platform**: iOS 17.0+
- **IDE**: Xcode 16+

## Project Structure

```text
InShelf/
├── App/
│   ├── Assets.xcassets/   # Color assets, illustrations, and SVG food icons
│   ├── InShelfApp.swift   # App entry point and SwiftData ModelContainer setup
│   └── TabBar.swift        # Main bottom navigation
├── Components/
│   ├── EmptyStateView.swift    # Reusable empty states for inventory and items
│   ├── FeaturedCardView.swift  # Featured recipe banner component
│   ├── ItemBar.swift           # Card component for listing food items
│   └── MenuCardView.swift      # Navigation cards for creations hub
├── Models/
│   ├── EmptyStateType.swift    # Enum for empty state variants
│   ├── ItemBarType.swift       # Enum for item bar visual variants
│   ├── ItemIcon.swift          # Food icon mappings (SVG image assets)
│   └── StockItem.swift         # SwiftData model for inventory items
└── Screens/
    ├── ComingSoon.swift        # Placeholder screen for upcoming tabs
    ├── Create.swift            # Creations hub screen
    ├── Item.swift              # Item creation and edit form
    ├── MyItems.swift           # Full list of user items
    └── Stock.swift             # Main stock inventory with expiration sorting
```

## Getting Started

### Prerequisites

- macOS Sonoma 14.0 or later
- Xcode 16.0 or later
- iOS 17.0+ Simulator or physical device

### Installation

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd InShelf
   ```

2. Open the project in Xcode:
   ```bash
   open InShelf.xcodeproj
   ```

3. Select your target device or simulator in Xcode and press `Cmd + R` to build and run.

## License

This project is available under the MIT License.
