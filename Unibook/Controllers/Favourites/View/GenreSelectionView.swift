import SnapKit
import UIKit

protocol GenreSelectionDelegate: AnyObject {
    func didSelectGenre(selectedIndex: Int)
}

final class GenreSelectionView: UIControl {
    private let mainContainerView = UIView()

    private let soccerView = UIImageView()
    private let sportView = UIImageView()
    private let detectivesView = UIImageView()
    private let fantasyView = UIImageView()
    private let classicView = UIImageView()
    private let adventuresView = UIImageView()
    private let historicalView = UIImageView()
    private let psychologyView = UIImageView()
    private let romanceView = UIImageView()
    private let esotericismView = UIImageView()
    private let childrenView = UIImageView()
    private let religionView = UIImageView()
    private let thrillerView = UIImageView()
    private let horrorsView = UIImageView()

    private let genreStackView = UIStackView()

    private var selectedIndex: Int? {
        didSet {
            updateViewsAppearance()
        }
    }

    private var views: [UIImageView] = []
    weak var delegate: GenreSelectionDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        soccerView.image = R.image.genre_soccer()
        sportView.image = R.image.genre_sport()
        detectivesView.image = R.image.genre_detectives()
        fantasyView.image = R.image.genre_fantasy()
        classicView.image = R.image.genre_classic()
        adventuresView.image = R.image.genre_adventures()
        historicalView.image = R.image.genre_historical()
        psychologyView.image = R.image.genre_psychology()
        romanceView.image = R.image.genre_romance()
        esotericismView.image = R.image.genre_esotericism()
        childrenView.image = R.image.genre_children()
        religionView.image = R.image.genre_religion()
        thrillerView.image = R.image.genre_thriller()
        horrorsView.image = R.image.genre_horrors()

        soccerView.isUserInteractionEnabled = true
        sportView.isUserInteractionEnabled = true
        detectivesView.isUserInteractionEnabled = true
        fantasyView.isUserInteractionEnabled = true
        classicView.isUserInteractionEnabled = true
        adventuresView.isUserInteractionEnabled = true
        historicalView.isUserInteractionEnabled = true
        psychologyView.isUserInteractionEnabled = true
        romanceView.isUserInteractionEnabled = true
        esotericismView.isUserInteractionEnabled = true
        childrenView.isUserInteractionEnabled = true
        religionView.isUserInteractionEnabled = true
        thrillerView.isUserInteractionEnabled = true
        horrorsView.isUserInteractionEnabled = true

        genreStackView.do { make in
            make.axis = .horizontal
            make.spacing = 8
            make.distribution = .fillEqually
            make.alignment = .leading
        }

        genreStackView.addArrangedSubview(soccerView)
        genreStackView.addArrangedSubview(sportView)
        genreStackView.addArrangedSubview(detectivesView)
        genreStackView.addArrangedSubview(fantasyView)
        genreStackView.addArrangedSubview(classicView)
        genreStackView.addArrangedSubview(adventuresView)
        genreStackView.addArrangedSubview(historicalView)
        genreStackView.addArrangedSubview(psychologyView)
        genreStackView.addArrangedSubview(romanceView)
        genreStackView.addArrangedSubview(esotericismView)
        genreStackView.addArrangedSubview(childrenView)
        genreStackView.addArrangedSubview(religionView)
        genreStackView.addArrangedSubview(thrillerView)
        genreStackView.addArrangedSubview(horrorsView)

        addSubviews(genreStackView)

        let tapGestureRecognizers = [
            UITapGestureRecognizer(target: self, action: #selector(genreTapped(_:))),
            UITapGestureRecognizer(target: self, action: #selector(genreTapped(_:))),
            UITapGestureRecognizer(target: self, action: #selector(genreTapped(_:))),
            UITapGestureRecognizer(target: self, action: #selector(genreTapped(_:))),
            UITapGestureRecognizer(target: self, action: #selector(genreTapped(_:))),
            UITapGestureRecognizer(target: self, action: #selector(genreTapped(_:))),
            UITapGestureRecognizer(target: self, action: #selector(genreTapped(_:))),
            UITapGestureRecognizer(target: self, action: #selector(genreTapped(_:))),
            UITapGestureRecognizer(target: self, action: #selector(genreTapped(_:))),
            UITapGestureRecognizer(target: self, action: #selector(genreTapped(_:))),
            UITapGestureRecognizer(target: self, action: #selector(genreTapped(_:))),
            UITapGestureRecognizer(target: self, action: #selector(genreTapped(_:))),
            UITapGestureRecognizer(target: self, action: #selector(genreTapped(_:))),
            UITapGestureRecognizer(target: self, action: #selector(genreTapped(_:)))
        ]
        
        soccerView.addGestureRecognizer(tapGestureRecognizers[0])
        sportView.addGestureRecognizer(tapGestureRecognizers[1])
        detectivesView.addGestureRecognizer(tapGestureRecognizers[2])
        fantasyView.addGestureRecognizer(tapGestureRecognizers[3])
        classicView.addGestureRecognizer(tapGestureRecognizers[4])
        adventuresView.addGestureRecognizer(tapGestureRecognizers[5])
        historicalView.addGestureRecognizer(tapGestureRecognizers[6])
        psychologyView.addGestureRecognizer(tapGestureRecognizers[7])
        romanceView.addGestureRecognizer(tapGestureRecognizers[8])
        esotericismView.addGestureRecognizer(tapGestureRecognizers[9])
        childrenView.addGestureRecognizer(tapGestureRecognizers[10])
        religionView.addGestureRecognizer(tapGestureRecognizers[11])
        thrillerView.addGestureRecognizer(tapGestureRecognizers[12])
        horrorsView.addGestureRecognizer(tapGestureRecognizers[13])

        views = [
            soccerView, sportView, detectivesView, fantasyView, classicView, adventuresView, historicalView, psychologyView,
            romanceView, esotericismView, childrenView, religionView, thrillerView, horrorsView
        ]
        updateViewsAppearance()
    }

    private func setupConstraints() {
        genreStackView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.bottom.equalToSuperview()
        }

        [soccerView, sportView, detectivesView, fantasyView, classicView, adventuresView, historicalView, psychologyView,
         romanceView, esotericismView, childrenView, religionView, thrillerView, horrorsView].forEach { view in
            view.snp.makeConstraints { make in
                make.height.equalTo(genreStackView.snp.height)
                make.width.equalTo(157)
            }
        }
    }

    @objc private func genreTapped(_ sender: UITapGestureRecognizer) {
        guard let tappedView = sender.view as? UIImageView else { return }
        guard let index = views.firstIndex(of: tappedView) else { return }

        if selectedIndex == index {
            selectedIndex = nil
        } else {
            selectedIndex = index
        }

        delegate?.didSelectGenre(selectedIndex: selectedIndex ?? -1)
    }

    private func updateViewsAppearance() {
        for (index, view) in views.enumerated() {
            if selectedIndex == index {
                view.layer.borderWidth = 2
                view.layer.cornerRadius = 8
                view.layer.borderColor = UIColor.white.cgColor
            } else {
                view.layer.borderWidth = 0
            }
        }
    }

    func configure(selectedIndex: Int?) {
        self.selectedIndex = selectedIndex
    }

    func configureForCell(selectedIndex: Int?) {
        self.selectedIndex = selectedIndex

        genreStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        for (index, view) in views.enumerated() {
            if selectedIndex == index {
                view.layer.borderWidth = 2
                view.layer.cornerRadius = 8
                view.layer.borderColor = UIColor.white.cgColor
            } else {
                view.layer.borderWidth = 0
                view.layer.borderColor = nil
            }
        }
    }
}
