# Maps and Location Setup

This app includes a "View Pickup Location" feature that shows the driver's current location and the pickup location on a map with distance calculation.

## API Keys Configuration

### Option 1: OpenStreetMap (Free - Recommended)
The app is configured to use OpenStreetMap by default, which doesn't require an API key.

### Option 2: Google Maps API
If you prefer Google Maps, follow these steps:

1. **Get API Key**:
   - Go to [Google Cloud Console](https://console.cloud.google.com/)
   - Create a new project or select existing one
   - Enable the following APIs:
     - Maps SDK for Android
     - Maps SDK for iOS
     - Directions API
     - Geocoding API
   - Create credentials (API Key)
   - Restrict the API key to your app for security

2. **Configure API Key**:
   Open `lib/config/api_config.dart` and replace:
   ```dart
   static const String googleMapsApiKey = 'YOUR_GOOGLE_MAPS_API_KEY_HERE';
   ```
   With your actual API key.

### Option 3: Mapbox API
Alternatively, you can use Mapbox:

1. **Get API Key**:
   - Sign up at [Mapbox](https://www.mapbox.com/)
   - Get your access token from the account dashboard

2. **Configure API Key**:
   Open `lib/config/api_config.dart` and replace:
   ```dart
   static const String mapboxApiKey = 'YOUR_MAPBOX_API_KEY_HERE';
   ```

## Permissions

The app requires the following permissions:

### Android
- `ACCESS_FINE_LOCATION` - For precise location
- `ACCESS_COARSE_LOCATION` - For approximate location
- `ACCESS_BACKGROUND_LOCATION` - For background location updates
- `INTERNET` - For map tiles and API calls

### iOS
Add to `ios/Runner/Info.plist`:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs location access to show your current location on the map</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>This app needs location access to track your location during rides</string>
```

## Features

### View Pickup Location
- Shows driver's current location (green marker)
- Shows pickup location (blue marker)
- Displays route line between locations
- Calculates and shows distance in kilometers
- Zoom controls and current location button

### Distance Calculation
- Uses Haversine formula for accurate distance calculation
- Shows distance with configurable precision
- Updates in real-time as location changes

## Dependencies

The following packages are used:
- `flutter_map` - Interactive map widget
- `geolocator` - Location services
- `latlong2` - Latitude/longitude utilities
- `flutter_polyline_points` - Route drawing (optional)
- `permission_handler` - Permission management

## Troubleshooting

### Location Not Working
1. Ensure location permissions are granted
2. Check if GPS is enabled on device
3. Try moving to an open area for better GPS signal

### Map Not Loading
1. Check internet connection
2. Verify API key configuration (if using Google Maps/Mapbox)
3. Try switching to OpenStreetMap (free option)

### Distance Calculation Issues
- Ensure both coordinates are valid
- Check if location services are working
- Distance is calculated in kilometers by default

## Customization

### Map Style
You can change the map style by modifying the tile URL in `PickupLocationMapPage.dart`:
- OpenStreetMap: `https://tile.openstreetmap.org/{z}/{x}/{y}.png`
- Google Maps: Requires API key setup
- Mapbox: Requires API key setup

### Distance Unit
Change the distance unit in `lib/config/api_config.dart`:
```dart
static const String distanceUnit = 'km'; // or 'miles'
```

### Map Markers
Customize marker appearance in `PickupLocationMapPage.dart`:
- Change colors, icons, and sizes
- Add custom images for markers
- Adjust marker positioning
