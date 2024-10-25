import Foundation
import UIKit

struct GenreModel: Codable {
    var imageName: String 
    var isSelected: Bool
    var index: Int

    var image: UIImage? {
        return UIImage(named: imageName)
    }
}
