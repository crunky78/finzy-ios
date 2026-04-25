import SwiftUI

enum AppState {
    case splash
    case login
    case categorySelect
    case main
}

@main
struct FinzyApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

struct RootView: View {
    @State private var appState: AppState = .splash

    var body: some View {
        ZStack {
            switch appState {
            case .splash:
                SplashView {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        appState = .login
                    }
                }
                .transition(.opacity)

            case .login:
                LoginView {
                    // 로그인 성공
                    withAnimation(.easeInOut(duration: 0.4)) {
                        appState = .categorySelect
                    }
                } onSkip: {
                    // 건너뛰기
                    withAnimation(.easeInOut(duration: 0.4)) {
                        appState = .main
                    }
                }
                .transition(.opacity)

            case .categorySelect:
                CategorySelectView {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        appState = .main
                    }
                }
                .transition(.opacity)

            case .main:
                MainTabView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.35), value: appState)
    }
}
