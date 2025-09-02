import SwiftUI

// MARK: - Implementation Implementation Implementation Implementation

protocol ProgressDisplayable {
    var progressPercentage: Int { get }
}

protocol BackgroundProviding {
    associatedtype BackgroundContent: View
    func makeBackground() -> BackgroundContent
}

// MARK: - Implementation Implementation Implementation

struct CluckFarmLoadingOverlay: View, ProgressDisplayable {
    @StateObject private var themeEngine = CluckFarmThemeEngine.shared
    let progress: Double
    @State private var pulse = false
    var progressPercentage: Int { Int(progress * 100) }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Fon: zelenyy gradient
                themeEngine.getBackgroundGradient()
                    .ignoresSafeArea(.all)
                    
                    

                // Adaptivnaya komponovka dlya portretnoy i gorizontalnoy orientatsii
                if geo.size.width > geo.size.height {
                    // Gorizontalnaya orientatsiya
                    HStack {
                        Spacer()
                        
                        // Logo sleva
                        CluckFarmLogoAnimation()
                            .frame(width: geo.size.width * 0.25, height: geo.size.height * 0.6)
                        
                            .shadow(color: .black.opacity(0.4), radius: 20, y: 8)
                        
                            .animation(
                                Animation.easeInOut(duration: 1.1).repeatForever(autoreverses: true),
                                value: pulse
                            )
                            .onAppear { pulse = true }
                         
                        
                        Spacer().frame(width: 60)
                        
                        // Progress sprava
                        VStack(spacing: 20) {
                            Text("Loading \(progressPercentage)%")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.8), radius: 4, y: 2)
                            
                            CluckFarmProgressBar(value: progress)
                                .frame(width: geo.size.width * 0.4, height: 12)
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.black.opacity(0.6))
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                        )
                        .shadow(color: .black.opacity(0.5), radius: 15, y: 8)
                        
                        Spacer()
                    }
                } else {
                    // Portretnaya orientatsiya
                    VStack {
                        Spacer()
                        
                        // Animirovannyy logo v verhney chasti
                        CluckFarmLogoAnimation()
                            .frame(width: geo.size.width * 0.4, height: geo.size.height * 0.3)
                        
                        Spacer().frame(height: 80)
                        
                        // Progressbar i protsenty vnizu
                        VStack(spacing: 20) {
                            Text("Loading Farm \(progressPercentage)%")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(Color.cluckFarmTheme(hex: CluckFarmColorPalette.lightGreen))
                                .shadow(color: .black.opacity(0.8), radius: 4, y: 2)
                            
                            CluckFarmProgressBar(value: progress)
                                .frame(width: geo.size.width * 0.7, height: 12)
                        }
                        .padding(24)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.black.opacity(0.6))
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                        )
                        .shadow(color: .black.opacity(0.5), radius: 15, y: 8)
                        
                        Spacer()
                    }
                }
            }
            .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
        }
    }
}

// MARK: - Background Views

struct CluckFarmBackground: View, BackgroundProviding {
    func makeBackground() -> some View {
        Image("background")
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
    }

    var body: some View {
        makeBackground()
    }
}

// MARK: - Implementation Implementation Implementation Implementation

struct CluckFarmProgressBar: View {
    let value: Double
    @State private var shimmerOffset: CGFloat = -1.0
    @State private var pulseScale: CGFloat = 1.0
    @State private var particles: [ProgressParticle] = []

    var body: some View {
        GeometryReader { geometry in
            progressContainer(in: geometry)
                .onAppear {
                    startShimmerAnimation()
                    startPulseAnimation()
                    generateParticles(width: geometry.size.width)
                }
        }
    }

    private func progressContainer(in geometry: GeometryProxy) -> some View {
        ZStack(alignment: .leading) {
            backgroundTrack(height: geometry.size.height)
            progressTrack(in: geometry)
            particleOverlay(in: geometry)
        }
    }

    private func farmProgressionColors() -> [Color] {
        let progress = value
        
        if progress < 0.25 {
            // Nachalnyy rost - temno-zelenyy k zelenomu
            return [
                Color.cluckFarmTheme(hex: CluckFarmColorPalette.darkGreen),
                Color.cluckFarmTheme(hex: CluckFarmColorPalette.primaryGreen),
                Color.cluckFarmTheme(hex: CluckFarmColorPalette.secondaryGreen)
            ]
        } else if progress < 0.5 {
            // Razvivayuschayasya ferma - zelenyy k svetlo-zelenomu
            return [
                Color.cluckFarmTheme(hex: CluckFarmColorPalette.primaryGreen),
                Color.cluckFarmTheme(hex: CluckFarmColorPalette.secondaryGreen),
                Color.cluckFarmTheme(hex: CluckFarmColorPalette.lightGreen)
            ]
        } else if progress < 0.75 {
            // Protsvetayuschaya ferma - svetlo-zelenyy k yarkomu
            return [
                Color.cluckFarmTheme(hex: CluckFarmColorPalette.secondaryGreen),
                Color.cluckFarmTheme(hex: CluckFarmColorPalette.lightGreen),
                Color.cluckFarmTheme(hex: CluckFarmColorPalette.accentGreen)
            ]
        } else {
            // Polnaya ferma - yarkie zelenye tona
            return [
                Color.cluckFarmTheme(hex: CluckFarmColorPalette.lightGreen),
                Color.cluckFarmTheme(hex: CluckFarmColorPalette.accentGreen),
                Color.white.opacity(0.9)
            ]
        }
    }
    
    private func backgroundTrack(height: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: height / 2)
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.cluckFarmTheme(hex: CluckFarmColorPalette.darkGreen).opacity(0.3),
                        Color.cluckFarmTheme(hex: CluckFarmColorPalette.primaryGreen).opacity(0.2),
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(height: height)
            .overlay(
                RoundedRectangle(cornerRadius: height / 2)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.cluckFarmTheme(hex: CluckFarmColorPalette.lightGreen).opacity(0.3),
                                Color.cluckFarmTheme(hex: CluckFarmColorPalette.accentGreen).opacity(0.2),
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: 1.5
                    )
            )
            .shadow(color: Color.black.opacity(0.4), radius: 8, y: 4)
    }

    private func progressTrack(in geometry: GeometryProxy) -> some View {
        let width = CGFloat(value) * geometry.size.width
        let height = geometry.size.height

        return ZStack {
            // Main neonovyy gradient
            RoundedRectangle(cornerRadius: height / 2)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: farmProgressionColors()),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: width, height: height)
                .scaleEffect(pulseScale)
                .shadow(color: farmProgressionColors().first?.opacity(0.8) ?? Color.green.opacity(0.8), radius: 15, y: 0)
                .shadow(color: farmProgressionColors().last?.opacity(0.6) ?? Color.green.opacity(0.6), radius: 25, y: 0)

            // Animirovannyy blesk
            RoundedRectangle(cornerRadius: height / 2)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.clear,
                            Color.white.opacity(0.8),
                            Color.clear,
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: width * 0.3, height: height)
                .offset(x: shimmerOffset * width)
                .clipped()
                .frame(width: width, height: height)

            // Vnutrennee svechenie
            RoundedRectangle(cornerRadius: height / 2)
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.4),
                            Color.clear,
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: height / 2
                    )
                )
                .frame(width: width, height: height * 0.6)
        }
        .animation(.easeInOut(duration: 0.3), value: value)
    }

    private func particleOverlay(in geometry: GeometryProxy) -> some View {
        let width = CGFloat(value) * geometry.size.width

        return ZStack {
            ForEach(particles.indices, id: \.self) { index in
                let particle = particles[index]
                if particle.x <= width {
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color.cluckFarmTheme(hex: CluckFarmColorPalette.accentGreen).opacity(0.8),
                                    Color.clear,
                                ]),
                                center: .center,
                                startRadius: 0,
                                endRadius: 2
                            )
                        )
                        .frame(width: 4, height: 4)
                        .position(x: particle.x, y: particle.y)
                        .opacity(particle.opacity)
                }
            }
        }
    }

    private func startShimmerAnimation() {
        withAnimation(Animation.linear(duration: 2.0).repeatForever(autoreverses: false)) {
            shimmerOffset = 1.2
        }
    }

    private func startPulseAnimation() {
        withAnimation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            pulseScale = 1.05
        }
    }

    private func generateParticles(width: CGFloat) {
        particles = (0..<15).map { _ in
            ProgressParticle(
                x: CGFloat.random(in: 0...width),
                y: CGFloat.random(in: 2...8),
                opacity: Double.random(in: 0.3...0.9)
            )
        }
    }
}

private struct ProgressParticle {
    let x: CGFloat
    let y: CGFloat
    let opacity: Double
}


// MARK: - Implementation

#Preview("Vertical") {
    CluckFarmLoadingOverlay(progress: 0.2)
}

#Preview("Horizontal") {
    CluckFarmLoadingOverlay(progress: 0.2)
        .previewInterfaceOrientation(.landscapeRight)
        .previewDevice("iPhone 16 Pro")
}
