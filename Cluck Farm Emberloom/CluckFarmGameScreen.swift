import Foundation
import SwiftUI

struct CluckFarmEntryScreen: View {
    @StateObject private var loader: CluckFarmWebResourceLoader

    init(loader: CluckFarmWebResourceLoader) {
        _loader = StateObject(wrappedValue: loader)
    }

    var body: some View {
        ZStack {
            CluckFarmWebViewContainer(loader: loader)
                .opacity(loader.state == .finished ? 1 : 0.3)
            
            if loader.state != .finished {
                VStack {
                    switch loader.state {
                    case .progressing(_):
                        // Show logo animation during loading
                        CluckFarmLogoAnimation()
                            .frame(width: 200, height: 200)
                    case .failure(let err):
                        CluckFarmErrorDisplay(err: err)
                    case .noConnection:
                        CluckFarmOfflineDisplay()
                    case .standby:
                        // Show logo animation during standby
                        CluckFarmLogoAnimation()
                            .frame(width: 200, height: 200)
                    case .finished:
                        EmptyView()
                    }
                }
            }
        }
    }
}


private struct CluckFarmErrorDisplay: View {
    let err: String
    var body: some View {
        Text("Error: \(err)").foregroundColor(Color.cluckFarmTheme(hex: CluckFarmColorPalette.darkGreen))
    }
}

private struct CluckFarmOfflineDisplay: View {
    var body: some View {
        Text("No Connection").foregroundColor(.gray)
    }
}
