//
//  OllamaKit+Chat.swift
//
//
//  Created by Kevin Hermawan on 02/01/24.
//

import Combine
import Foundation

extension OllamaKit {
    /// Establishes an asynchronous stream for chat responses from the Ollama API, based on the provided data.
    ///
    /// This method sets up a streaming connection using Swift's concurrency features, allowing for real-time data handling as chat responses are generated by the Ollama API.
    ///
    /// Example usage
    ///
    /// ```swift
    /// let ollamaKit = OllamaKit()
    /// let chatData = OKChatRequestData(/* parameters */)
    ///
    /// Task {
    ///     do {
    ///         for try await response in ollamaKit.chat(data: chatData) {
    ///             // Handle each chat response
    ///         }
    ///     } catch {
    ///         // Handle error
    ///     }
    /// }
    /// ```
    ///
    ///  Example usage with tools
    ///
    /// ```swift
    /// let ollamaKit = OllamaKit()
    /// let chatData = OKChatRequestData(
    ///     /* parameters */,
    ///     tools: [
    ///         .object([
    ///             "type": .string("function"),
    ///             "function": .object([
    ///                 "name": .string("get_current_weather"),
    ///                 "description": .string("Get the current weather for a location"),
    ///                 "parameters": .object([
    ///                     "type": .string("object"),
    ///                     "properties": .object([
    ///                         "location": .object([
    ///                             "type": .string("string"),
    ///                             "description": .string("The location to get the weather for, e.g. San Francisco, CA")
    ///                         ]),
    ///                         "format": .object([
    ///                             "type": .string("string"),
    ///                             "description": .string("The format to return the weather in, e.g. 'celsius' or 'fahrenheit'"),
    ///                             "enum": .array([.string("celsius"), .string("fahrenheit")])
    ///                         ])
    ///                     ]),
    ///                     "required": .array([.string("location"), .string("format")])
    ///                 ])
    ///             ])
    ///         ])
    ///     ]
    /// )
    ///
    /// Task {
    ///     do {
    ///         for try await response in ollamaKit.chat(data: chatData) {
    ///             if let toolCalls = response.message?.toolCalls {
    ///                 for toolCall in toolCalls {
    ///                     if let function = toolCall.function {
    ///                         print("Tool called: \(function.name ?? "")")
    ///
    ///                         if let arguments = function.arguments {
    ///                             switch arguments {
    ///                             case .object(let argDict):
    ///                                 if let location = argDict["location"], case .string(let locationValue) = location {
    ///                                     print("Location: \(locationValue)")
    ///                                 }
    ///
    ///                                 if let format = argDict["format"], case .string(let formatValue) = format {
    ///                                     print("Format: \(formatValue)")
    ///                                 }
    ///                             default:
    ///                                 print("Unexpected arguments format")
    ///                             }
    ///                         } else {
    ///                             print("No arguments provided")
    ///                         }
    ///                     }
    ///                 }
    ///             }
    ///         }
    ///     } catch {
    ///         // Handle error
    ///     }
    /// }
    /// ```
    ///
    /// - Parameter data: The ``OKChatRequestData`` used to initiate the chat streaming from the Ollama API.
    /// - Returns: An `AsyncThrowingStream<OKChatResponse, Error>` emitting the live stream of chat responses from the Ollama API.
    public func chat(data: OKChatRequestData) -> AsyncThrowingStream<OKChatResponse, Error> {
        do {
            let request = try OKRouter.chat(data: data).asURLRequest(with: routerConfig())

            return OKHTTPClient.shared.stream(request: request, with: OKChatResponse.self)
        } catch {
            return AsyncThrowingStream { continuation in
                continuation.finish(throwing: error)
            }
        }
    }
    
    /// Establishes a Combine publisher for streaming chat responses from the Ollama API, based on the provided data.
    ///
    /// This method sets up a streaming connection using the Combine framework, facilitating real-time data handling as chat responses are generated by the Ollama API.
    ///
    /// Example usage
    ///
    /// ```swift
    /// let ollamaKit = OllamaKit()
    /// let chatData = OKChatRequestData(/* parameters */)
    ///
    /// ollamaKit.chat(data: chatData)
    ///     .sink(receiveCompletion: { completion in
    ///         // Handle completion or error
    ///     }, receiveValue: { chatResponse in
    ///         // Handle each chat response
    ///     })
    ///     .store(in: &cancellables)
    /// ```
    ///
    /// Example usage with tools
    ///
    /// ```swift
    /// let ollamaKit = OllamaKit()
    /// let chatData = OKChatRequestData(
    ///     /* parameters */,
    ///     tools: [
    ///         .object([
    ///             "type": .string("function"),
    ///             "function": .object([
    ///                 "name": .string("get_current_weather"),
    ///                 "description": .string("Get the current weather for a location"),
    ///                 "parameters": .object([
    ///                     "type": .string("object"),
    ///                     "properties": .object([
    ///                         "location": .object([
    ///                             "type": .string("string"),
    ///                             "description": .string("The location to get the weather for, e.g. San Francisco, CA")
    ///                         ]),
    ///                         "format": .object([
    ///                             "type": .string("string"),
    ///                             "description": .string("The format to return the weather in, e.g. 'celsius' or 'fahrenheit'"),
    ///                             "enum": .array([.string("celsius"), .string("fahrenheit")])
    ///                         ])
    ///                     ]),
    ///                     "required": .array([.string("location"), .string("format")])
    ///                 ])
    ///             ])
    ///         ])
    ///     ]
    /// )
    ///
    /// ollamaKit.chat(data: chatData)
    ///     .sink(receiveCompletion: { completion in
    ///         // Handle completion or error
    ///     }, receiveValue: { chatResponse in
    ///         if let toolCalls = chatResponse.message?.toolCalls {
    ///             for toolCall in toolCalls {
    ///                 if let function = toolCall.function {
    ///                     print("Tool called: \(function.name ?? "")")
    ///
    ///                     if let arguments = function.arguments {
    ///                         switch arguments {
    ///                         case .object(let argDict):
    ///                             if let location = argDict["location"], case .string(let locationValue) = location {
    ///                                 print("Location: \(locationValue)")
    ///                             }
    ///
    ///                             if let format = argDict["format"], case .string(let formatValue) = format {
    ///                                 print("Format: \(formatValue)")
    ///                             }
    ///                         default:
    ///                             print("Unexpected arguments format")
    ///                         }
    ///                     } else {
    ///                         print("No arguments provided")
    ///                     }
    ///                 }
    ///             }
    ///         }
    ///     })
    ///     .store(in: &cancellables)
    /// ```
    ///
    /// - Parameter data: The ``OKChatRequestData`` used to initiate the chat streaming from the Ollama API.
    /// - Returns: An `AnyPublisher<OKChatResponse, Error>` emitting the live stream of chat responses from the Ollama API.
    public func chat(data: OKChatRequestData) -> AnyPublisher<OKChatResponse, Error> {
        do {
            let request = try OKRouter.chat(data: data).asURLRequest(with: routerConfig())

            return OKHTTPClient.shared.stream(request: request, with: OKChatResponse.self)
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
    }
}
