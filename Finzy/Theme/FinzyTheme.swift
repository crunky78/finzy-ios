import SwiftUI

// MARK: - Finzy 컬러 테마
extension Color {
    static let finzyAccent    = Color(hex: "#FF5C2E")
    static let finzyAccent2   = Color(hex: "#FF8C5A")
    static let finzyAccentSoft = Color(hex: "#FFF0EB")
    static let finzyCharcoal  = Color(hex: "#1A1A1A")
    static let finzyGray1     = Color(hex: "#888888")
    static let finzyGray2     = Color(hex: "#BBBBBB")
    static let finzyGray3     = Color(hex: "#EFEFEF")
    static let finzyGray4     = Color(hex: "#F7F6F3")
    static let finzyBg        = Color(hex: "#F0EDE6")
    static let finzyWhite     = Color(hex: "#FFFDF9")
    static let finzyGreen     = Color(hex: "#2ECC71")
    static let finzyGreenSoft = Color(hex: "#E8F8EE")
    static let finzyBlue      = Color(hex: "#2E86FF")
    static let finzyBlueSoft  = Color(hex: "#EBF3FF")
    static let finzyYellow    = Color(hex: "#F4A916")
    static let finzyYellowSoft = Color(hex: "#FFF8E6")

    // hex 초기화
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Finzy 폰트
struct FinzyFont {
    static func bold(_ size: CGFloat) -> Font { .system(size: size, weight: .bold) }
    static func heavy(_ size: CGFloat) -> Font { .system(size: size, weight: .heavy) }
    static func medium(_ size: CGFloat) -> Font { .system(size: size, weight: .medium) }
    static func regular(_ size: CGFloat) -> Font { .system(size: size, weight: .regular) }
}

// MARK: - 뱃지 타입
enum VerificationBadge {
    case card       // 💳 카드명세서
    case order      // 📦 주문번호
    case waybill    // 🚚 운송장
    case gift       // 🎁 선물받음
    case brand      // 📢 브랜드증정

    var icon: String {
        switch self {
        case .card:    return "💳"
        case .order:   return "📦"
        case .waybill: return "🚚"
        case .gift:    return "🎁"
        case .brand:   return "📢"
        }
    }

    var label: String {
        switch self {
        case .card:    return "카드 인증"
        case .order:   return "주문번호 인증"
        case .waybill: return "운송장 인증"
        case .gift:    return "선물받음"
        case .brand:   return "브랜드 증정"
        }
    }

    var color: Color {
        switch self {
        case .card:    return .finzyGreen
        case .order:   return .finzyBlue
        case .waybill: return Color(hex: "#9B5DE5")
        case .gift:    return .finzyYellow
        case .brand:   return .finzyGray1
        }
    }

    var bgColor: Color {
        switch self {
        case .card:    return .finzyGreenSoft
        case .order:   return .finzyBlueSoft
        case .waybill: return Color(hex: "#F3EDFF")
        case .gift:    return .finzyYellowSoft
        case .brand:   return .finzyGray3
        }
    }

    var description: String {
        switch self {
        case .card:    return "카드명세서로 실구매가 확인된 리뷰예요"
        case .order:   return "온라인 주문번호로 실구매가 확인된 리뷰예요"
        case .waybill: return "운송장 번호로 배송이 확인된 리뷰예요"
        case .gift:    return "구매 인증은 없지만 실제 사용 후기예요"
        case .brand:   return "브랜드로부터 제품을 제공받았어요"
        }
    }
}

// MARK: - 카테고리
enum ReviewCategory: String, CaseIterable {
    case beauty = "뷰티"
    case electronics = "전자기기"
    case food = "식품"
    case fashion = "패션"
    case interior = "인테리어"
    case pet = "반려동물"
    case book = "도서"
    case sports = "스포츠"
    case hobby = "취미"

    var emoji: String {
        switch self {
        case .beauty:      return "💄"
        case .electronics: return "📱"
        case .food:        return "🍱"
        case .fashion:     return "👗"
        case .interior:    return "🏠"
        case .pet:         return "🐶"
        case .book:        return "📚"
        case .sports:      return "⚽"
        case .hobby:       return "🧸"
        }
    }
}
