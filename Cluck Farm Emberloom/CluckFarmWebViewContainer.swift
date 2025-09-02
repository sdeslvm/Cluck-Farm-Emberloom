import SwiftUI
import WebKit
import Combine

// MARK: - Implementation Implementation extensions

/// Implementation details
protocol CluckFarmGradientRenderer {
    func buildFarmGradientLayer() -> CAGradientLayer
}

// MARK: - Implementation container Implementation Implementation

/// Implementation details
final class CluckFarmContainerView: UIView, CluckFarmGradientRenderer {
    // MARK: - Implementation Implementation

    private let farmLayer = CAGradientLayer()

    // MARK: - Implementation

    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeFarmView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initializeFarmView()
    }

// MARK: - Methods

    private func initializeFarmView() {
        layer.insertSublayer(buildFarmGradientLayer(), at: 0)
    }

/// Implementation details
    func buildFarmGradientLayer() -> CAGradientLayer {
        farmLayer.colors = UIColor.cluckFarmGradientColors()
        farmLayer.startPoint = CGPoint(x: 0, y: 0)
        farmLayer.endPoint = CGPoint(x: 1, y: 1)
        return farmLayer
    }

    // MARK: - Implementation Implementation

    override func layoutSubviews() {
        super.layoutSubviews()
        farmLayer.frame = bounds
    }
}

// MARK: - Extensions Implementation Implementation

extension UIColor {
/// Implementation details
    convenience init(hex hexString: String) {
        let sanitizedHex =
            hexString
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")
            .uppercased()

        var colorValue: UInt64 = 0
        Scanner(string: sanitizedHex).scanHexInt64(&colorValue)

        let redComponent = CGFloat((colorValue & 0xFF0000) >> 16) / 255.0
        let greenComponent = CGFloat((colorValue & 0x00FF00) >> 8) / 255.0
        let blueComponent = CGFloat(colorValue & 0x0000FF) / 255.0

        self.init(red: redComponent, green: greenComponent, blue: blueComponent, alpha: 1.0)
    }
    
}

// MARK: - Implementation web-Implementation

struct CluckFarmWebViewContainer: UIViewRepresentable {
    // MARK: - Properties

    @ObservedObject var loader: CluckFarmWebResourceLoader

    // MARK: - Coordinator

    func makeCoordinator() -> CluckFarmWebCoordinator {
        CluckFarmWebCoordinator { [weak loader] status in
            DispatchQueue.main.async {
                loader?.state = status
            }
        }
    }

    // MARK: - Implementation Implementation

    func makeUIView(context: Context) -> WKWebView {
        let configuration = buildCluckFarmWebConfiguration()
        let webView = WKWebView(frame: .zero, configuration: configuration)

        configureCluckFarmWebViewStyle(webView)
        configureCluckFarmContainer(with: webView)

        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        loader.attachCluckFarmWebView { webView }
        loader.monitor(webView)

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Here you can update the WKWebView as needed, e.g., reload content when the loader changes.
        // For now, this can be left empty or you can update it as per loader's state if needed.
    }

    // MARK: - Private methods settings

    private func buildCluckFarmWebConfiguration() -> WKWebViewConfiguration {
        return CluckFarmWebViewConfigurationBuilder.createAdvancedConfiguration()
    }

    private func configureCluckFarmWebViewStyle(_ webView: WKWebView) {
        CluckFarmWebViewConfigurationBuilder.configureWebViewForCluckFarm(webView)
    }

    private func configureCluckFarmContainer(with webView: WKWebView) {
        let containerView = CluckFarmContainerView()
        containerView.addSubview(webView)

        webView.frame = containerView.bounds
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }

    private func clearCluckFarmData() {
        CluckFarmWebDataManager.clearCluckFarmWebData()
    }
}
