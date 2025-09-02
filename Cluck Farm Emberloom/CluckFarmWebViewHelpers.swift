import Foundation
import WebKit
import SwiftUI

// MARK: - Implementation Implementation Implementation WebView

class CluckFarmWebViewConfigurationBuilder {
    static func createAdvancedConfiguration() -> WKWebViewConfiguration {
        let config = WKWebViewConfiguration()
        config.websiteDataStore = .default()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        config.suppressesIncrementalRendering = false
        config.processPool = WKProcessPool()
        
        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = true
        config.defaultWebpagePreferences = preferences
        
        return config
    }
    
    static func configureWebViewForCluckFarm(_ webView: WKWebView) {
        webView.isOpaque = false
        webView.scrollView.bounces = false
        webView.scrollView.isScrollEnabled = true
        webView.allowsBackForwardNavigationGestures = true
        
        webView.configuration.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
        webView.configuration.setValue(true, forKey: "allowUniversalAccessFromFileURLs")
    }
}

// MARK: - Manager Implementation WebView

class CluckFarmWebDataManager {
    static func clearCluckFarmWebData() {
        let dataTypes: Set<String> = [
            WKWebsiteDataTypeDiskCache,
            WKWebsiteDataTypeMemoryCache,
            WKWebsiteDataTypeCookies,
            WKWebsiteDataTypeLocalStorage
        ]
        
        WKWebsiteDataStore.default().removeData(
            ofTypes: dataTypes,
            modifiedSince: .distantPast
        ) {}
    }
    
    static func configureDataStore() -> WKWebsiteDataStore {
        return .default()
    }
}

// MARK: - Extensions Implementation Implementation

extension String {
    static let infernoCache = WKWebsiteDataTypeDiskCache
    static let infernoMemory = WKWebsiteDataTypeMemoryCache
    static let infernoCookies = WKWebsiteDataTypeCookies
    static let infernoStorage = WKWebsiteDataTypeLocalStorage
}
