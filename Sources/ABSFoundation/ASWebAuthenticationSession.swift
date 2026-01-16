//
//  ASWebAuthenticationSession.swift
//  angry-boat-swift
//
//  Created by Maddie Schipper on 1/16/26.
//

import Foundation
import AuthenticationServices

public struct WebAuthenticationSessionError : LocalizedError, Sendable {
    public let message: String
    
    public var errorDescription: String? { self.message }
}

extension ASWebAuthenticationSession {
    @MainActor
    public static func authorize(url: URL, callbackScheme: String, prefersEphemeralWebBrowserSession: Bool = false, providerContext: ASWebAuthenticationPresentationContextProviding? = nil) async throws -> URL {
        
        return try await withCheckedThrowingContinuation { continuation in
            let context = providerContext ?? WebAuthenticationSessionContextProvider()
           
            var session: ASWebAuthenticationSession!
            session = ASWebAuthenticationSession(url: url, callbackURLScheme: callbackScheme) { callbackURL, error in
                withExtendedLifetime((context, session)) {
                    // Callback happens on arbitrary queue
                    // get back to the main queue before resuming the continuation
                    DispatchQueue.main.async {
                        if let error {
                            continuation.resume(throwing: error)
                        } else if let callbackURL {
                            continuation.resume(returning: callbackURL)
                        } else {
                            let error = WebAuthenticationSessionError(message: String(
                                    localized: "WebAuthenticationSessionError.invalidCallbackState",
                                    defaultValue: "Invalid Callback State"
                                )
                            )
                            continuation.resume(throwing: error)
                        }
                    }
                }
            }
            
            session.presentationContextProvider = context
            session.prefersEphemeralWebBrowserSession = prefersEphemeralWebBrowserSession
            
            guard session.canStart else {
                let error = WebAuthenticationSessionError(message: String(
                        localized: "WebAuthenticationSessionError.cannotStart",
                        defaultValue: "Cannot Start")
                )
                continuation.resume(throwing: error)
                return
            }
            
            
            if session.start() {
                return
            }
            
            let error = WebAuthenticationSessionError(message: String(
                localized: "WebAuthenticationSessionError.startFailed",
                defaultValue: "Failed to start web authentication session")
            )
            
            continuation.resume(throwing: error)
        }
    }
}

fileprivate class WebAuthenticationSessionContextProvider : NSObject, ASWebAuthenticationPresentationContextProviding {
    
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        #if os(macOS)
        if let keyWindow = NSApplication.shared.keyWindow {
            return keyWindow
        }
        return ASPresentationAnchor()
        #elseif os(iOS)
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            if let keyWindow = scene.windows.first(where: \.isKeyWindow) {
                return keyWindow
            }
            return ASPresentationAnchor(windowScene: scene)
        }
        return ASPresentationAnchor()
        #else
        return ASPresentationAnchor()
        #endif
    }
}
