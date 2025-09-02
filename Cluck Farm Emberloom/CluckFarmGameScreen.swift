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
                    Text("Status: \(loader.state.debugDescription)")
                        .foregroundColor(.white)
                        .padding()
                    
                    switch loader.state {
                    case .progressing(let percent):
                        CluckFarmProgressDisplay(value: percent)
                    case .failure(let err):
                        CluckFarmErrorDisplay(err: err)
                    case .noConnection:
                        CluckFarmOfflineDisplay()
                    case .standby:
                        Text("Loading...")
                            .foregroundColor(.white)
                    case .finished:
                        EmptyView()
                    }
                }
                .background(Color.black.opacity(0.7))
            }
        }
    }
}

private struct CluckFarmProgressDisplay: View {
    let value: Double
    var body: some View {
        GeometryReader { geo in
            CluckFarmLoadingOverlay(progress: value)
                .frame(width: geo.size.width, height: geo.size.height)
                .background(Color.black)
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
