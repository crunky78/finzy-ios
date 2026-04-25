import SwiftUI

struct SplashView: View {
    @State private var logoScale: CGFloat = 0.7
    @State private var logoOpacity: Double = 0
    @State private var subOpacity: Double = 0
    @State private var dotOpacity: Double = 0

    var onFinished: () -> Void

    var body: some View {
        ZStack {
            Color.finzyCharcoal
                .ignoresSafeArea()

            VStack(spacing: 10) {
                // 로고
                Text("Finzy")
                    .font(.system(size: 52, weight: .heavy, design: .serif))
                    .foregroundColor(.finzyAccent)
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)

                // 서브타이틀
                Text("내돈내산 소비 일기 SNS")
                    .font(FinzyFont.medium(13))
                    .foregroundColor(.white.opacity(0.5))
                    .tracking(1.5)
                    .opacity(subOpacity)

                // 로딩 점
                Circle()
                    .fill(Color.finzyAccent)
                    .frame(width: 6, height: 6)
                    .opacity(dotOpacity)
                    .padding(.top, 28)
                    .animation(
                        .easeInOut(duration: 0.8).repeatForever(autoreverses: true),
                        value: dotOpacity
                    )
            }
        }
        .onAppear {
            // 로고 등장
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }
            // 서브타이틀
            withAnimation(.easeIn(duration: 0.4).delay(0.4)) {
                subOpacity = 1.0
            }
            // 점 애니메이션
            withAnimation(.easeIn(duration: 0.3).delay(0.7)) {
                dotOpacity = 1.0
            }
            // 2초 후 다음 화면
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                onFinished()
            }
        }
    }
}

#Preview {
    SplashView(onFinished: {})
}
