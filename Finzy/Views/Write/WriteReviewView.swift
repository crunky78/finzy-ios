import SwiftUI

// MARK: - WriteReviewViewModel
@MainActor
class WriteReviewViewModel: ObservableObject {
    @Published var productName = ""
    @Published var selectedCategory: ReviewCategory = .beauty
    @Published var priceText = ""
    @Published var store = ""
    @Published var stars = 0
    @Published var pros = ""
    @Published var cons = ""
    @Published var comment = ""
    @Published var selectedBadge: VerificationBadge? = nil
    @Published var isPublic = true
    @Published var isLoading = false
    @Published var isSuccess = false
    @Published var errorMessage: String? = nil

    // 임시 userId (나중에 로그인 연동 시 변경)
    let userId = 1

    var isValid: Bool {
        !productName.isEmpty && stars > 0 && !pros.isEmpty && !cons.isEmpty
    }

    func submitReview() async {
        guard isValid else {
            errorMessage = "필수 항목을 모두 입력해주세요"
            return
        }

        isLoading = true
        errorMessage = nil

        let request = ReviewRequestModel(
            productName: productName,
            category: selectedCategory.name,
            price: Int(priceText),
            store: store.isEmpty ? nil : store,
            stars: stars,
            pros: pros,
            cons: cons,
            comment: comment.isEmpty ? nil : comment,
            verificationType: selectedBadge.map { badgeToString($0) },
            isPublic: isPublic
        )

        do {
            _ = try await ReviewAPI.shared.createReview(userId: userId, request: request)
            isSuccess = true
        } catch {
            errorMessage = "등록 중 오류가 발생했어요"
        }

        isLoading = false
    }

    private func badgeToString(_ badge: VerificationBadge) -> String {
        switch badge {
        case .card:    return "CARD"
        case .order:   return "ORDER"
        case .waybill: return "WAYBILL"
        case .gift:    return "GIFT"
        case .brand:   return "BRAND"
        }
    }
}

// MARK: - WriteReviewView
struct WriteReviewView: View {
    @StateObject private var viewModel = WriteReviewViewModel()
    @Environment(\.dismiss) private var dismiss

    var onSuccess: (() -> Void)?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {

                    // 인증 선택
                    VerificationSection(selected: $viewModel.selectedBadge)

                    // 상품명
                    InputSection(title: "상품명", isRequired: true) {
                        TextField("상품명을 입력해주세요", text: $viewModel.productName)
                            .font(FinzyFont.medium(14))
                    }

                    // 카테고리
                    InputSection(title: "카테고리", isRequired: true) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(ReviewCategory.allCases, id: \.self) { cat in
                                    Button {
                                        viewModel.selectedCategory = cat
                                    } label: {
                                        HStack(spacing: 4) {
                                            Text(cat.emoji)
                                                .font(.system(size: 13))
                                            Text(cat.rawValue)
                                                .font(FinzyFont.bold(11))
                                                .foregroundColor(
                                                    viewModel.selectedCategory == cat ? .white : .finzyCharcoal
                                                )
                                        }
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(
                                            viewModel.selectedCategory == cat
                                            ? Color.finzyCharcoal
                                            : Color.finzyGray3
                                        )
                                        .cornerRadius(20)
                                    }
                                }
                            }
                        }
                    }

                    // 가격 / 구매처
                    HStack(spacing: 12) {
                        InputSection(title: "가격", isRequired: false) {
                            HStack {
                                TextField("18,900", text: $viewModel.priceText)
                                    .font(FinzyFont.medium(14))
                                    .keyboardType(.numberPad)
                                Text("원")
                                    .font(FinzyFont.medium(13))
                                    .foregroundColor(.finzyGray1)
                            }
                        }
                        InputSection(title: "구매처", isRequired: false) {
                            TextField("올리브영, 쿠팡...", text: $viewModel.store)
                                .font(FinzyFont.medium(14))
                        }
                    }

                    // 별점
                    InputSection(title: "별점", isRequired: true) {
                        HStack(spacing: 8) {
                            ForEach(1..<6) { i in
                                Button {
                                    withAnimation(.spring(response: 0.2)) {
                                        viewModel.stars = i
                                    }
                                } label: {
                                    Image(systemName: i <= viewModel.stars ? "star.fill" : "star")
                                        .font(.system(size: 28))
                                        .foregroundColor(i <= viewModel.stars ? .finzyYellow : .finzyGray2)
                                        .scaleEffect(i <= viewModel.stars ? 1.1 : 1.0)
                                }
                            }
                            if viewModel.stars > 0 {
                                Text("\(viewModel.stars).0")
                                    .font(FinzyFont.bold(16))
                                    .foregroundColor(.finzyCharcoal)
                                    .padding(.leading, 4)
                            }
                        }
                    }

                    // 장점
                    InputSection(title: "장점", isRequired: false) {
                        TextField("좋았던 점을 작성해주세요", text: $viewModel.pros, axis: .vertical)
                            .font(FinzyFont.medium(13))
                            .lineLimit(3...5)
                    }
                    .background(Color.finzyGreenSoft.opacity(0.5))

                    // 단점 (필수)
                    InputSection(title: "단점", isRequired: true, accentColor: .finzyAccent) {
                        TextField("아쉬운 점을 꼭 적어주세요", text: $viewModel.cons, axis: .vertical)
                            .font(FinzyFont.medium(13))
                            .lineLimit(3...5)
                    }
                    .background(Color.finzyAccentSoft.opacity(0.5))

                    // 한줄 코멘트
                    InputSection(title: "한줄 코멘트", isRequired: false) {
                        TextField("한줄로 정리해보세요 (선택)", text: $viewModel.comment)
                            .font(FinzyFont.medium(13))
                    }

                    // 공개 여부
                    HStack {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("피드에 공개")
                                .font(FinzyFont.bold(14))
                                .foregroundColor(.finzyCharcoal)
                            Text("비공개 시 나만 볼 수 있어요")
                                .font(FinzyFont.regular(11))
                                .foregroundColor(.finzyGray1)
                        }
                        Spacer()
                        Toggle("", isOn: $viewModel.isPublic)
                            .tint(.finzyGreen)
                    }
                    .padding(14)
                    .background(Color.finzyGray3)
                    .cornerRadius(14)

                    // 에러 메시지
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(FinzyFont.medium(12))
                            .foregroundColor(.finzyAccent)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 4)
                    }

                    // 등록 버튼
                    Button {
                        Task { await viewModel.submitReview() }
                    } label: {
                        HStack {
                            if viewModel.isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("등록하기")
                                    .font(FinzyFont.bold(16))
                                if viewModel.selectedBadge != nil {
                                    Text("✅")
                                }
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(viewModel.isValid ? Color.finzyCharcoal : Color.finzyGray2)
                        .cornerRadius(16)
                    }
                    .disabled(!viewModel.isValid || viewModel.isLoading)

                    Spacer().frame(height: 20)
                }
                .padding(16)
            }
            .background(Color.finzyBg)
            .navigationTitle("소비 기록하기")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") { dismiss() }
                        .font(FinzyFont.medium(14))
                        .foregroundColor(.finzyGray1)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("임시저장") { }
                        .font(FinzyFont.medium(14))
                        .foregroundColor(.finzyAccent)
                }
            }
            .onChange(of: viewModel.isSuccess) { _, success in
                if success {
                    onSuccess?()
                    dismiss()
                }
            }
        }
    }
}

// MARK: - 인증 섹션
struct VerificationSection: View {
    @Binding var selected: VerificationBadge?

    let badges: [VerificationBadge] = [.card, .order, .waybill, .gift, .brand]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("구매 인증")
                    .font(FinzyFont.bold(14))
                    .foregroundColor(.finzyCharcoal)
                Text("인증 시 ✅ 뱃지가 붙어요")
                    .font(FinzyFont.regular(11))
                    .foregroundColor(.finzyGray1)
            }

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 8) {
                ForEach(badges, id: \.label) { badge in
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            if selected == badge {
                                selected = nil
                            } else {
                                selected = badge
                            }
                        }
                    } label: {
                        VStack(spacing: 4) {
                            Text(badge.icon)
                                .font(.system(size: 20))
                            Text(badge.label)
                                .font(FinzyFont.bold(9))
                                .foregroundColor(selected == badge ? badge.color : .finzyGray1)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(selected == badge ? badge.bgColor : Color.finzyGray3)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(selected == badge ? badge.color : Color.clear, lineWidth: 1.5)
                        )
                    }
                }
            }

            if let badge = selected {
                HStack(spacing: 6) {
                    Text(badge.icon)
                    Text(badge.description)
                        .font(FinzyFont.regular(11))
                        .foregroundColor(.finzyGray1)
                }
                .padding(.horizontal, 4)
            }
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.04), radius: 6, y: 2)
    }
}

// MARK: - 입력 섹션 컴포넌트
struct InputSection<Content: View>: View {
    let title: String
    let isRequired: Bool
    var accentColor: Color = .finzyCharcoal
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 4) {
                Text(title)
                    .font(FinzyFont.bold(13))
                    .foregroundColor(.finzyCharcoal)
                if isRequired {
                    Text("필수")
                        .font(FinzyFont.bold(9))
                        .foregroundColor(.white)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(accentColor)
                        .cornerRadius(4)
                }
            }
            content
                .padding(12)
                .background(Color.finzyGray3)
                .cornerRadius(12)
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.04), radius: 6, y: 2)
    }
}

// MARK: - VerificationBadge Equatable
extension VerificationBadge: Equatable {
    static func == (lhs: VerificationBadge, rhs: VerificationBadge) -> Bool {
        lhs.label == rhs.label
    }
}

#Preview {
    WriteReviewView()
}
