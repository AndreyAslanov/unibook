import UIKit

final class MockGenresData {
    static let shared = MockGenresData()

    private init() {}

    let genres: [GenreModel] = [
        GenreModel(imageName: "genre_detectives", isSelected: false, index: 0),
        GenreModel(imageName: "genre_fantasy", isSelected: false, index: 1),
        GenreModel(imageName: "genre_classic", isSelected: false, index: 2),
        GenreModel(imageName: "genre_adventures", isSelected: false, index: 3),
        GenreModel(imageName: "genre_historical", isSelected: false, index: 4),
        GenreModel(imageName: "genre_psychology", isSelected: false, index: 5),
        GenreModel(imageName: "genre_romance", isSelected: false, index: 6),
        GenreModel(imageName: "genre_esotericism", isSelected: false, index: 7),
        GenreModel(imageName: "genre_children", isSelected: false, index: 8),
        GenreModel(imageName: "genre_religion", isSelected: false, index: 9),
        GenreModel(imageName: "genre_thriller", isSelected: false, index: 10),
        GenreModel(imageName: "genre_horrors", isSelected: false, index: 11)
    ]
}
