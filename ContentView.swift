//
//  DynamicNotchSimulation.swift
//  iPhone 12 için "Dynamic Notch" Simülasyonu
//
//  Mantık: iPhone 12'nin fiziksel çentiği zaten siyah bir kesim. Bu bileşeni
//  TAM O NOKTAYA (ekranın en üstüne, çentik ölçülerinde) siyah olarak
//  yerleştirdiğimizde, gerçek çentikle kaynaşıp "içine gömülü" görünür.
//  Dokununca basılma efekti + genişleme animasyonu, çentiğin kendisi
//  büyüyormuş hissi verir (üst kenar hep ekrana yapışık kalır, sadece
//  alt kısım aşağı doğru şişer).
//
//  KURULUM:
//  1) Xcode > File > New > Project > App (SwiftUI, Swift)
//  2) ContentView.swift içeriğini tamamen silip bunu yapıştır.
//  3) Proje şablonu kendi "@main" struct'ı oluşturduysa, aşağıdaki
//     "DynamicNotchDemoApp" struct'ını SİL (çakışmasın diye).
//  4) Simulator > iPhone 12 seç, Run (▶).
//

import SwiftUI

// MARK: - App Girişi (yeni proje oluşturduysan kullan, oluşturmadıysan sil)
@main
struct DynamicNotchDemoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

enum IslandState {
    case compact
    case expanded
}

// MARK: - Ana Ekran
struct ContentView: View {
    @State private var islandState: IslandState = .compact
    @State private var progress: Double = 0.35

    var body: some View {
        ZStack(alignment: .top) {
            LinearGradient(
                colors: [Color.black, Color(red: 0.08, green: 0.08, blue: 0.1)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 16) {
                Spacer().frame(height: 100)

                Text("Dynamic Notch Simülasyonu")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.7))

                Text("Çentiğe dokun — genişlesin/küçülsün.")
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.4))

                Spacer()
            }

            // Gerçek çentiğin TAM üstüne, kaynaşacak şekilde
            DynamicNotchView(state: $islandState, progress: progress)
                .ignoresSafeArea(edges: .top)
        }
        .onAppear { startFakeProgress() }
    }

    private func startFakeProgress() {
        Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 1.0)) {
                progress = progress >= 1.0 ? 0.1 : progress + 0.15
            }
        }
    }
}

// MARK: - Sadece alt köşeleri yuvarlak "çentik" şekli
// (Üst kenar dümdüz kalır ki ekranın fiziksel üst kenarıyla kaynaşsın)
struct NotchShape: Shape {
    var bottomRadius: CGFloat

    var animatableData: CGFloat {
        get { bottomRadius }
        set { bottomRadius = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        let r = min(bottomRadius, h, w / 2)

        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: w, y: 0))
        path.addLine(to: CGPoint(x: w, y: h - r))
        path.addQuadCurve(to: CGPoint(x: w - r, y: h), control: CGPoint(x: w, y: h))
        path.addLine(to: CGPoint(x: r, y: h))
        path.addQuadCurve(to: CGPoint(x: 0, y: h - r), control: CGPoint(x: 0, y: h))
        path.closeSubpath()
        return path
    }
}

// MARK: - Basılma tepkisi veren buton stili
struct NotchButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.93 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.5), value: configuration.isPressed)
    }
}

// MARK: - Dynamic Notch Bileşeni
struct DynamicNotchView: View {
    @Binding var state: IslandState
    let progress: Double

    // iPhone 12 çentik ölçüleri (point)
    private let notchWidth: CGFloat = 209
    private let notchHeight: CGFloat = 30
    private let notchBottomRadius: CGFloat = 20

    private let expandedWidth: CGFloat = 330
    private let expandedHeight: CGFloat = 110
    private let expandedBottomRadius: CGFloat = 34

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.72)) {
                state = (state == .compact) ? .expanded : .compact
            }
        } label: {
            NotchShape(bottomRadius: state == .compact ? notchBottomRadius : expandedBottomRadius)
                .fill(Color.black)
                .frame(
                    width: state == .compact ? notchWidth : expandedWidth,
                    height: state == .compact ? notchHeight : expandedHeight
                )
                // Üst kenar hep ekranın en üstünde sabit kalsın diye .top hizalı büyütüyoruz
                .frame(maxWidth: .infinity, alignment: .top)
                .overlay(content)
        }
        .buttonStyle(NotchButtonStyle())
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private var content: some View {
        if state == .compact {
            // Boştayken çentiğin içine gömülü nokta / kamera hissi
            HStack {
                Spacer()
                Circle()
                    .fill(Color.gray.opacity(0.4))
                    .frame(width: 10, height: 10)
                Spacer().frame(width: 14)
            }
        } else {
            VStack(spacing: 10) {
                HStack {
                    Image(systemName: "music.note")
                        .foregroundColor(.white)
                    Text("Şimdi Çalıyor")
                        .font(.caption)
                        .foregroundColor(.white)
                    Spacer()
                    Text("\(Int(progress * 100))%")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.6))
                }
                .padding(.horizontal, 18)
                .padding(.top, 34) // güvenli alan (kamera çıkıntısı) payı

                ProgressView(value: progress)
                    .tint(.white)
                    .padding(.horizontal, 18)

                Spacer()
            }
        }
    }
}

// MARK: - Önizleme
#Preview {
    ContentView()
}
