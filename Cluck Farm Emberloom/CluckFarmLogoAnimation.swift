import SwiftUI

// MARK: - Animation Implementation Implementation Cluck Farm

struct CluckFarmLogoAnimation: View {
    @State private var isAnimating = false
    @State private var rotationAngle: Double = 0
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    @State private var featherOffset: CGFloat = 0
    @State private var pulseScale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            // Fonovye chastitsy
            ForEach(0..<20, id: \.self) { index in
                Circle()
                    .fill(Color.cluckFarmTheme(hex: CluckFarmColorPalette.lightGreen))
                    .frame(width: CGFloat.random(in: 2...6))
                    .position(
                        x: CGFloat.random(in: 0...300),
                        y: CGFloat.random(in: 0...600)
                    )
                    .opacity(isAnimating ? 0.6 : 0)
                    .animation(
                        Animation.easeInOut(duration: Double.random(in: 2...4))
                            .repeatForever(autoreverses: true)
                            .delay(Double.random(in: 0...2)),
                        value: isAnimating
                    )
            }
            
            VStack(spacing: 20) {
                // Glavnyy logo
                ZStack {
                    // Vneshnee koltso
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.cluckFarmTheme(hex: CluckFarmColorPalette.primaryGreen),
                                    Color.cluckFarmTheme(hex: CluckFarmColorPalette.secondaryGreen)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 8
                        )
                        .frame(width: 120, height: 120)
                        .scaleEffect(pulseScale)
                        .animation(
                            Animation.easeInOut(duration: 2.0)
                                .repeatForever(autoreverses: true),
                            value: pulseScale
                        )
                    
                    // Tsentralnaya ikonka
                    ZStack {
                        // Fon ikonki
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color.cluckFarmTheme(hex: CluckFarmColorPalette.lightGreen),
                                        Color.cluckFarmTheme(hex: CluckFarmColorPalette.primaryGreen)
                                    ],
                                    center: .center,
                                    startRadius: 10,
                                    endRadius: 50
                                )
                            )
                            .frame(width: 100, height: 100)
                        
                        // Ikonka iz Assets
                        Image("CluckFarmLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .rotationEffect(.degrees(rotationAngle))
                            .scaleEffect(scale)
                    }
                }
                .scaleEffect(scale)
                .opacity(opacity)
                
                // Nazvanie prilozheniya
                VStack(spacing: 5) {
                    Text("Cluck Farm")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(Color.cluckFarmTheme(hex: CluckFarmColorPalette.darkGreen))
                        .offset(x: featherOffset)
                    
                    Text("Emberloom")
                        .font(.system(size: 24, weight: .medium, design: .rounded))
                        .foregroundColor(Color.cluckFarmTheme(hex: CluckFarmColorPalette.secondaryGreen))
                        .offset(x: -featherOffset)
                }
                .opacity(opacity)
                
                // Indikator zagruzki
                HStack(spacing: 8) {
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(Color.cluckFarmTheme(hex: CluckFarmColorPalette.primaryGreen))
                            .frame(width: 12, height: 12)
                            .scaleEffect(isAnimating ? 1.2 : 0.8)
                            .animation(
                                Animation.easeInOut(duration: 0.6)
                                    .repeatForever(autoreverses: true)
                                    .delay(Double(index) * 0.2),
                                value: isAnimating
                            )
                    }
                }
                .opacity(opacity)
            }
        }
        .onAppear {
            startAnimation()
        }
    }
    
    private func startAnimation() {
        // Nachalnaya animation poyavleniya
        withAnimation(.easeOut(duration: 1.0)) {
            opacity = 1.0
            scale = 1.0
        }
        
        // Animation vrascheniya
        withAnimation(.linear(duration: 8.0).repeatForever(autoreverses: false)) {
            rotationAngle = 360
        }
        
        // Animation pulsatsii
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            pulseScale = 1.1
        }
        
        // Animation perev (pokachivanie teksta)
        withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
            featherOffset = 10
        }
        
        // Aktivatsiya tochek zagruzki
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isAnimating = true
        }
    }
}

struct CluckFarmSplashScreen: View {
    @State private var showMainApp = false
    @State private var animationComplete = false
    
    var body: some View {
        ZStack {
            // Fonovyy gradient
            LinearGradient(
                colors: [
                    Color.cluckFarmTheme(hex: CluckFarmColorPalette.darkGreen),
                    Color.cluckFarmTheme(hex: CluckFarmColorPalette.primaryGreen),
                    Color.cluckFarmTheme(hex: CluckFarmColorPalette.lightGreen)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            if !showMainApp {
                CluckFarmLogoAnimation()
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .scale.combined(with: .opacity)
                    ))
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                withAnimation(.easeInOut(duration: 1.0)) {
                    showMainApp = true
                }
            }
        }
    }
}

#Preview {
    CluckFarmSplashScreen()
}
