# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Eteria (永念) is a memorial app with a Flutter frontend and Node.js backend that allows users to create digital memorial spaces for deceased loved ones. The app features user authentication with email verification, memorial management, photo uploads, and social interactions.

**Current Status**: The app includes a fully functional Flutter frontend with Provider state management, custom UI components, and integration with a Node.js backend. Key features implemented include waterfall grid layout, memorial creation/viewing, photo upload, authentication flow, and detailed memorial pages with interactive elements.

## Architecture

### Flutter Frontend (Main Repository)
- **Framework**: Flutter 3.9.0+ with Material Design 3
- **State Management**: Provider pattern with AuthProvider and MemorialProvider
- **API Communication**: Singleton ApiClient with JWT token management at `http://127.0.0.1:3000/api/v1`
- **Data Persistence**: SharedPreferences for user sessions and local storage
- **Image Handling**: ImagePicker for selection, flutter_image_compress for optimization, platform_image widget for unified display
- **Code Generation**: JSON serialization using build_runner and json_serializable
- **UI Components**: Custom widgets including PhotoCarousel, StaggeredGridView, CompactMemorialCard
- **Navigation**: Material app router with Hero animations for smooth transitions

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

# Database setup
./scripts/setup-db.sh
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
- **Critical**: Uses `@JsonKey` annotations for field mapping between frontend (camelCase) and backend (snake_case)
- **Field mappings**: `type` → `memorial_type`, `birthDate` → `birth_date`, `deathDate` → `death_date`, `isPublic` → `is_public`, etc.
- Has `toCreateJson()` method that excludes ID field for creation requests

## State Management Architecture

- **AuthProvider**: Manages user authentication state, login/logout, registration
- **MemorialProvider**: Handles memorial CRUD operations and filtering
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
- `/lib/services/` - API communication layer (ApiClient, AuthService, MemorialService, FileService, EmailService)
- `/lib/providers/` - State management (AuthProvider, MemorialProvider)
- `/lib/pages/` - UI screens (LoginPage, RegisterPage, HomePage, CreatePage, MemorialDetailPage, ProfilePage, etc.)
- `/lib/widgets/` - Reusable UI components (PhotoCarousel, CompactMemorialCard, StaggeredGridView, PlatformImage, etc.)
- `/lib/theme/` - Design system and theming (AppTheme with Material Design 3)
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

### Development Workflow
- **Code Generation**: Run `dart run build_runner build --delete-conflicting-outputs` after modifying `@JsonSerializable` models
- **API Testing**: Backend runs on `127.0.0.1:3000` - use iOS simulator for best connectivity
- **Image Handling**: Images are compressed automatically and support both local paths and network URLs
- **State Management**: Use Provider.of<T>(context, listen: false) for actions, Consumer<T> for UI updates