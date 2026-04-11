---
inclusion: manual
---

# Responsive Design Guide

Your Flutter app now has comprehensive responsive design support for all device sizes.

## Quick Start

### 1. Import the Responsive Utility
```dart
import '../utils/responsive.dart';
```

### 2. Use Responsive Values

#### Padding
```dart
// Automatically scales based on device size
padding: Responsive.padding(context),
padding: Responsive.paddingHorizontal(context),
padding: Responsive.paddingVertical(context),
```

#### Font Sizes
```dart
// Heading (mobile: 24, tablet: 28, desktop: 32)
fontSize: Responsive.headingFontSize(context),

// Body text (mobile: 14, tablet: 16, desktop: 18)
fontSize: Responsive.fontSize(context),

// Custom sizes
fontSize: Responsive.fontSize(context, mobile: 12, tablet: 14, desktop: 16),
```

#### Spacing
```dart
// Responsive spacing between elements
SizedBox(height: Responsive.spacing(context)),
```

#### Grid Columns
```dart
// Automatically adjusts: mobile=2, tablet=3, desktop=4
GridView.count(
  crossAxisCount: Responsive.gridColumns(context),
  ...
)
```

#### Button Height
```dart
// Scales based on device: mobile=44, tablet=48, desktop=52
height: Responsive.buttonHeight(context),
```

#### Icon Size
```dart
// Responsive icons: mobile=20, tablet=24, desktop=28
size: Responsive.iconSize(context),
```

#### Border Radius
```dart
// Responsive corners: mobile=12, tablet=16, desktop=20
borderRadius: BorderRadius.circular(Responsive.borderRadius(context)),
```

## Device Detection

```dart
// Check device type
if (Responsive.isMobile(context)) {
  // Mobile-specific layout
}

if (Responsive.isTablet(context)) {
  // Tablet-specific layout
}

if (Responsive.isDesktop(context)) {
  // Desktop-specific layout
}

// Get screen dimensions
double width = Responsive.width(context);
double height = Responsive.height(context);
```

## Breakpoints

- **Mobile**: < 600px
- **Tablet**: 600px - 900px
- **Desktop**: ≥ 900px

## Responsive Widgets

### ResponsiveContainer
Automatically centers content and constrains max width:
```dart
ResponsiveContainer(
  child: YourWidget(),
  padding: Responsive.padding(context),
)
```

### ResponsiveGrid
Automatically adjusts columns:
```dart
ResponsiveGrid(
  children: [
    CardWidget(),
    CardWidget(),
    CardWidget(),
  ],
  spacing: 16,
)
```

### ResponsiveText
Scales text automatically:
```dart
ResponsiveText(
  'Hello World',
  mobileSize: 14,
  tabletSize: 16,
  desktopSize: 18,
)
```

### ResponsiveButton
Scales button size:
```dart
ResponsiveButton(
  label: 'Click Me',
  onPressed: () {},
  icon: Icons.check,
)
```

## Best Practices

1. **Always use Responsive for sizing** - Never hardcode pixel values
2. **Test on multiple devices** - Use Flutter device emulators
3. **Use SafeArea** - Protects from notches and system UI
4. **Flexible layouts** - Use Expanded, Flexible, and LayoutBuilder
5. **Orientation handling** - Consider landscape mode

## Example: Responsive Dashboard

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: ResponsiveContainer(
      child: SingleChildScrollView(
        padding: Responsive.padding(context),
        child: Column(
          children: [
            Text(
              'Dashboard',
              style: TextStyle(
                fontSize: Responsive.headingFontSize(context),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: Responsive.spacing(context, mobile: 16, tablet: 20, desktop: 24)),
            ResponsiveGrid(
              children: [
                StatCard(title: 'Users', value: '100'),
                StatCard(title: 'Revenue', value: '\$5000'),
                StatCard(title: 'Orders', value: '250'),
                StatCard(title: 'Growth', value: '+15%'),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
```

## Testing Responsive Design

1. **Mobile** (360x640): iPhone SE, Pixel 4a
2. **Tablet** (768x1024): iPad, Pixel Tablet
3. **Desktop** (1920x1080): Web, Desktop

Use Flutter DevTools to test different screen sizes:
```bash
flutter run -d chrome  # Web
flutter run -d emulator-5554  # Android
```

## Common Patterns

### Responsive Padding
```dart
padding: Responsive.paddingHorizontal(context).copyWith(
  top: Responsive.spacing(context),
  bottom: Responsive.spacing(context),
)
```

### Conditional Layouts
```dart
if (Responsive.isMobile(context)) {
  // Single column layout
} else if (Responsive.isTablet(context)) {
  // Two column layout
} else {
  // Three+ column layout
}
```

### Responsive Images
```dart
Image.asset(
  'assets/image.png',
  width: Responsive.width(context) * 0.8,
  fit: BoxFit.cover,
)
```

## Troubleshooting

**Issue**: Text overflowing on small screens
**Solution**: Use `Responsive.fontSize()` and `maxLines` property

**Issue**: Buttons too small on tablets
**Solution**: Use `Responsive.buttonHeight()` for consistent sizing

**Issue**: Grid items too cramped
**Solution**: Adjust `Responsive.gridColumns()` or increase spacing

For more help, check the Responsive utility class in `lib/utils/responsive.dart`
