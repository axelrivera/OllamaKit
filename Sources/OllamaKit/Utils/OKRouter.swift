//
//  OKRouter.swift
//
//
//  Created by Kevin Hermawan on 10/11/23.
//

import Foundation

internal enum OKRouter {
    case root
    case models
    case modelInfo(data: OKModelInfoRequestData)
    case generate(data: OKGenerateRequestData)
    case chat(data: OKChatRequestData)
    case copyModel(data: OKCopyModelRequestData)
    case deleteModel(data: OKDeleteModelRequestData)
    case pullModel(data: OKPullModelRequestData)
    case embeddings(data: OKEmbeddingsRequestData)
    
    internal var path: String {
        switch self {
        case .root:
            return "/"
        case .models:
            return "/api/tags"
        case .modelInfo:
            return "/api/show"
        case .generate:
            return "/api/generate"
        case .chat:
            return "/api/chat"
        case .copyModel:
            return "/api/copy"
        case .deleteModel:
            return "/api/delete"
        case .pullModel:
            return "/api/pull"
        case .embeddings:
            return "/api/embeddings"
        }
    }
    
    internal var method: String {
        switch self {
        case .root:
            return "HEAD"
        case .models:
            return "GET"
        case .modelInfo:
            return "POST"
        case .generate:
            return "POST"
        case .chat:
            return "POST"
        case .copyModel:
            return "POST"
        case .deleteModel:
            return "DELETE"
        case .pullModel:
            return "POST"
        case .embeddings:
            return "POST"
        }
    }
    
    internal var headers: [String: String] {
        ["Content-Type": "application/json"]
    }
}

extension OKRouter {
    func asURLRequest(with baseURL: URL, authToken: String? = nil) throws -> URLRequest {
        let config = OKRouterConfig(baseURL: baseURL, authToken: authToken)
        return try asURLRequest(with: config)
    }
    
    func asURLRequest(with config: OKRouterConfig) throws -> URLRequest {
        let url = config.baseURL.appendingPathComponent(path)
        
        var headers = self.headers
        if let authToken = config.authToken, !authToken.isEmpty {
            headers["Authorization"] = "Bearer \(authToken)"
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.allHTTPHeaderFields = headers
        
        switch self {
        case .modelInfo(let data):
            request.httpBody = try JSONEncoder.default.encode(data)
        case .generate(let data):
            request.httpBody = try JSONEncoder.default.encode(data)
        case .chat(let data):
            request.httpBody = try JSONEncoder.default.encode(data)
        case .copyModel(let data):
            request.httpBody = try JSONEncoder.default.encode(data)
        case .deleteModel(let data):
            request.httpBody = try JSONEncoder.default.encode(data)
        case .pullModel(let data):
            request.httpBody = try JSONEncoder.default.encode(data)
        case .embeddings(let data):
            request.httpBody = try JSONEncoder.default.encode(data)
        default:
            break
        }
        
        return request
    }
}

struct OKRouterConfig {
    let baseURL: URL
    let authToken: String?
    
    init(baseURL: URL, authToken: String? = nil) {
        self.baseURL = baseURL
        self.authToken = authToken
    }
}
