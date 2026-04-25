import Foundation

// MARK: - API 응답 모델
struct ReviewResponseModel: Codable, Identifiable {
    let id: Int
    let userId: Int
    let nickname: String
    let profileImageUrl: String?
    let productName: String
    let category: String
    let price: Int?
    let store: String?
    let stars: Int
    let pros: String
    let cons: String
    let comment: String?
    let verificationType: String?
    let isVerified: Bool
    let likeCount: Int
    let commentCount: Int
    let helpfulCount: Int
    let meBuyCount: Int
    let createdAt: String?
}

// MARK: - 페이지 응답
struct PageResponse<T: Codable>: Codable {
    let content: [T]
    let totalElements: Int
    let totalPages: Int
    let number: Int
    let size: Int
    let last: Bool
}

// MARK: - 리뷰 작성 요청
struct ReviewRequestModel: Codable {
    let productName: String
    let category: String
    let price: Int?
    let store: String?
    let stars: Int
    let pros: String
    let cons: String
    let comment: String?
    let verificationType: String?
    let isPublic: Bool
    
    enum CodingKeys: String, CodingKey {
        case productName
        case category
        case price
        case store
        case stars
        case pros
        case cons
        case comment
        case verificationType
        case isPublic
    }
}

// MARK: - ReviewAPI
class ReviewAPI {
    static let shared = ReviewAPI()
    private init() {}
    
    // 피드 조회
    func getFeed(page: Int = 0, size: Int = 10, category: String? = nil) async throws -> PageResponse<ReviewResponseModel> {
        var path = "/reviews?page=\(page)&size=\(size)"
        if let category = category, category != "ALL" {
            path += "&category=\(category)"
        }
        return try await APIClient.shared.get(path: path)
    }
    
    // 검색
    func searchReviews(keyword: String, verifiedOnly: Bool = false, page: Int = 0) async throws -> PageResponse<ReviewResponseModel> {
        let encodedKeyword = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? keyword
        let path = "/reviews/search?keyword=\(encodedKeyword)&verifiedOnly=\(verifiedOnly)&page=\(page)"
        return try await APIClient.shared.get(path: path)
    }
    
    // 리뷰 상세
    func getReview(id: Int) async throws -> ReviewResponseModel {
        return try await APIClient.shared.get(path: "/reviews/\(id)")
    }
    
    // 리뷰 작성
    func createReview(userId: Int, request: ReviewRequestModel) async throws -> ReviewResponseModel {
        return try await APIClient.shared.post(path: "/reviews?userId=\(userId)", body: request)
    }
    
    // 내 리뷰
    func getMyReviews(userId: Int) async throws -> [ReviewResponseModel] {
        return try await APIClient.shared.get(path: "/reviews/my?userId=\(userId)")
    }
    
    // 랭킹
    func getRanking(limit: Int = 10) async throws -> [ReviewResponseModel] {
        return try await APIClient.shared.get(path: "/reviews/ranking?limit=\(limit)")
    }
}

// MARK: - 카테고리 변환 헬퍼
extension ReviewResponseModel {
    var categoryEnum: ReviewCategory? {
        switch category {
        case "BEAUTY":      return .beauty
        case "ELECTRONICS": return .electronics
        case "FOOD":        return .food
        case "FASHION":     return .fashion
        case "INTERIOR":    return .interior
        case "PET":         return .pet
        case "BOOK":        return .book
        case "SPORTS":      return .sports
        case "HOBBY":       return .hobby
        default:            return nil
        }
    }
    
    var verificationBadge: VerificationBadge? {
        switch verificationType {
        case "CARD":    return .card
        case "ORDER":   return .order
        case "WAYBILL": return .waybill
        case "GIFT":    return .gift
        case "BRAND":   return .brand
        default:        return nil
        }
    }
    
    var categoryEmoji: String {
        return categoryEnum?.emoji ?? "🛍️"
    }
    
    var starsDisplay: String {
        return String(repeating: "⭐", count: stars)
    }
    
    var timeAgoDisplay: String {
        guard let dateString = createdAt else { return "방금 전(nil)" }
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        
        guard let date = formatter.date(from: dateString) else {
            return "파싱실패:\(dateString)" // 이게 뜨면 포맷 문제
        }
        
        let now = Date()
        let diff = Int(now.timeIntervalSince(date))
        
        switch diff {
        case ..<60:
            return "방금 전"
        case 60..<3600:
            return "\(diff / 60)분 전"
        case 3600..<86400:
            return "\(diff / 3600)시간 전"
        case 86400..<604800:
            return "\(diff / 86400)일 전"
        default:
            let display = DateFormatter()
            display.dateFormat = "M월 d일"
            display.locale = Locale(identifier: "ko_KR")
            return display.string(from: date)
        }
    }
}
