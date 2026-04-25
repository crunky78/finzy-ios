import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            FeedViewWithAPI()
                .tabItem {
                    Image(systemName: selectedTab == 0 ? "house.fill" : "house")
                    Text("피드")
                }
                .tag(0)

            RankingPlaceholderView()
                .tabItem {
                    Image(systemName: "flame\(selectedTab == 1 ? ".fill" : "")")
                    Text("랭킹")
                }
                .tag(1)

            WriteReviewPlaceholderView()
                .tabItem {
                    Image(systemName: "pencil.circle\(selectedTab == 2 ? ".fill" : "")")
                    Text("기록")
                }
                .tag(2)

            SearchMainView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("탐색")
                }
                .tag(3)

            MyPageView()
                .tabItem {
                    Image(systemName: "person\(selectedTab == 4 ? ".fill" : "")")
                    Text("마이")
                }
                .tag(4)
        }
        .tint(.finzyAccent)
    }
}

// MARK: - API 연동 피드뷰
struct FeedViewWithAPI: View {
    @StateObject private var viewModel = FeedViewModel()
    @State private var showWriteReview = false
    let feedTabs = ["전체", "팔로잉", "인기"]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 피드 탭
                HStack(spacing: 0) {
                    ForEach(feedTabs.indices, id: \.self) { i in
                        Button {
                            withAnimation { viewModel.selectedFeedTab = i }
                        } label: {
                            VStack(spacing: 4) {
                                Text(feedTabs[i])
                                    .font(FinzyFont.bold(13))
                                    .foregroundColor(viewModel.selectedFeedTab == i ? .finzyAccent : .finzyGray2)
                                Rectangle()
                                    .fill(viewModel.selectedFeedTab == i ? Color.finzyAccent : Color.clear)
                                    .frame(height: 2)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal, 16)

                Divider()

                // 카테고리 스크롤
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        CategoryChip(title: "전체", isSelected: viewModel.selectedCategory == nil) {
                            Task { await viewModel.changeCategory(nil) }
                        }
                        ForEach(ReviewCategory.allCases, id: \.self) { cat in
                            CategoryChip(
                                title: "\(cat.emoji) \(cat.rawValue)",
                                isSelected: viewModel.selectedCategory == cat.name
                            ) {
                                Task { await viewModel.changeCategory(cat.name) }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                }
                .background(Color.finzyWhite)

                Divider()

                // 피드 컨텐츠
                if viewModel.isLoading && viewModel.reviews.isEmpty {
                    Spacer()
                    ProgressView().tint(.finzyAccent)
                    Spacer()
                } else if let error = viewModel.errorMessage {
                    Spacer()
                    VStack(spacing: 12) {
                        Text("😢").font(.system(size: 44))
                        Text(error)
                            .font(FinzyFont.medium(14))
                            .foregroundColor(.finzyGray1)
                        Button("다시 시도") {
                            Task { await viewModel.loadFeed(reset: true) }
                        }
                        .font(FinzyFont.bold(13))
                        .foregroundColor(.finzyAccent)
                    }
                    Spacer()
                } else if viewModel.reviews.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Text("📭").font(.system(size: 44))
                        Text("아직 리뷰가 없어요\n첫 번째 리뷰를 작성해보세요!")
                            .font(FinzyFont.medium(14))
                            .foregroundColor(.finzyGray1)
                            .multilineTextAlignment(.center)
                    }
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.reviews) { review in
                                NavigationLink(destination: ReviewDetailView(review: review)) {
                                    APIReviewCardView(review: review)
                                }
                                .buttonStyle(.plain)
                                    .padding(.horizontal, 16)
                                    .onAppear {
                                        if review.id == viewModel.reviews.last?.id {
                                            Task { await viewModel.loadFeed() }
                                        }
                                    }
                            }
                            if viewModel.isLoading {
                                ProgressView().tint(.finzyAccent).padding()
                            }
                        }
                        .padding(.vertical, 12)
                    }
                    .background(Color.finzyBg)
                    .refreshable {
                        await viewModel.loadFeed(reset: true)
                    }
                }
            }
            .background(Color.finzyWhite)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("Finzy")
                        .font(.system(size: 24, weight: .heavy, design: .serif))
                        .foregroundColor(.finzyAccent)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 10) {
                        Button { } label: {
                            Image(systemName: "bell").foregroundColor(.finzyCharcoal)
                        }
                        Button { } label: {
                            Image(systemName: "magnifyingglass").foregroundColor(.finzyCharcoal)
                        }
                    }
                }
            }
            .overlay(alignment: .bottomTrailing) {
                Button { showWriteReview = true } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 52, height: 52)
                        .background(Color.finzyAccent)
                        .clipShape(Circle())
                        .shadow(color: .finzyAccent.opacity(0.5), radius: 10, y: 4)
                }
                .padding(.trailing, 20)
                .padding(.bottom, 16)
            }
        }
        .sheet(isPresented: $showWriteReview) {
            WriteReviewView {
                Task { await viewModel.loadFeed(reset: true) }
            }
        }
        .task {
            await viewModel.loadFeed(reset: true)
        }
    }
}

// MARK: - 카테고리 칩
struct CategoryChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(FinzyFont.bold(11))
                .foregroundColor(isSelected ? .white : .finzyGray1)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.finzyCharcoal : Color.finzyGray3)
                .cornerRadius(20)
        }
    }
}

// MARK: - 리뷰 카드 모델 (샘플용)
struct ReviewCard: Identifiable {
    let id = UUID()
    let username: String
    let timeAgo: String
    let badge: VerificationBadge
    let category: ReviewCategory
    let productName: String
    let price: String
    let store: String
    let stars: Int
    let pro: String
    let con: String
    let emoji: String
    let likes: Int
    let comments: Int
}

// MARK: - API 리뷰 카드뷰
struct APIReviewCardView: View {
    let review: ReviewResponseModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Circle()
                    .fill(LinearGradient(
                        colors: [.finzyAccent2, .finzyAccent],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 32, height: 32)

                VStack(alignment: .leading, spacing: 1) {
                    Text(review.nickname)
                        .font(FinzyFont.bold(12))
                        .foregroundColor(.finzyCharcoal)
                    Text(review.timeAgoDisplay)
                        .font(FinzyFont.regular(10))
                        .foregroundColor(.finzyGray1)
                }

                Spacer()

                if let badge = review.verificationBadge {
                    HStack(spacing: 3) {
                        Text(badge.icon).font(.system(size: 11))
                        Text(badge.label)
                            .font(FinzyFont.bold(10))
                            .foregroundColor(badge.color)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(badge.bgColor)
                    .cornerRadius(20)
                }
            }

            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.finzyGray3)
                    .frame(height: 100)
                Text(review.categoryEmoji)
                    .font(.system(size: 44))
                    .frame(maxWidth: .infinity, maxHeight: 100)
                Text(review.categoryEnum?.rawValue ?? review.category)
                    .font(FinzyFont.bold(9))
                    .foregroundColor(.finzyCharcoal)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(.white)
                    .cornerRadius(8)
                    .padding(8)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(review.productName)
                    .font(FinzyFont.bold(13))
                    .foregroundColor(.finzyCharcoal)
                HStack {
                    if let price = review.price {
                        Text("\(price.formatted())원")
                            .font(FinzyFont.medium(11))
                            .foregroundColor(.finzyCharcoal)
                    }
                    if let store = review.store {
                        Text("· \(store)")
                            .font(FinzyFont.regular(11))
                            .foregroundColor(.finzyGray1)
                    }
                }
            }

            HStack(spacing: 2) {
                ForEach(0..<5) { i in
                    Image(systemName: i < review.stars ? "star.fill" : "star")
                        .font(.system(size: 12))
                        .foregroundColor(i < review.stars ? .finzyYellow : .finzyGray2)
                }
            }

            HStack(spacing: 8) {
                ProConBox(text: review.pros, isPro: true)
                ProConBox(text: review.cons, isPro: false)
            }

            Divider()

            HStack(spacing: 14) {
                ActionButton(icon: "heart", count: review.likeCount)
                ActionButton(icon: "bubble.right", count: review.commentCount)
                ActionButton(icon: "bookmark", count: nil)
                Spacer()
                Text("나도 샀어요")
                    .font(FinzyFont.bold(11))
                    .foregroundColor(.finzyAccent)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 5)
                    .background(Color.finzyAccentSoft)
                    .cornerRadius(16)
            }
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(18)
        .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
    }
}

// MARK: - 장단점 박스
struct ProConBox: View {
    let text: String
    let isPro: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 4) {
            Text(isPro ? "👍" : "👎").font(.system(size: 10))
            Text(text)
                .font(FinzyFont.regular(10))
                .foregroundColor(isPro ? Color(hex: "#1A6035") : Color(hex: "#A03010"))
                .lineLimit(2)
                .lineSpacing(2)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(isPro ? Color.finzyGreenSoft : Color.finzyAccentSoft)
        .cornerRadius(10)
    }
}

// MARK: - 액션 버튼
struct ActionButton: View {
    let icon: String
    let count: Int?

    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: icon).font(.system(size: 14))
            if let count = count {
                Text("\(count)").font(FinzyFont.medium(11))
            }
        }
        .foregroundColor(.finzyGray1)
    }
}


// MARK: - 플레이스홀더 뷰들
struct RankingPlaceholderView: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("🔥").font(.system(size: 44))
            Text("랭킹").font(FinzyFont.heavy(20)).foregroundColor(.finzyCharcoal)
            Text("개발 예정").font(FinzyFont.medium(13)).foregroundColor(.finzyGray2)
        }
    }
}

struct WriteReviewPlaceholderView: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("✏️").font(.system(size: 44))
            Text("기록하기").font(FinzyFont.heavy(20)).foregroundColor(.finzyCharcoal)
            Text("개발 예정").font(FinzyFont.medium(13)).foregroundColor(.finzyGray2)
        }
    }
}


#Preview {
    MainTabView()
}
