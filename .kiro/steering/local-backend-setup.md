---
inclusion: manual
---

# Local Backend Setup Guide

This guide explains how to configure your Flutter app to connect to a local backend server for development.

## Quick Start

### 1. Update .env File

The `.env` file in your project root controls which backend the app connects to:

```env
# Local Development (localhost)
API_URL=http://localhost:8080

# Physical Device/Emulator (replace with your machine IP)
# API_URL=http://192.168.x.x:8080

# Production (Azure Backend)
# API_URL=https://ams-bpcac7gvb5cnhtdt.southeastasia-01.azurewebsites.net
```

### 2. Rebuild Flutter App

After updating `.env`, rebuild the app:

```bash
flutter clean
flutter pub get
flutter run
```

## Configuration Options

### Option 1: Local Development (Localhost)

**For running on Android Emulator or Web:**

```env
API_URL=http://localhost:8080
```

**For Android Emulator specifically:**
- Android emulator sees `localhost` as the emulator itself
- Use `http://10.0.2.2:8080` to reach your host machine

```env
API_URL=http://10.0.2.2:8080
```

### Option 2: Physical Device/Emulator with Machine IP

**For physical devices or when localhost doesn't work:**

1. Find your machine's IP address:
   - **Windows**: `ipconfig` (look for IPv4 Address)
   - **Mac/Linux**: `ifconfig` (look for inet)

2. Update `.env`:
```env
API_URL=http://192.168.x.x:8080
```

Replace `192.168.x.x` with your actual IP address.

### Option 3: Production (Azure Backend)

```env
API_URL=https://ams-bpcac7gvb5cnhtdt.southeastasia-01.azurewebsites.net
```

## Testing Different Backends

### Test with Production Backend
```env
API_URL=https://ams-bpcac7gvb5cnhtdt.southeastasia-01.azurewebsites.net
```

Then:
```bash
flutter clean
flutter pub get
flutter run
```

### Test with Local Backend
```env
API_URL=http://localhost:8080
```

Then:
```bash
flutter clean
flutter pub get
flutter run
```

## Troubleshooting

### Connection Refused
- **Problem**: "Failed to connect to server"
- **Solution**: Make sure your backend server is running on the specified port

### Timeout Errors
- **Problem**: "Connection timeout"
- **Solution**: 
  - Check if backend is running
  - Verify the IP address is correct
  - Check firewall settings

### Wrong IP Address
- **Problem**: App can't reach backend
- **Solution**:
  - Verify your machine IP with `ipconfig` (Windows) or `ifconfig` (Mac/Linux)
  - Make sure device is on same network
  - Try using `localhost` if on same machine

### Android Emulator Issues
- **Problem**: Can't connect to localhost
- **Solution**: Use `http://10.0.2.2:8080` instead of `http://localhost:8080`

## How It Works

1. **flutter_dotenv** loads the `.env` file at app startup
2. **AppConfig** reads the `API_URL` from environment variables
3. **ApiService** uses this URL for all API calls
4. No code changes needed - just update `.env` and rebuild

## Environment Variables

The app supports these environment variables in `.env`:

```env
# Required
API_URL=http://localhost:8080

# Optional
APP_NAME=Attendance Management
APP_VERSION=1.0.0
```

## Common Scenarios

### Scenario 1: Local Development on Same Machine
```env
API_URL=http://localhost:8080
```
- Backend running on your machine
- Flutter app running on emulator/device on same machine

### Scenario 2: Development on Physical Device
```env
API_URL=http://192.168.1.100:8080
```
- Backend running on your machine (192.168.1.100)
- Flutter app running on physical device on same network

### Scenario 3: Production Testing
```env
API_URL=https://ams-bpcac7gvb5cnhtdt.southeastasia-01.azurewebsites.net
```
- Backend running on Azure
- Flutter app connecting to production server

## Verifying Connection

After updating `.env` and rebuilding:

1. Open the app
2. Try to login with test credentials
3. Check console logs for API URL being used
4. Look for messages like: "📤 Logging in: http://localhost:8080/api/account/login"

## Important Notes

- **Always rebuild** after changing `.env` (flutter clean && flutter pub get)
- **Don't commit sensitive URLs** - use `.env` for local development
- **Test both backends** before deploying
- **Check firewall** if connection fails
- **Verify backend is running** before testing

## Quick Commands

```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run

# Run on specific device
flutter run -d <device-id>

# Run with verbose logging
flutter run -v

# Check available devices
flutter devices
```

## References

- [flutter_dotenv documentation](https://pub.dev/packages/flutter_dotenv)
- [AppConfig implementation](../lib/config/app_config.dart)
- [ApiService implementation](../lib/services/api_service.dart)
