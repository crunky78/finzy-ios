import SwiftUI

struct LoginView: View {
    @State private var contentOpacity: Double = 0
    @State private var contentOffset: CGFloat = 30

    var onLogin: () -> Void
    var onSkip: () -> Void

    var body: some View {
        ZStack {
            Color.finzyWhite.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // 상단 일러스트 영역
                ZStack {
                    Circle()
                        .fill(Color.finzyAccentSoft)
                        .frame(width: 120, height: 120)
                    Text("🧾")
                        .font(.system(size: 52))
                }
                .padding(.bottom, 28)

                // 로고
                Text("Finzy")
                    .font(.system(size: 44, weight: .heavy, design: .serif))
                    .foregroundColor(.finzyAccent)
                    .padding(.bottom, 12)

                // 설명
                Text("영수증 인증된 리뷰만 있는\n내돈내산 소비 일기 SNS")
                    .font(FinzyFont.medium(14))
                    .foregroundColor(.finzyGray1)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.bottom, 40)

                // 소셜 로그인 버튼
                VStack(spacing: 12) {
                    // 애플 로그인
                    Button {
                        onLogin()
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "apple.logo")
                                .font(.system(size: 18, weight: .semibold))
                            Text("Apple로 시작하기")
                                .font(FinzyFont.bold(15))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color.finzyCharcoal)
                        .cornerRadius(16)
                    }

                    // 카카오 로그인
                    Button {
                        onLogin()
                    } label: {
                        HStack(spacing: 10) {
                            Text("💛")
                                .font(.system(size: 18))
                            Text("카카오로 시작하기")
                                .font(FinzyFont.bold(15))
                        }
                        .foregroundColor(Color(hex: "#391B1B"))
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color(hex: "#FEE500"))
                        .cornerRadius(16)
                    }
                }
                .padding(.horizontal, 28)

                Spacer().frame(height: 24)

                // 건너뛰기
                Button {
                    onSkip()
                } label: {
                    Text("로그인 없이 둘러보기")
                        .font(FinzyFont.medium(13))
                        .foregroundColor(.finzyGray2)
                        .underline()
                }

                Spacer()

                // 하단 안내
                Text("로그인 시 이용약관 및 개인정보처리방침에 동의합니다")
                    .font(FinzyFont.regular(11))
                    .foregroundColor(.finzyGray2)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 20)
            }
            .opacity(contentOpacity)
            .offset(y: contentOffset)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.1)) {
                contentOpacity = 1
                contentOffset = 0
            }
        }
    }
}

#Preview {
    LoginView(onLogin: {}, onSkip: {})
}
