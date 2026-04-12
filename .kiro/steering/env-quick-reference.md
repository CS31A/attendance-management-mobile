---
inclusion: manual
---

# .env Quick Reference

## Current Configuration

Your `.env` file is located at the project root (same level as `pubspec.yaml`).

## Available Options

### 1. Local Development (Default)
```env
API_URL=http://localhost:8080
```
✅ Use this for local backend testing

### 2. Android Emulator
```env
API_URL=http://10.0.2.2:8080
```
✅ Use this when running on Android emulator

### 3. Physical Device (Replace IP)
```env
API_URL=http://192.168.x.x:8080
```
✅ Replace `192.168.x.x` with your machine's IP

### 4. Production (Azure)
```env
API_URL=https://ams-bpcac7gvb5cnhtdt.southeastasia-01.azurewebsites.net
```
✅ Use this for production testing

## How to Switch Backends

1. **Edit `.env` file** - Change the `API_URL` value
2. **Save the file**
3. **Run these commands:**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

## Verify It's Working

After rebuilding, check the console output:
```
🚀 AppConfig Initialization:
   - Base URL: http://localhost:8080
   - App Name: Attendance Management
   - Version: 1.0.0
```

The URL shown should match your `.env` configuration.

## Test Credentials

```
Username: admin@attendance.com
Password: Admin@123!
```

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Connection refused | Make sure backend is running on the port |
| Timeout | Check if backend is responding |
| Wrong URL in logs | Did you run `flutter clean`? |
| Still using old URL | Delete build folder: `rm -rf build/` |

## Important

⚠️ **Always run `flutter clean` after changing `.env`**

The app caches environment variables at build time, so changes won't take effect without a clean rebuild.
