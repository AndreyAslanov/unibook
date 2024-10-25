import Foundation
import UIKit

struct FavouriteModel: Codable {
    var id: UUID
    var bookTitle: String
    var author: String
    var genre: String
    var feedback: String
    var proccess: Int
    var rating: Int
    var genreIndex: Int
    var favImagePath: String?
    
    var favImage: UIImage? {
        guard let path = favImagePath else { return nil }
        return UIImage(contentsOfFile: path)
    }
}
