# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Eteria (永念) is a memorial app with a Flutter frontend and Node.js backend that allows users to create digital memorial spaces for deceased loved ones. The app features user authentication with email verification, memorial management, photo uploads, and social interactions.

**Current Status**: The app includes a fully functional Flutter frontend with Provider state management, glassmorphism UI design, and integration with a Node.js backend. Key features implemented include waterfall grid layout with staggered grid view, memorial creation/viewing, photo upload with compression, authentication flow, detailed memorial pages with interactive elements, and a digital life section.

## Architecture

### Flutter Frontend (Main Repository)
- **Framework**: Flutter 3.9.0+ with Dart SDK 3.0.0+
- **UI Theme**: Custom glassmorphism theme with warm colors and paper texture backgrounds
- **State Management**: Provider pattern with AuthProvider and MemorialProvider
- **API Communication**: Singleton ApiClient with JWT token management at `http://127.0.0.1:3000/api/v1`
- **Data Persistence**: SharedPreferences for user sessions and local storage
- **Image Handling**: ImagePicker for selection, flutter_image_compress for optimization, cached_network_image for display
- **Code Generation**: JSON serialization using build_runner and json_serializable
- **UI Components**: Glass-style widgets including GlassBottomNavigation, GlassMemorialCard, PhotoCarousel, StaggeredGridView
- **Navigation**: Bottom navigation with glassmorphism effects and Hero animations

### Backend API (Sibling Directory)
- **Location**: `/Users/tuohai/Documents/后端/eteria-backend/`
- **Framework**: Node.js with Express.js
- **Database**: PostgreSQL with Sequelize ORM
- **Cache**: Redis for session management and verification codes
- **Authentication**: JWT tokens with email verification workflow
- **Email Service**: Aruba SMTP for verification codes
- **File Storage**: Local file system with multer and sharp for image processing

## Key Development Commands

### Flutter Frontend
```bash
# Install dependencies
flutter pub get

# Generate JSON serialization code (required after model changes)
dart run build_runner build --delete-conflicting-outputs

# Run app (iOS simulator recommended for local backend connectivity)
flutter run --debug

# Run in release mode for performance testing
flutter run --release

# Hot reload during development (press 'r' in terminal)
# Hot restart (press 'R' in terminal)

# Run tests
flutter test

# Run single test file
flutter test test/widget_test.dart

# Build for release
flutter build apk --release        # Android
flutter build ios --release        # iOS

# Check for lint issues
flutter analyze

# Format code
dart format .
```

### Backend (if needed)
```bash
cd /Users/tuohai/Documents/后端/eteria-backend

# Install dependencies
npm install

# Start development server (with auto-reload)
npm run dev

# Start production server
npm start

# Database operations
npm run db:migrate    # Run database migrations
npm run db:seed      # Seed database with initial data

# Run tests
npm test

# Kill processes on port 3000 (if needed)
lsof -ti:3000 | xargs kill -9
```

## Authentication Flow

The app uses a **two-step registration process**:

1. **Send Verification Code**: `POST /auth/send-verification-code` with email
2. **Register with Code**: `POST /auth/register` with email, password, name, and verification code

**Important**: In development mode, verification codes are displayed in backend console logs. Email delivery uses Aruba SMTP configured in backend `.env`.

## API Integration

- **Base URL**: `http://127.0.0.1:3000/api/v1` (configured for iOS simulator)
- **Authentication**: Bearer tokens in Authorization header
- **Error Handling**: Standardized error responses with codes and messages
- **Logging**: Extensive debug logging in both frontend and backend for development

### Key Endpoints
- `POST /auth/send-verification-code` - Send 6-digit email verification code
- `POST /auth/register` - Register with verification code
- `POST /auth/login` - User login
- `GET /auth/me` - Get current user
- `GET /memorials` - List memorials
- `POST /memorials` - Create memorial
- `POST /memorials/:id/like` - Toggle like/unlike for memorial
- `POST /memorials/:id/view` - Increment view count for memorial
- `GET /memorials/:id/stats` - Get memorial statistics (likes, views, comments)
- `POST /files/upload` - Upload multiple files (supports `memorial_id` parameter)
- `POST /files/upload-single` - Upload single file
- `DELETE /files/:id` - Delete file

## Data Models

### User Model
- Uses `int` ID (matches backend)
- `isVerified` boolean field (mapped from backend `is_verified`)
- JSON serialization with `@JsonKey` annotations for field mapping
- No longer includes deprecated `status` enum or `bio` fields

### Memorial Model
- Supports multiple image paths and URLs
- Includes relationship field for connection to deceased
- Date formatting utilities for birth/death dates
- Public/private visibility settings
- **Interactive features**: `likeCount` and `viewCount` fields for user engagement tracking
- **Critical**: Uses `@JsonKey` annotations for field mapping between frontend (camelCase) and backend (snake_case)
- **Field mappings**: `type` → `memorial_type`, `birthDate` → `birth_date`, `deathDate` → `death_date`, `isPublic` → `is_public`, `likeCount` → `like_count`, `viewCount` → `view_count`, etc.
- Has `toCreateJson()` method that excludes ID field for creation requests

## State Management Architecture

- **AuthProvider**: Manages user authentication state, login/logout, registration
- **MemorialProvider**: Handles memorial CRUD operations, filtering, and interactive features (likes/views)
  - **Auto-loading**: Automatically loads memorial data after successful login
  - **Interactive methods**: `toggleMemorialLike()` and `incrementMemorialViews()` update both backend and local state
  - **Real-time updates**: Uses `notifyListeners()` to update UI immediately after API calls
- **Provider Pattern**: Used throughout for reactive state updates

## Development Notes

### Network Configuration
- Backend must run on `127.0.0.1:3000` for iOS simulator connectivity
- Flutter ApiClient is pre-configured for this address
- Android emulator may require `10.0.2.2` instead

### Code Generation
After modifying any model classes with `@JsonSerializable()`, regenerate code:
```bash
dart run build_runner build --delete-conflicting-outputs
```

### Backend Dependencies
The backend requires PostgreSQL and Redis services running locally. Use the provided setup scripts for initialization.

### Email Verification
- Development: Verification codes shown in backend console
- Production: Emails sent via configured Aruba SMTP
- Codes expire after 5 minutes and are stored in Redis

### Image Handling
- Frontend: ImagePicker for selection, ImageHelper for compression, FileService for upload
- Backend: Multer for upload with file type validation, Sharp for thumbnail generation, local storage in `/uploads`
- **Important**: File upload supports `application/octet-stream` MIME type and uses file extension for type validation
- **Image compression**: flutter_image_compress automatically converts images to JPEG format during compression
- **File storage structure**: `/uploads/images/`, `/uploads/videos/`, `/uploads/audio/`, `/uploads/others/`

## Testing Strategy

- Frontend: Widget tests in `/test` directory
- Backend: Jest tests with supertest for API testing
- Manual Testing: Use iOS simulator with backend console for verification codes

## File Structure

### Critical Frontend Directories
- `/lib/models/` - Data models with JSON serialization (Memorial, User, FilterType)
- `/lib/services/` - API communication layer (ApiClient, AuthService, MemorialService, FileService, EmailService, FeedbackService)
- `/lib/providers/` - State management (AuthProvider, MemorialProvider)
- `/lib/pages/` - UI screens including glass-style pages (GlassHomePage, GlassCreatePage, GlassPersonalPage, DigitalLifePage, LoginPage, RegisterPage, etc.)
- `/lib/widgets/` - Reusable UI components with glass effects (GlassBottomNavigation, GlassMemorialCard, PhotoCarousel, StaggeredGridView, PlatformImage, etc.)
- `/lib/theme/` - Design system including glassmorphism_theme.dart and app_theme.dart
- `/lib/utils/` - Utilities (ImageHelper, FormValidators, ErrorHandler, UIHelpers)
- `/lib/config/` - Configuration files and constants

### Critical Backend Directories
- `/src/controllers/` - API endpoint handlers (authController, memorialController, fileController)
- `/src/models/` - Database models (User, Memorial, File)
- `/src/middleware/` - Authentication, validation, error handling, file upload (multer)
- `/src/services/` - Email service and external integrations
- `/src/routes/` - API route definitions

## Common Issues & Troubleshooting

### File Upload Issues
- **MIME Type Problems**: Backend accepts `application/octet-stream` and validates by file extension
- **Database Constraints**: File model allows `memorial_id` to be null for uploads before memorial creation
- **Image Compression**: flutter_image_compress may change MIME type; backend handles this gracefully
- **Field Mapping**: Backend returns `file_url` as `url` in API responses for frontend compatibility

### Model Synchronization
- Always run `dart run build_runner build --delete-conflicting-outputs` after modifying `@JsonSerializable` models
- Backend validation expects snake_case field names (use `@JsonKey` annotations for mapping)
- Memorial creation requires `toCreateJson()` method to exclude auto-generated ID field

### Authentication Issues
- Verification codes appear in backend console during development
- JWT tokens are managed by ApiClient singleton
- Login state persists across app restarts via SharedPreferences

### UI/Widget Issues
- **PhotoCarousel Navigation**: Use `IgnorePointer` to wrap overlay elements that might block navigation buttons
- **Hero Animations**: Memorial images use Hero widgets with tags like `memorial_image_${memorial.id}`
- **Hot Reload**: Press 'r' for hot reload, 'R' for hot restart during development
- **Provider Updates**: Always use `notifyListeners()` in Provider classes after state changes

### Interactive Features & User Engagement
- **Like System**: Uses backend Like model with unique constraint on (memorial_id, user_id)
- **View Tracking**: Automatically increments view count when opening memorial detail page
- **Real-time Updates**: Provider methods immediately update local state and call backend APIs
- **Error Handling**: Failed API calls show user-friendly error messages via SnackBar
- **State Persistence Issues**: If like button state doesn't persist after page refresh, check that `/memorials/:id/stats` route uses `optionalAuth` middleware and frontend service returns `response['data']['stats']`

### Development Workflow
- **Code Generation**: Run `dart run build_runner build --delete-conflicting-outputs` after modifying `@JsonSerializable` models
- **API Testing**: Backend runs on `127.0.0.1:3000` - use iOS simulator for best connectivity
- **Image Handling**: Images are compressed automatically and support both local paths and network URLs
- **State Management**: Use Provider.of<T>(context, listen: false) for actions, Consumer<T> for UI updates
- **Data Loading**: App automatically loads memorial data after user authentication, no manual refresh needed
- **BuildContext Safety**: Use local references for ScaffoldMessenger when crossing async gaps
- **Glassmorphism UI**: The app uses a custom glassmorphism theme with warm colors, blur effects, and gradient backgrounds

## Key Dependencies

### Main Dependencies
- **provider**: ^6.1.2 - State management
- **image_picker**: ^1.1.2 - Photo selection from gallery/camera
- **cached_network_image**: ^3.4.1 - Network image caching and display
- **flutter_image_compress**: ^2.3.0 - Image compression before upload
- **shared_preferences**: ^2.3.2 - Local data persistence
- **http**: ^1.2.2 - HTTP client for API requests
- **intl**: ^0.20.2 - Internationalization and date formatting
- **google_fonts**: ^6.2.1 - Custom font support
- **json_annotation**: ^4.9.0 - JSON serialization annotations
- **mailer**: ^6.1.2 - Email functionality
- **crypto**: ^3.0.5 - Cryptographic operations

### Development Dependencies
- **build_runner**: ^2.4.13 - Code generation runner
- **json_serializable**: ^6.8.0 - JSON serialization code generator
- **flutter_lints**: ^5.0.0 - Dart linting rules

## Critical Implementation Details

### API Response Handling & State Synchronization
- **Statistics API Fix**: Memorial stats API (`GET /memorials/:id/stats`) now correctly uses `optionalAuth` middleware to pass user authentication for proper `user_liked` state
- **Frontend Service Fix**: `getMemorialStats()` now correctly returns `response['data']['stats']` instead of `response['data']` to match backend response structure
- **Like State Management**: `toggleMemorialLikeWithResult()` method provides detailed API response including actual like counts and user state
- **NULL Value Handling**: Backend like/unlike operations handle NULL values in database by initializing counts before increment/decrement operations

### Interactive Features Implementation
- **Like System**: Memorial detail pages use `_checkLikeStatus()` on initialization to fetch user's current like state from backend
- **Real-time Updates**: Like button state updates immediately via `setState()` and persists across page refreshes through backend API calls
- **Statistics Tracking**: Memorial stats include `view_count`, `like_count`, `comment_count`, and `user_liked` fields for comprehensive user engagement tracking
- **State Persistence**: User like status is stored in backend database with unique constraints on (memorial_id, user_id) pairs

### Backend Authentication Architecture
- **Optional Authentication**: Routes like stats and memorial details use `optionalAuth` middleware to support both authenticated and anonymous access
- **JWT Token Management**: Tokens properly decoded with `userId` field for user identification in like/unlike operations
- **User Context**: `req.user?.id` pattern ensures graceful handling of both authenticated and anonymous requests

### Platform-Specific Network Configuration
```dart
static String get baseUrl {
  if (Platform.isAndroid) {
    return 'http://10.0.2.2:3000/api/v1';  // Android emulator
  } else {
    return 'http://127.0.0.1:3000/api/v1';  // iOS simulator
  }
}
```

### setState() Error Prevention
When working with widgets that trigger setState() during build phase (like BottomSheet selections), use these patterns:
- Extract callback logic to separate methods
- Use `mounted` checks before calling setState()
- For RadioListTile and similar widgets in forms, avoid direct setState() calls in onChanged callbacks

### Database Operations & Error Handling
- **Like Toggle Logic**: Backend properly handles NULL values by updating to 0 before increment/decrement operations
- **Sequelize Operations**: Uses `memorial.increment()`, `memorial.decrement()`, and `memorial.reload()` for atomic database updates
- **Error Recovery**: Frontend falls back to default states (`_isLiked = false`) when API calls fail

### Glassmorphism Theme Implementation
- Uses custom `GlassmorphismTheme` with gradient backgrounds
- Glass effect containers with blur and transparency
- Warm color palette with paper texture backgrounds
- Custom glass navigation components