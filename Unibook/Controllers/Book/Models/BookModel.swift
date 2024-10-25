import Foundation
import UIKit

struct BookModel: Codable {
    var id: UUID
    var bookTitle: String
    var author: String
    var genre: String
    var note: String
    var proccess: Int
    var rating: Int
    var bookImagePath: String?

    var bookImage: UIImage? {
        guard let path = bookImagePath else { return nil }
        return UIImage(contentsOfFile: path)
    }
}
