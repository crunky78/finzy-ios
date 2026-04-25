import SwiftUI

// MARK: - SearchViewModel
@MainActor
class SearchViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var results: [ReviewResponseModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var verifiedOnly = false
    @Published var hasSearched = false

    func search() async {
        guard !searchText.trimmingCharacters(in: .whitespaces).isEmpty else { return }

        isLoading = true
        errorMessage = nil
        hasSearched = true

        do {
            let response = try await ReviewAPI.shared.searchReviews(
                keyword: searchText,
                verifiedOnly: verifiedOnly
            )
            results = response.content
        } catch {
            errorMessage = "검색 중 오류가 발생했어요"
        }

        isLoading = false
    }

    func clear() {
        searchText = ""
        results = []
        hasSearched = false
        errorMessage = nil
    }
}

// MARK: - SearchMainView
struct SearchMainView: View {
    @StateObject private var viewModel = SearchViewModel()
    @FocusState private var isFocused: Bool

    let recentSearches = ["라로슈포제", "소니 헤드폰", "네스프레소", "뉴발란스 993"]
    let hotSearches = ["에어팟 프로2", "다이슨 에어랩", "뉴발란스 993", "링크플로우"]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                // 검색바
                HStack(spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.finzyGray1)
                            .font(.system(size: 15))
                        TextField("상품명으로 찾아보세요", text: $viewModel.searchText)
                            .font(FinzyFont.medium(14))
                            .focused($isFocused)
                            .submitLabel(.search)
                            .onSubmit {
                                Task { await viewModel.search() }
                            }
                        if !viewModel.searchText.isEmpty {
                            Button {
                                viewModel.clear()
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.finzyGray2)
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color.finzyGray3)
                    .cornerRadius(12)

                    if isFocused || !viewModel.searchText.isEmpty {
                        Button("취소") {
                            viewModel.clear()
                            isFocused = false
                        }
                        .font(FinzyFont.medium(13))
                        .foregroundColor(.finzyGray1)
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color.finzyWhite)
                .animation(.easeInOut(duration: 0.2), value: isFocused)

                Divider()

                // 인증만 보기 토글 (검색 후에만 표시)
                if viewModel.hasSearched {
                    HStack {
                        Text("인증 리뷰만 보기")
                            .font(FinzyFont.medium(13))
                            .foregroundColor(.finzyCharcoal)
                        Spacer()
                        Toggle("", isOn: $viewModel.verifiedOnly)
                            .tint(.finzyGreen)
                            .onChange(of: viewModel.verifiedOnly) { _, _ in
                                Task { await viewModel.search() }
                            }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.finzyWhite)

                    Divider()
                }

                // 컨텐츠
                if viewModel.isLoading {
                    Spacer()
                    ProgressView().tint(.finzyAccent)
                    Spacer()
                } else if viewModel.hasSearched {
                    // 검색 결과
                    SearchResultView(
                        keyword: viewModel.searchText,
                        results: viewModel.results,
                        errorMessage: viewModel.errorMessage
                    )
                } else {
                    // 검색 전 홈
                    SearchHomeView(recentSearches: recentSearches, hotSearches: hotSearches) { keyword in
                        viewModel.searchText = keyword
                        Task { await viewModel.search() }
                    }
                }
            }
            .background(Color.finzyBg)
            .navigationTitle("탐색")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - 검색 홈
struct SearchHomeView: View {
    let recentSearches: [String]
    let hotSearches: [String]
    let onTap: (String) -> Void

    let columns = Array(repeating: GridItem(.flexible()), count: 2)

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {

                // 최근 검색
                VStack(alignment: .leading, spacing: 0) {
                    Text("최근 검색")
                        .font(FinzyFont.bold(14))
                        .foregroundColor(.finzyCharcoal)
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 8)

                    ForEach(recentSearches, id: \.self) { keyword in
                        Button {
                            onTap(keyword)
                        } label: {
                            HStack {
                                Image(systemName: "clock")
                                    .font(.system(size: 13))
                                    .foregroundColor(.finzyGray1)
                                Text(keyword)
                                    .font(FinzyFont.medium(13))
                                    .foregroundColor(.finzyCharcoal)
                                Spacer()
                                Image(systemName: "xmark")
                                    .font(.system(size: 11))
                                    .foregroundColor(.finzyGray2)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                        }
                        Divider().padding(.leading, 44)
                    }
                }
                .background(Color.finzyWhite)

                // 인기 검색어
                VStack(alignment: .leading, spacing: 10) {
                    Text("🔥 인기 검색어")
                        .font(FinzyFont.bold(14))
                        .foregroundColor(.finzyCharcoal)
                        .padding(.horizontal, 16)
                        .padding(.top, 20)

                    LazyVGrid(columns: columns, spacing: 8) {
                        ForEach(hotSearches.indices, id: \.self) { i in
                            Button {
                                onTap(hotSearches[i])
                            } label: {
                                HStack(spacing: 8) {
                                    Text("\(i + 1)")
                                        .font(FinzyFont.heavy(13))
                                        .foregroundColor(i < 2 ? .finzyAccent : .finzyGray1)
                                        .frame(width: 18)
                                    Text(hotSearches[i])
                                        .font(FinzyFont.medium(12))
                                        .foregroundColor(.finzyCharcoal)
                                    Spacer()
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .background(Color.finzyWhite)
                                .cornerRadius(12)
                                .shadow(color: .black.opacity(0.04), radius: 4, y: 1)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }

                // 카테고리 탐색
                VStack(alignment: .leading, spacing: 10) {
                    Text("카테고리 탐색")
                        .font(FinzyFont.bold(14))
                        .foregroundColor(.finzyCharcoal)
                        .padding(.horizontal, 16)
                        .padding(.top, 20)

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 10) {
                        ForEach(ReviewCategory.allCases, id: \.self) { cat in
                            Button {
                                onTap(cat.rawValue)
                            } label: {
                                VStack(spacing: 6) {
                                    Text(cat.emoji).font(.system(size: 24))
                                    Text(cat.rawValue)
                                        .font(FinzyFont.bold(10))
                                        .foregroundColor(.finzyCharcoal)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.finzyWhite)
                                .cornerRadius(14)
                                .shadow(color: .black.opacity(0.04), radius: 4, y: 1)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }

                Spacer().frame(height: 30)
            }
        }
    }
}

// MARK: - 검색 결과
struct SearchResultView: View {
    let keyword: String
    let results: [ReviewResponseModel]
    let errorMessage: String?

    var body: some View {
        if let error = errorMessage {
            Spacer()
            VStack(spacing: 12) {
                Text("😢").font(.system(size: 44))
                Text(error)
                    .font(FinzyFont.medium(14))
                    .foregroundColor(.finzyGray1)
            }
            Spacer()
        } else if results.isEmpty {
            VStack(spacing: 12) {
                Spacer()
                Text("🔍").font(.system(size: 44))
                Text("'\(keyword)' 검색 결과가 없어요")
                    .font(FinzyFont.bold(15))
                    .foregroundColor(.finzyCharcoal)
                Text("첫 번째 리뷰를 작성해보세요!")
                    .font(FinzyFont.medium(13))
                    .foregroundColor(.finzyGray1)
                Spacer()
            }
        } else {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    // 결과 요약 카드
                    SearchSummaryCard(keyword: keyword, results: results)
                        .padding(.horizontal, 16)

                    // 결과 헤더
                    HStack {
                        Text("리뷰 \(results.count)개")
                            .font(FinzyFont.bold(13))
                            .foregroundColor(.finzyCharcoal)
                        Spacer()
                    }
                    .padding(.horizontal, 16)

                    // 리뷰 목록
                    ForEach(results) { review in
                        APIReviewCardView(review: review)
                            .padding(.horizontal, 16)
                    }

                    Spacer().frame(height: 20)
                }
                .padding(.top, 12)
            }
        }
    }
}

// MARK: - 검색 결과 요약 카드
struct SearchSummaryCard: View {
    let keyword: String
    let results: [ReviewResponseModel]

    var avgStars: Double {
        guard !results.isEmpty else { return 0 }
        return Double(results.map { $0.stars }.reduce(0, +)) / Double(results.count)
    }

    var verifiedCount: Int {
        results.filter { $0.isVerified }.count
    }

    // 많이 언급된 장점/단점 (간단히 첫 번째 것)
    var topPro: String { results.first?.pros ?? "" }
    var topCon: String { results.first?.cons ?? "" }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("✅ 인증 리뷰 종합")
                    .font(FinzyFont.bold(11))
                    .foregroundColor(.white.opacity(0.6))
                Spacer()
                Text("\(verifiedCount)개 인증")
                    .font(FinzyFont.bold(10))
                    .foregroundColor(.finzyGreen)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.finzyGreenSoft.opacity(0.2))
                    .cornerRadius(10)
            }

            HStack(alignment: .bottom, spacing: 10) {
                Text(String(format: "%.1f", avgStars))
                    .font(.system(size: 32, weight: .heavy))
                    .foregroundColor(.white)

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 2) {
                        ForEach(0..<5) { i in
                            Image(systemName: Double(i) < avgStars ? "star.fill" : "star")
                                .font(.system(size: 11))
                                .foregroundColor(.finzyYellow)
                        }
                    }
                    Text("리뷰 \(results.count)개")
                        .font(FinzyFont.medium(10))
                        .foregroundColor(.white.opacity(0.5))
                }
            }

            HStack(spacing: 8) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("👍 자주 언급된 장점")
                        .font(FinzyFont.bold(8))
                        .foregroundColor(.finzyGreen.opacity(0.8))
                        .textCase(.uppercase)
                    Text(topPro)
                        .font(FinzyFont.regular(10))
                        .foregroundColor(.white.opacity(0.8))
                        .lineLimit(2)
                }
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.finzyGreen.opacity(0.15))
                .cornerRadius(10)

                VStack(alignment: .leading, spacing: 3) {
                    Text("👎 자주 언급된 단점")
                        .font(FinzyFont.bold(8))
                        .foregroundColor(.finzyAccent.opacity(0.8))
                        .textCase(.uppercase)
                    Text(topCon)
                        .font(FinzyFont.regular(10))
                        .foregroundColor(.white.opacity(0.8))
                        .lineLimit(2)
                }
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.finzyAccent.opacity(0.15))
                .cornerRadius(10)
            }
        }
        .padding(14)
        .background(Color.finzyCharcoal)
        .cornerRadius(16)
    }
}

#Preview {
    SearchMainView()
}
