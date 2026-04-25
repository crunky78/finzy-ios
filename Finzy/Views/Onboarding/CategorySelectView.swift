import SwiftUI

struct CategorySelectView: View {
    @State private var selected: Set<ReviewCategory> = []
    @State private var contentOpacity: Double = 0

    var onFinished: () -> Void

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        ZStack {
            Color.finzyWhite.ignoresSafeArea()

            VStack(spacing: 0) {
                // 상단 헤더
                HStack {
                    Spacer()
                    Button("건너뛰기") {
                        onFinished()
                    }
                    .font(FinzyFont.medium(13))
                    .foregroundColor(.finzyGray1)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 8)

                // 타이틀
                VStack(alignment: .leading, spacing: 6) {
                    Text("어떤 제품에 관심있어요? 👀")
                        .font(FinzyFont.heavy(20))
                        .foregroundColor(.finzyCharcoal)
                    Text("선택한 카테고리 위주로 피드를 보여드려요")
                        .font(FinzyFont.regular(13))
                        .foregroundColor(.finzyGray1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)

                // 카테고리 그리드
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(ReviewCategory.allCases, id: \.self) { cat in
                        CategoryButton(
                            category: cat,
                            isSelected: selected.contains(cat)
                        ) {
                            if selected.contains(cat) {
                                selected.remove(cat)
                            } else {
                                selected.insert(cat)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)

                Spacer()

                // 시작하기 버튼
                Button {
                    onFinished()
                } label: {
                    HStack {
                        Text(selected.isEmpty ? "일단 시작하기" : "시작하기 →")
                            .font(FinzyFont.bold(16))
                        if !selected.isEmpty {
                            Text("\(selected.count)개 선택됨")
                                .font(FinzyFont.medium(12))
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color.finzyAccent)
                    .cornerRadius(16)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
        }
        .opacity(contentOpacity)
        .onAppear {
            withAnimation(.easeIn(duration: 0.3)) {
                contentOpacity = 1
            }
        }
    }
}

// MARK: - 카테고리 버튼
struct CategoryButton: View {
    let category: ReviewCategory
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Text(category.emoji)
                    .font(.system(size: 28))
                Text(category.rawValue)
                    .font(FinzyFont.bold(11))
                    .foregroundColor(isSelected ? .white : .finzyCharcoal)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .background(isSelected ? Color.finzyCharcoal : Color.finzyGray3)
            .cornerRadius(14)
            .scaleEffect(isSelected ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
    }
}

#Preview {
    CategorySelectView(onFinished: {})
}
