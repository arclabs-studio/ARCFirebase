# Getting Started with ARCFirebaseAI

Set up Firebase AI content generation in your app.

## Prerequisites

1. A Firebase project with the Gemini API enabled
2. `GoogleService-Info.plist` added to your app target
3. Firebase configured at app launch via ``FirebaseManager/configure()``

## Setup

### 1. Import the Module

```swift
import ARCFirebaseAI
```

### 2. Configure in Your App

```swift
@main
struct MyApp: App {
    let ai = FirebaseAIProvider.live

    init() {
        FirebaseManager.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.aiProvider, ai)
        }
    }
}
```

### 3. Use in Views

```swift
struct ChatView: View {
    @Environment(\.aiProvider) var ai
    @State private var response = ""

    var body: some View {
        VStack {
            Text(response)
            Button("Generate") {
                Task {
                    let result = try await ai.generateContent(
                        prompt: "Suggest a restaurant"
                    )
                    response = result.content
                }
            }
        }
    }
}
```

## Basic Usage

### Simple Generation

```swift
let response = try await ai.generateContent(prompt: "Hello")
print(response.content)
```

### With System Instruction

```swift
let response = try await ai.generateContent(
    prompt: "Describe this dish",
    systemInstruction: "You are a knowledgeable food critic"
)
```

### Configuration Presets

```swift
// Creative writing
let response = try await ai.generateContent(
    prompt: "Write a restaurant review",
    configuration: .creative
)

// Factual answers
let response = try await ai.generateContent(
    prompt: "What is umami?",
    configuration: .factual
)
```

## Streaming

Display content as it's generated:

```swift
for try await chunk in ai.streamContent(prompt: "Tell me about sushi") {
    text += chunk
}
```

## Structured Output

Extract structured data using Firebase's `Schema` type:

```swift
import FirebaseAI

let schema = Schema.object(properties: [
    "name": .string(),
    "rating": .integer(),
    "cuisine": .string()
])

let response = try await ai.generateStructuredContent(
    prompt: "Extract info: 'Osteria Francescana is a 3-star Italian restaurant'",
    responseSchema: schema,
    configuration: .structured
)
// response.content contains JSON matching the schema
```

## Multi-Turn Chat

Maintain conversation context:

```swift
var history: [AIMessage] = []

// First turn
let response1 = try await ai.sendMessage(
    "What's a good Italian restaurant?",
    history: history
)
history.append(AIMessage(role: .user, content: "What's a good Italian restaurant?"))
history.append(AIMessage(role: .model, content: response1.content))

// Second turn (model remembers context)
let response2 = try await ai.sendMessage(
    "What about Japanese?",
    history: history
)
```

## Dependency Injection

Use ``AIProviding`` for testable ViewModels:

```swift
@Observable
final class ChatViewModel {
    private let ai: any AIProviding
    var response: String = ""

    init(ai: any AIProviding) {
        self.ai = ai
    }

    func generate(prompt: String) async throws {
        let result = try await ai.generateContent(prompt: prompt)
        response = result.content
    }
}

// Production
let viewModel = ChatViewModel(ai: FirebaseAIProvider.live)

// Testing
let viewModel = ChatViewModel(ai: MockAIProvider())
```
