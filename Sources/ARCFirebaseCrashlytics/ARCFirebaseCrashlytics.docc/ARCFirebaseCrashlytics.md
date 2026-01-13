# ``ARCFirebaseCrashlytics``

Firebase Crashlytics integration for crash reporting and error tracking.

## Overview

ARCFirebaseCrashlytics provides a simple interface to Firebase Crashlytics for tracking crashes, non-fatal errors, and custom logs.

## Key Features

- **Crash reporting**: Automatic crash detection and reporting
- **Non-fatal errors**: Track handled exceptions
- **Custom logs**: Add context to crash reports
- **User identification**: Associate crashes with users

## Topics

### Getting Started

- <doc:CrashReportingGuide>

### Error Recording

- ``CrashlyticsManager``
- ``CrashlyticsManager/record(error:)``
- ``CrashlyticsManager/recordNonFatal(error:)``

### Custom Logging

- ``CrashlyticsManager/log(_:)``

### User Context

- ``CrashlyticsManager/setUserID(_:)``
- ``CrashlyticsManager/setCustomValue(_:forKey:)``
