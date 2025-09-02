import Combine
import SwiftUI
import WebKit

// MARK: - Protocols

/// Protocol for managing web loading state
protocol WebLoadable: AnyObject {
    var state: CluckFarmWebStatus { get set }
    func setConnectivity(_ available: Bool)
}

/// Protocol for monitoring loading progress
protocol ProgressMonitoring {
    func observeProgression()
    func monitor(_ webView: WKWebView)
}

// MARK: - Main web view loader

/// Class for managing web view loading and state
final class CluckFarmWebResourceLoader: NSObject, ObservableObject, WebLoadable, ProgressMonitoring {
    // MARK: - Properties

    @Published var state: CluckFarmWebStatus = .standby

    let cluckFarmEndpoint: URL
    private var cluckFarmSubscriptions = Set<AnyCancellable>()
    private var cluckFarmProgressStream = PassthroughSubject<Double, Never>()
    private var cluckFarmViewFactory: (() -> WKWebView)?

    // MARK: - Initialization

    init(resourceURL: URL) {
        self.cluckFarmEndpoint = resourceURL
        super.init()
        observeProgression()
    }

    // MARK: - Public methods

    /// Attach web view to loader
    func attachCluckFarmWebView(factory: @escaping () -> WKWebView) {
        cluckFarmViewFactory = factory
        initiateCluckFarmLoad()
    }

    /// Set connectivity availability
    func setConnectivity(_ available: Bool) {
        switch (available, state) {
        case (true, .noConnection):
            initiateCluckFarmLoad()
        case (false, _):
            state = .noConnection
        default:
            break
        }
    }

    // MARK: - Private loading methods

    /// Start web view loading
    private func initiateCluckFarmLoad() {
        guard let webView = cluckFarmViewFactory?() else { return }

        let request = URLRequest(url: cluckFarmEndpoint, timeoutInterval: 12)
        state = .progressing(progress: 0)

        webView.navigationDelegate = self
        webView.load(request)
        monitorCluckFarmProgress(webView)
    }

    // MARK: - Monitoring methods

    /// Observe loading progress
    func observeProgression() {
        startCluckFarmProgressMonitoring()
    }
    
    private func startCluckFarmProgressMonitoring() {
        cluckFarmProgressStream
            .removeDuplicates()
            .sink { [weak self] progress in
                guard let self else { return }
                self.state = progress < 1.0 ? .progressing(progress: progress) : .finished
            }
            .store(in: &cluckFarmSubscriptions)
    }

    /// Monitor web view progress
    func monitor(_ webView: WKWebView) {
        monitorCluckFarmProgress(webView)
    }
    
    private func monitorCluckFarmProgress(_ webView: WKWebView) {
        webView.publisher(for: \.estimatedProgress)
            .sink { [weak self] progress in
                self?.cluckFarmProgressStream.send(progress)
            }
            .store(in: &cluckFarmSubscriptions)
    }
}

// MARK: - Navigation handling extension

extension CluckFarmWebResourceLoader: WKNavigationDelegate {
    /// Handle navigation errors
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        handleNavigationError(error)
    }

    /// Handle provisional navigation errors
    func webView(
        _ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!,
        withError error: Error
    ) {
        handleNavigationError(error)
    }

    // MARK: - Private error handling methods

    /// General navigation error handling method
    private func handleNavigationError(_ error: Error) {
        state = .failure(reason: error.localizedDescription)
    }
}

// MARK: - Extensions for enhanced functionality

extension CluckFarmWebResourceLoader {
    /// Create loader with safe URL
    convenience init?(urlString: String) {
        guard let url = URL(string: urlString) else { return nil }
        self.init(resourceURL: url)
    }
}
