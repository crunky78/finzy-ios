import Foundation
import SwiftUI

// MARK: - FeedViewModel
@MainActor
class FeedViewModel: ObservableObject {
    @Published var reviews: [ReviewResponseModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedCategory: String? = nil
    @Published var selectedFeedTab = 0

    private var currentPage = 0
    private var hasMore = true

    func loadFeed(reset: Bool = false) async {
        guard !isLoading else { return }

        if reset {
            currentPage = 0
            hasMore = true
            reviews = []
        }

        guard hasMore else { return }

        isLoading = true
        errorMessage = nil

        do {
            let response = try await ReviewAPI.shared.getFeed(
                page: currentPage,
                size: 10,
                category: selectedCategory
            )

            if reset {
                reviews = response.content
            } else {
                reviews.append(contentsOf: response.content)
            }

            hasMore = !response.last
            currentPage += 1
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func changeCategory(_ category: String?) async {
        selectedCategory = category
        await loadFeed(reset: true)
    }
}

// MARK: - ReviewCategory name 헬퍼
extension ReviewCategory {
    var name: String {
        switch self {
        case .beauty:      return "BEAUTY"
        case .electronics: return "ELECTRONICS"
        case .food:        return "FOOD"
        case .fashion:     return "FASHION"
        case .interior:    return "INTERIOR"
        case .pet:         return "PET"
        case .book:        return "BOOK"
        case .sports:      return "SPORTS"
        case .hobby:       return "HOBBY"
        }
    }
}
