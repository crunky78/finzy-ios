import SwiftUI

// MARK: - ReviewDetailView
struct ReviewDetailView: View {
    let review: ReviewResponseModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {

                // 상품 이미지 영역
                ZStack(alignment: .bottomLeading) {
                    Rectangle()
                        .fill(Color.finzyGray3)
                        .frame(maxWidth: .infinity)
                        .frame(height: 240)

                    Text(review.categoryEmoji)
                        .font(.system(size: 80))
                        .frame(maxWidth: .infinity, maxHeight: 240)

                    // 카테고리 태그
                    Text(review.categoryEnum?.rawValue ?? review.category)
                        .font(FinzyFont.bold(11))
                        .foregroundColor(.finzyCharcoal)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(.white)
                        .cornerRadius(10)
                        .padding(16)
                }

                VStack(alignment: .leading, spacing: 16) {

                    // 유저 정보
                    HStack(spacing: 10) {
                        Circle()
                            .fill(LinearGradient(
                                colors: [.finzyAccent2, .finzyAccent],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(width: 40, height: 40)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(review.nickname)
                                .font(FinzyFont.bold(14))
                                .foregroundColor(.finzyCharcoal)
                            Text(review.timeAgoDisplay)
                                .font(FinzyFont.regular(11))
                                .foregroundColor(.finzyGray1)
                        }

                        Spacer()

                        Button { } label: {
                            Text("+ 팔로우")
                                .font(FinzyFont.bold(12))
                                .foregroundColor(.finzyAccent)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.finzyAccentSoft)
                                .cornerRadius(20)
                        }
                    }

                    Divider()

                    // 인증 뱃지
                    if let badge = review.verificationBadge {
                        HStack(spacing: 8) {
                            HStack(spacing: 5) {
                                Text(badge.icon).font(.system(size: 14))
                                Text(badge.label)
                                    .font(FinzyFont.bold(12))
                                    .foregroundColor(badge.color)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(badge.bgColor)
                            .cornerRadius(20)

                            Text(badge.description)
                                .font(FinzyFont.regular(11))
                                .foregroundColor(.finzyGray1)
                        }
                    }

                    // 상품 정보
                    VStack(alignment: .leading, spacing: 6) {
                        Text(review.productName)
                            .font(FinzyFont.heavy(20))
                            .foregroundColor(.finzyCharcoal)

                        HStack(spacing: 8) {
                            if let price = review.price {
                                Text("\(price.formatted())원")
                                    .font(FinzyFont.bold(15))
                                    .foregroundColor(.finzyCharcoal)
                            }
                            if let store = review.store {
                                Text("·")
                                    .foregroundColor(.finzyGray2)
                                Text(store)
                                    .font(FinzyFont.regular(13))
                                    .foregroundColor(.finzyGray1)
                            }
                        }

                        // 별점
                        HStack(spacing: 4) {
                            HStack(spacing: 2) {
                                ForEach(0..<5) { i in
                                    Image(systemName: i < review.stars ? "star.fill" : "star")
                                        .font(.system(size: 16))
                                        .foregroundColor(i < review.stars ? .finzyYellow : .finzyGray2)
                                }
                            }
                            Text("\(review.stars).0")
                                .font(FinzyFont.bold(15))
                                .foregroundColor(.finzyCharcoal)
                        }
                    }

                    Divider()

                    // 장단점
                    VStack(spacing: 10) {
                        // 장점
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 6) {
                                Text("👍")
                                Text("장점")
                                    .font(FinzyFont.bold(13))
                                    .foregroundColor(.finzyGreen)
                            }
                            Text(review.pros)
                                .font(FinzyFont.regular(13))
                                .foregroundColor(.finzyCharcoal)
                                .lineSpacing(4)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(12)
                                .background(Color.finzyGreenSoft)
                                .cornerRadius(12)
                        }

                        // 단점
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 6) {
                                Text("👎")
                                Text("단점")
                                    .font(FinzyFont.bold(13))
                                    .foregroundColor(.finzyAccent)
                            }
                            Text(review.cons)
                                .font(FinzyFont.regular(13))
                                .foregroundColor(.finzyCharcoal)
                                .lineSpacing(4)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(12)
                                .background(Color.finzyAccentSoft)
                                .cornerRadius(12)
                        }
                    }

                    // 한줄 코멘트
                    if let comment = review.comment, !comment.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("💬 한줄 코멘트")
                                .font(FinzyFont.bold(13))
                                .foregroundColor(.finzyCharcoal)
                            Text(comment)
                                .font(FinzyFont.regular(13))
                                .foregroundColor(.finzyCharcoal)
                                .lineSpacing(4)
                                .padding(12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.finzyGray3)
                                .cornerRadius(12)
                        }
                    }

                    Divider()

                    // 액션 버튼
                    HStack(spacing: 20) {
                        // 좋아요
                        Button { } label: {
                            HStack(spacing: 5) {
                                Image(systemName: "heart")
                                    .font(.system(size: 16))
                                Text("\(review.likeCount)")
                                    .font(FinzyFont.medium(13))
                            }
                            .foregroundColor(.finzyGray1)
                        }

                        // 댓글
                        Button { } label: {
                            HStack(spacing: 5) {
                                Image(systemName: "bubble.right")
                                    .font(.system(size: 16))
                                Text("\(review.commentCount)")
                                    .font(FinzyFont.medium(13))
                            }
                            .foregroundColor(.finzyGray1)
                        }

                        // 도움됐어요
                        Button { } label: {
                            HStack(spacing: 5) {
                                Image(systemName: "hand.thumbsup")
                                    .font(.system(size: 16))
                                Text("도움됐어요 \(review.helpfulCount)")
                                    .font(FinzyFont.medium(13))
                            }
                            .foregroundColor(.finzyGray1)
                        }

                        Spacer()

                        // 저장
                        Button { } label: {
                            Image(systemName: "bookmark")
                                .font(.system(size: 16))
                                .foregroundColor(.finzyGray1)
                        }
                    }

                    // 나도 샀어요 버튼
                    Button { } label: {
                        HStack {
                            Text("🛍️")
                            Text("나도 샀어요")
                                .font(FinzyFont.bold(15))
                            if review.meBuyCount > 0 {
                                Text("\(review.meBuyCount)명")
                                    .font(FinzyFont.medium(13))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color.finzyAccent)
                        .cornerRadius(16)
                    }
                }
                .padding(16)
            }
        }
        .background(Color.finzyWhite)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(review.productName)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button { } label: {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.finzyCharcoal)
                }
            }
        }
    }
}
