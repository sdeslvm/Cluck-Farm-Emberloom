import Foundation
import SwiftUI

// Перенесено в CluckFarmColorUtilities.swift

struct CluckFarmGameInitialView: View {
    @StateObject private var themeEngine = CluckFarmThemeEngine.shared
    @StateObject private var audioManager = CluckFarmAudioManager.shared
    @StateObject private var hapticManager = CluckFarmHapticManager.shared
    @State private var showSplash = true
    
    private var cluckFarmGameEndpoint: URL { URL(string: "https://cluckfargame.com/app")! }

    var body: some View {
        ZStack {
            if showSplash {
                CluckFarmLogoAnimation()
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .scale.combined(with: .opacity)
                    ))
            } else {
                // Используем фоновый градиент из темы
                themeEngine.getBackgroundGradient()
                    .ignoresSafeArea()
                
                CluckFarmEntryScreen(loader: .init(resourceURL: cluckFarmGameEndpoint))
            }
        }
        .onAppear {
            // Отключаем звуки
            // audioManager.playFarmAmbience()
            hapticManager.gameSuccess()
            
            // Показываем сплэш экран на 2 секунды для быстрого тестирования
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeInOut(duration: 1.0)) {
                    showSplash = false
                }
            }
        }
    }
}

#Preview {
    CluckFarmGameInitialView()
}

// Перенесено в CluckFarmColorUtilities.swift
