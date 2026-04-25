import SwiftUI

// MARK: - MyPageViewModel
@MainActor
class MyPageViewModel: ObservableObject {
    @Published var myReviews: [ReviewResponseModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var viewMode: ViewMode = .grid

    enum ViewMode { case grid, timeline }

    let userId = 1
    let nickname = "현화_소비일기"
    let followers = 128
    let following = 94

    var reviewCount: Int { myReviews.count }
    var verifiedCount: Int { myReviews.filter { $0.isVerified }.count }
    var verifiedRate: Int {
        guard reviewCount > 0 else { return 0 }
        return Int(Double(verifiedCount) / Double(reviewCount) * 100)
    }
    var thisMonthTotal: Int {
        myReviews.compactMap { $0.price }.reduce(0, +)
    }
    var categoryStats: [(String, Int)] {
        var stats: [String: Int] = [:]
        for review in myReviews {
            stats[review.category, default: 0] += (review.price ?? 0)
        }
        let total = stats.values.reduce(0, +)
        guard total > 0 else { return [] }
        return stats
            .sorted { $0.value > $1.value }
            .prefix(3)
            .map { (cat, amount) in
                let emoji = ReviewCategory.allCases.first { $0.name == cat }?.emoji ?? "🛍️"
                return ("\(emoji) \(cat)", Int(Double(amount) / Double(total) * 100))
            }
    }

    // 타임라인용 날짜별 그룹
    var groupedByDate: [(String, [ReviewResponseModel])] {
        var groups: [String: [ReviewResponseModel]] = [:]
        for review in myReviews {
            let date = formatDate(review.createdAt ?? "")
            groups[date, default: []].append(review)
        }
        return groups.sorted { $0.key > $1.key }
    }

    func loadMyReviews() async {
        isLoading = true
        do {
            myReviews = try await ReviewAPI.shared.getMyReviews(userId: userId)
        } catch {
            errorMessage = "불러오기 실패"
        }
        isLoading = false
    }

    private func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        if let date = formatter.date(from: dateString) {
            let display = DateFormatter()
            display.dateFormat = "yyyy년 M월 d일"
            display.locale = Locale(identifier: "ko_KR")
            return display.string(from: date)
        }
        return dateString
    }
}

// MARK: - MyPageView
struct MyPageView: View {
    @StateObject private var viewModel = MyPageViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // 프로필
                    ProfileCardView(viewModel: viewModel)

                    // 소비 통계
                    if !viewModel.myReviews.isEmpty {
                        SpendingCardView(viewModel: viewModel)
                            .padding(.horizontal, 16)
                            .padding(.top, 16)
                    }

                    // 뷰 모드 토글
                    ViewModeToggle(viewMode: $viewModel.viewMode)
                        .padding(.horizontal, 16)
                        .padding(.top, 16)

                    // 컨텐츠
                    if viewModel.isLoading {
                        ProgressView().tint(.finzyAccent).padding(.top, 40)
                    } else if viewModel.myReviews.isEmpty {
                        EmptyDiaryView()
                    } else {
                        switch viewModel.viewMode {
                        case .grid:
                            GridDiaryView(reviews: viewModel.myReviews)
                                .padding(.top, 12)
                        case .timeline:
                            TimelineDiaryView(groups: viewModel.groupedByDate)
                                .padding(.top, 12)
                        }
                    }

                    Spacer().frame(height: 30)
                }
            }
            .background(Color.finzyBg)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("Finzy")
                        .font(.system(size: 24, weight: .heavy, design: .serif))
                        .foregroundColor(.finzyAccent)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { } label: {
                        Image(systemName: "gearshape")
                            .foregroundColor(.finzyCharcoal)
                    }
                }
            }
        }
        .task { await viewModel.loadMyReviews() }
    }
}

// MARK: - 프로필 카드
struct ProfileCardView: View {
    @ObservedObject var viewModel: MyPageViewModel

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            colors: [.finzyAccent2, .finzyAccent],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 64, height: 64)
                    Text("😊").font(.system(size: 30))
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.nickname)
                        .font(FinzyFont.heavy(18))
                        .foregroundColor(.finzyCharcoal)
                    HStack(spacing: 16) {
                        VStack(spacing: 1) {
                            Text("\(viewModel.followers)").font(FinzyFont.heavy(15)).foregroundColor(.finzyCharcoal)
                            Text("팔로워").font(FinzyFont.regular(11)).foregroundColor(.finzyGray1)
                        }
                        VStack(spacing: 1) {
                            Text("\(viewModel.following)").font(FinzyFont.heavy(15)).foregroundColor(.finzyCharcoal)
                            Text("팔로잉").font(FinzyFont.regular(11)).foregroundColor(.finzyGray1)
                        }
                    }
                }
                Spacer()
                Button { } label: {
                    Text("편집")
                        .font(FinzyFont.bold(12))
                        .foregroundColor(.finzyCharcoal)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(Color.finzyGray3)
                        .cornerRadius(20)
                }
            }
            .padding(16)

            Divider()

            HStack(spacing: 0) {
                StatItem(value: "\(viewModel.reviewCount)", label: "리뷰")
                Divider().frame(height: 32)
                StatItem(value: "\(viewModel.verifiedCount)", label: "인증")
                Divider().frame(height: 32)
                StatItem(value: "\(viewModel.verifiedRate)%", label: "인증률", highlight: true)
                Divider().frame(height: 32)
                StatItem(value: "\(viewModel.myReviews.map { $0.helpfulCount }.reduce(0, +))", label: "도움줬어요")
            }
            .padding(.vertical, 12)
        }
        .background(Color.finzyWhite)
    }
}

struct StatItem: View {
    let value: String
    let label: String
    var highlight: Bool = false

    var body: some View {
        VStack(spacing: 3) {
            Text(value).font(FinzyFont.heavy(18)).foregroundColor(highlight ? .finzyAccent : .finzyCharcoal)
            Text(label).font(FinzyFont.regular(10)).foregroundColor(.finzyGray1)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - 소비 통계 카드
struct SpendingCardView: View {
    @ObservedObject var viewModel: MyPageViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("📅 이번달 소비")
                    .font(FinzyFont.bold(11))
                    .foregroundColor(.white.opacity(0.6))
                Spacer()
                Text("총 \(viewModel.reviewCount)건")
                    .font(FinzyFont.bold(10))
                    .foregroundColor(.white.opacity(0.5))
            }
            Text("\(viewModel.thisMonthTotal.formatted())원")
                .font(.system(size: 26, weight: .heavy))
                .foregroundColor(.white)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4).fill(Color.white.opacity(0.15)).frame(height: 6)
                    RoundedRectangle(cornerRadius: 4).fill(Color.finzyAccent).frame(width: geo.size.width * 0.62, height: 6)
                }
            }
            .frame(height: 6)
            HStack(spacing: 8) {
                ForEach(viewModel.categoryStats, id: \.0) { cat in
                    Text("\(cat.0) \(cat.1)%")
                        .font(FinzyFont.bold(10))
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.horizontal, 8).padding(.vertical, 4)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(10)
                }
            }
        }
        .padding(16)
        .background(Color.finzyCharcoal)
        .cornerRadius(18)
    }
}

// MARK: - 뷰 모드 토글
struct ViewModeToggle: View {
    @Binding var viewMode: MyPageViewModel.ViewMode

    var body: some View {
        HStack(spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) { viewMode = .grid }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "square.grid.3x3")
                        .font(.system(size: 14))
                    Text("그리드")
                        .font(FinzyFont.bold(13))
                }
                .foregroundColor(viewMode == .grid ? .white : .finzyGray1)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(viewMode == .grid ? Color.finzyCharcoal : Color.clear)
                .cornerRadius(10)
            }
            Button {
                withAnimation(.easeInOut(duration: 0.2)) { viewMode = .timeline }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "list.bullet")
                        .font(.system(size: 14))
                    Text("타임라인")
                        .font(FinzyFont.bold(13))
                }
                .foregroundColor(viewMode == .timeline ? .white : .finzyGray1)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(viewMode == .timeline ? Color.finzyCharcoal : Color.clear)
                .cornerRadius(10)
            }
        }
        .padding(4)
        .background(Color.finzyGray3)
        .cornerRadius(14)
    }
}

// MARK: - 그리드 뷰
struct GridDiaryView: View {
    let reviews: [ReviewResponseModel]
    let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 3)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 2) {
            ForEach(reviews) { review in
                GridItemView(review: review)
            }
        }
        .padding(.horizontal, 16)
    }
}

struct GridItemView: View {
    let review: ReviewResponseModel

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // 배경
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.finzyGray3)
                .aspectRatio(1, contentMode: .fit)

            // 이모지
            Text(review.categoryEmoji)
                .font(.system(size: 36))
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            // 하단 정보
            VStack(alignment: .leading, spacing: 2) {
                Text(review.productName)
                    .font(FinzyFont.bold(9))
                    .foregroundColor(.white)
                    .lineLimit(1)
                HStack(spacing: 2) {
                    ForEach(0..<5) { i in
                        Image(systemName: i < review.stars ? "star.fill" : "star")
                            .font(.system(size: 7))
                            .foregroundColor(i < review.stars ? .finzyYellow : .white.opacity(0.4))
                    }
                }
            }
            .padding(8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                LinearGradient(
                    colors: [.clear, .black.opacity(0.6)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .cornerRadius(14)

            // 인증 뱃지
            if review.isVerified {
                Text("✅")
                    .font(.system(size: 12))
                    .padding(5)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            }
        }
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
    }
}

// MARK: - 타임라인 뷰
struct TimelineDiaryView: View {
    let groups: [(String, [ReviewResponseModel])]

    var body: some View {
        VStack(spacing: 0) {
            ForEach(groups, id: \.0) { date, reviews in
                VStack(alignment: .leading, spacing: 8) {
                    // 날짜 헤더
                    HStack {
                        Text(date)
                            .font(FinzyFont.bold(13))
                            .foregroundColor(.finzyGray1)
                        Spacer()
                        Text("\(reviews.count)건")
                            .font(FinzyFont.regular(11))
                            .foregroundColor(.finzyGray2)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                    // 해당 날짜 리뷰들
                    ForEach(reviews) { review in
                        TimelineCardView(review: review)
                            .padding(.horizontal, 16)
                    }
                }
            }
        }
    }
}

struct TimelineCardView: View {
    let review: ReviewResponseModel

    var body: some View {
        HStack(spacing: 12) {
            // 왼쪽 타임라인 라인
            VStack(spacing: 0) {
                Circle()
                    .fill(review.isVerified ? Color.finzyGreen : Color.finzyGray2)
                    .frame(width: 10, height: 10)
                Rectangle()
                    .fill(Color.finzyGray3)
                    .frame(width: 2)
            }
            .frame(width: 10)

            // 카드
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.finzyGray3)
                        .frame(width: 48, height: 48)
                    Text(review.categoryEmoji).font(.system(size: 22))
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(review.productName)
                        .font(FinzyFont.bold(13))
                        .foregroundColor(.finzyCharcoal)
                        .lineLimit(1)
                    HStack(spacing: 4) {
                        if let store = review.store {
                            Text(store).font(FinzyFont.regular(11)).foregroundColor(.finzyGray1)
                        }
                        if let price = review.price {
                            Text("· \(price.formatted())원").font(FinzyFont.regular(11)).foregroundColor(.finzyGray1)
                        }
                    }
                    HStack(spacing: 2) {
                        ForEach(0..<5) { i in
                            Image(systemName: i < review.stars ? "star.fill" : "star")
                                .font(.system(size: 9))
                                .foregroundColor(i < review.stars ? .finzyYellow : .finzyGray2)
                        }
                        if let badge = review.verificationBadge {
                            Text(badge.icon).font(.system(size: 9))
                            Text(badge.label)
                                .font(FinzyFont.bold(9))
                                .foregroundColor(badge.color)
                        }
                    }
                }

                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 11))
                    .foregroundColor(.finzyGray2)
            }
            .padding(10)
            .background(Color.finzyWhite)
            .cornerRadius(14)
            .shadow(color: .black.opacity(0.04), radius: 4, y: 1)
        }
        .padding(.bottom, 6)
    }
}

// MARK: - 빈 상태
struct EmptyDiaryView: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("📝").font(.system(size: 44))
            Text("아직 기록한 소비가 없어요\n첫 번째 리뷰를 작성해보세요!")
                .font(FinzyFont.medium(13))
                .foregroundColor(.finzyGray1)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

#Preview {
    MyPageView()
}
