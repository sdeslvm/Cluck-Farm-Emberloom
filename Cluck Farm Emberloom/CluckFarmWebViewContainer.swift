import SwiftUI
import WebKit
import Combine

// MARK: - Протоколы и расширения

/// Протокол для создания градиентных представлений
protocol CluckFarmGradientRenderer {
    func buildFarmGradientLayer() -> CAGradientLayer
}

// MARK: - Улучшенный контейнер с градиентом

/// Кастомный контейнер с градиентным фоном
final class CluckFarmContainerView: UIView, CluckFarmGradientRenderer {
    // MARK: - Приватные свойства

    private let farmLayer = CAGradientLayer()

    // MARK: - Инициализаторы

    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeFarmView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initializeFarmView()
    }

    // MARK: - Методы настройки

    private func initializeFarmView() {
        layer.insertSublayer(buildFarmGradientLayer(), at: 0)
    }

    /// Создание градиентного слоя
    func buildFarmGradientLayer() -> CAGradientLayer {
        farmLayer.colors = UIColor.cluckFarmGradientColors()
        farmLayer.startPoint = CGPoint(x: 0, y: 0)
        farmLayer.endPoint = CGPoint(x: 1, y: 1)
        return farmLayer
    }

    // MARK: - Обновление слоя

    override func layoutSubviews() {
        super.layoutSubviews()
        farmLayer.frame = bounds
    }
}

// MARK: - Расширения для цветов

extension UIColor {
    /// Инициализатор цвета из HEX-строки с улучшенной обработкой
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

// MARK: - Представление веб-вида

struct CluckFarmWebViewContainer: UIViewRepresentable {
    // MARK: - Свойства

    @ObservedObject var loader: CluckFarmWebResourceLoader

    // MARK: - Координатор

    func makeCoordinator() -> CluckFarmWebCoordinator {
        CluckFarmWebCoordinator { [weak loader] status in
            DispatchQueue.main.async {
                loader?.state = status
            }
        }
    }

    // MARK: - Создание представления

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

    // MARK: - Приватные методы настройки

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
