# ``ARCFirebaseAI``

Integrate Google Gemini AI through Firebase AI Logic for content generation, streaming, and multi-turn chat.

## Overview

ARCFirebaseAI provides a protocol-based abstraction over Firebase AI (Gemini), enabling AI content generation with full testability through dependency injection.

Firebase proxies the Gemini API so API keys never touch the iOS client. The module follows the same Protocol + Provider + EnvironmentKey pattern as other ARCFirebase modules.

## Topics

### Protocol

- ``AIProviding``

### Provider

- ``FirebaseAIProvider``

### Models

- ``AIConfiguration``
- ``AIResponse``
- ``AIMessage``

### SwiftUI Integration

- ``AIProviderKey``

### Getting Started

- <doc:GettingStarted>
