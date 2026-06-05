import 'package:flutter/material.dart';
import 'package:lesson_flutter/theme/theme_provider.dart';
import 'package:provider/provider.dart';

/// Animated sun/moon sliding toggle button shown in the AppBar.
class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode(context);

    return GestureDetector(
      onTap: () => themeProvider.toggleTheme(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: 52,
        height: 28,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: isDark ? const Color(0xFF4A7C59) : Colors.grey.shade300,
        ),
        child: Stack(
          children: [
            // Track icons
            Positioned(
              left: 6,
              top: 0,
              bottom: 0,
              child: Center(
                child: Icon(
                  Icons.dark_mode,
                  size: 14,
                  color: isDark ? Colors.white70 : Colors.transparent,
                ),
              ),
            ),
            Positioned(
              right: 6,
              top: 0,
              bottom: 0,
              child: Center(
                child: Icon(
                  Icons.light_mode,
                  size: 14,
                  color: isDark ? Colors.transparent : Colors.orange.shade600,
                ),
              ),
            ),
            // Sliding thumb
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              top: 3,
              left: isDark ? 27 : 3,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Icon(
                  isDark ? Icons.dark_mode : Icons.light_mode,
                  size: 12,
                  color: isDark ? const Color(0xFF4A7C59) : Colors.orange.shade600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Alternative: Theme Switch with Text
class ThemeSwitchTile extends StatelessWidget {
  const ThemeSwitchTile({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode(context);

    return SwitchListTile(
      title: const Text('Dark Mode'),
      subtitle: Text(isDark ? 'Enabled' : 'Disabled'),
      value: isDark,
      onChanged: (value) {
        themeProvider.toggleTheme();
      },
      secondary: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
    );
  }
}

// Theme Mode Selector (Light, Dark, System)
class ThemeModeSelector extends StatelessWidget {
  const ThemeModeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Theme Mode',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        RadioListTile<ThemeMode>(
          title: const Text('Light'),
          subtitle: const Text('Always use light theme'),
          value: ThemeMode.light,
          groupValue: themeProvider.themeMode,
          onChanged: (value) {
            if (value != null) {
              themeProvider.setThemeMode(value);
            }
          },
          secondary: const Icon(Icons.light_mode),
        ),
        RadioListTile<ThemeMode>(
          title: const Text('Dark'),
          subtitle: const Text('Always use dark theme'),
          value: ThemeMode.dark,
          groupValue: themeProvider.themeMode,
          onChanged: (value) {
            if (value != null) {
              themeProvider.setThemeMode(value);
            }
          },
          secondary: const Icon(Icons.dark_mode),
        ),
        RadioListTile<ThemeMode>(
          title: const Text('System'),
          subtitle: const Text('Follow system settings'),
          value: ThemeMode.system,
          groupValue: themeProvider.themeMode,
          onChanged: (value) {
            if (value != null) {
              themeProvider.setThemeMode(value);
            }
          },
          secondary: const Icon(Icons.brightness_auto),
        ),
      ],
    );
  }
}
