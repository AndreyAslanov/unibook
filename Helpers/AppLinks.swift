import Foundation

struct AppLinks {
    static let appShareURL: URL = {
        guard let url = URL(string: "https://apps.apple.com/us/app/unibook/id6737278261") else {
            fatalError("Invalid URL for appShareURL")
        }
        return url
    }()

    static let appStoreReviewURL: URL = {
        guard let url = URL(string: "https://apps.apple.com/us/app/unibook/id6737278261") else {
            fatalError("Invalid URL for appStoreReviewURL")
        }
        return url
    }()

    static let usagePolicyURL: URL = {
        guard let url = URL(string: "https://www.termsfeed.com/live/738f47ac-c4e2-47de-b897-98079742e0cf") else {
            fatalError("Invalid URL for usagePolicyURL")
        }
        return url
    }()
}
