import Foundation
import SwiftUI

// Pereneseno v CluckFarmColorUtilities.swift

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
                // Ispolzuem fonovyy gradient iz temy
                themeEngine.getBackgroundGradient()
                    .ignoresSafeArea()
                
                CluckFarmEntryScreen(loader: .init(resourceURL: cluckFarmGameEndpoint))
            }
        }
        .onAppear {
            // Otklyuchaem zvuki
            // audioManager.playFarmAmbience()
            hapticManager.gameSuccess()
            
            // Pokazyvaem splesh screen na 2 sekundy dlya quicklygo testirovaniya
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

// Pereneseno v CluckFarmColorUtilities.swift
