---
inclusion: manual
---

# .env Copy-Paste Templates

## Quick Copy-Paste Options

### Option 1: Local Development (Default)
Copy and paste this into your `.env` file:

```
API_URL=http://localhost:8080
APP_NAME=Attendance Management
APP_VERSION=1.0.0
```

### Option 2: Android Emulator
Copy and paste this into your `.env` file:

```
API_URL=http://10.0.2.2:8080
APP_NAME=Attendance Management
APP_VERSION=1.0.0
```

### Option 3: Physical Device
Replace `192.168.1.100` with your machine's IP, then copy and paste:

```
API_URL=http://192.168.1.100:8080
APP_NAME=Attendance Management
APP_VERSION=1.0.0
```

### Option 4: Production (Azure)
Copy and paste this into your `.env` file:

```
API_URL=https://ams-bpcac7gvb5cnhtdt.southeastasia-01.azurewebsites.net
APP_NAME=Attendance Management
APP_VERSION=1.0.0
```

## Steps to Use

1. Open `.env` file in your project root
2. Delete all content
3. Copy one of the options above
4. Paste it into `.env`
5. Save the file
6. Run these commands:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

## Finding Your Machine IP

### Windows
Open Command Prompt and run:
```
ipconfig
```
Look for "IPv4 Address" (usually starts with 192.168 or 10.0)

### Mac/Linux
Open Terminal and run:
```
ifconfig
```
Look for "inet" address

## Test Credentials

```
Username: admin@attendance.com
Password: Admin@123!
```

## Verify Connection

After rebuilding, check the console for:
```
🚀 AppConfig Initialization:
   - Base URL: http://localhost:8080
```

The URL should match your `.env` configuration.
