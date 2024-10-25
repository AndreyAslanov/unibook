import SnapKit
import UIKit

final class StatisticsViewController: UIViewController {
    private let backgroungImageView = UIImageView()
    private let statisticsLabel = UILabel()
    private let lastYearView = LastYearView()
    private let readingView = StatisticsView(type: .reading)
    private let timeView = StatisticsView(type: .time)
    private let genreView = StatisticsView(type: .genre)
    private let authorView = StatisticsView(type: .author)
    private let languageView = LanguageView()

    override func viewDidLoad() {
        super.viewDidLoad()

        let navigationBarAppearance = UINavigationBar.appearance()
        navigationBarAppearance.barTintColor = UIColor.black
        navigationBarAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]

        view.backgroundColor = .clear

        drawself()
        lastYearView.delegate = self
        readingView.delegate = self
        timeView.delegate = self
        genreView.delegate = self
        authorView.delegate = self
        languageView.delegate = self

        if let bookName = LastYearBooksDataManager.shared.fetchData() {
            lastYearView.configureBookValueLabel(with: bookName)
        }

        if let pagesName = LastYearPagesDataManager.shared.fetchData() {
            lastYearView.configurePageValueLabel(with: pagesName)
        }
        
        if let readingData = StatisticsDataManager.shared.fetchData(for: .reading) {
            readingView.configureValueLabel(with: readingData)
        }

        if let timeData = StatisticsDataManager.shared.fetchData(for: .time) {
            timeView.configureValueLabel(with: timeData)
        }

        if let genreData = StatisticsDataManager.shared.fetchData(for: .genre) {
            genreView.configureValueLabel(with: genreData)
        }

        if let authorData = StatisticsDataManager.shared.fetchData(for: .author) {
            authorView.configureValueLabel(with: authorData)
        }
    }

    private func drawself() {
        backgroungImageView.image = R.image.launch_background()

        statisticsLabel.do { make in
            make.text = L.statistics()
            make.font = .systemFont(ofSize: 28, weight: .bold)
            make.textColor = .white
            make.textAlignment = .left
        }

        view.addSubviews(
            backgroungImageView, statisticsLabel, lastYearView, 
            readingView, timeView, genreView, authorView, languageView
        )

        backgroungImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        statisticsLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(13.5)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(-5)
        }

        lastYearView.snp.makeConstraints { make in
            make.top.equalTo(statisticsLabel.snp.bottom).offset(18)
            make.leading.trailing.equalToSuperview().inset(12)
            make.height.equalTo(193)
        }
        
        readingView.snp.makeConstraints { make in
            make.top.equalTo(lastYearView.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(16)
            make.width.equalToSuperview().dividedBy(2).offset(-20)
            if UIDevice.isIphoneBelowX {
                make.height.equalTo(110)
            } else {
                make.height.equalTo(128)
            }
        }
        
        timeView.snp.makeConstraints { make in
            make.top.equalTo(lastYearView.snp.bottom).offset(16)
            make.trailing.equalToSuperview().inset(16)
            make.width.equalToSuperview().dividedBy(2).offset(-20)
            if UIDevice.isIphoneBelowX {
                make.height.equalTo(110)
            } else {
                make.height.equalTo(128)
            }
        }
        
        genreView.snp.makeConstraints { make in
            make.top.equalTo(readingView.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(16)
            make.width.equalToSuperview().dividedBy(2).offset(-20)
            if UIDevice.isIphoneBelowX {
                make.height.equalTo(110)
            } else {
                make.height.equalTo(128)
            }
        }
        
        authorView.snp.makeConstraints { make in
            make.top.equalTo(readingView.snp.bottom).offset(8)
            make.trailing.equalToSuperview().inset(16)
            make.width.equalToSuperview().dividedBy(2).offset(-20)
            if UIDevice.isIphoneBelowX {
                make.height.equalTo(110)
            } else {
                make.height.equalTo(128)
            }
        }
        
        languageView.snp.makeConstraints { make in
            make.top.equalTo(authorView.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(15)
            if UIDevice.isIphoneBelowX {
                make.height.equalTo(65)
            } else {
                make.height.equalTo(73)
            }
        }
    }
}

// MARK: - LastYearViewDelegate
extension StatisticsViewController: LastYearViewDelegate {
    func didTapBookButton() {
        let alertController = UIAlertController(title: L.numberBooks(), message: L.trackProgress(), preferredStyle: .alert)

        alertController.addTextField { textField in
            textField.placeholder = "0"
            textField.keyboardType = .phonePad
        }

        let cancelAction = UIAlertAction(title: L.close(), style: .default, handler: nil)

        let saveAction = UIAlertAction(title: L.save(), style: .cancel) { _ in
            guard let nameText = alertController.textFields?[0].text,
                  !nameText.isEmpty else {
                return
            }

            LastYearBooksDataManager.shared.saveData(nameText)
            self.lastYearView.configureBookValueLabel(with: nameText)
        }

        saveAction.setValue(UIColor(hex: "#0A84FF"), forKey: "titleTextColor")
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        alertController.overrideUserInterfaceStyle = .dark

        present(alertController, animated: true, completion: nil)
    }

    func didTapPageButton() {
        let alertController = UIAlertController(title: L.numberBooks(), message: L.trackProgress(), preferredStyle: .alert)

        alertController.addTextField { textField in
            textField.placeholder = "0"
            textField.keyboardType = .phonePad
        }

        let cancelAction = UIAlertAction(title: L.close(), style: .default, handler: nil)

        let saveAction = UIAlertAction(title: L.save(), style: .cancel) { _ in
            guard let nameText = alertController.textFields?[0].text,
                  !nameText.isEmpty else {
                return
            }

            LastYearPagesDataManager.shared.saveData(nameText)
            self.lastYearView.configurePageValueLabel(with: nameText)
        }

        saveAction.setValue(UIColor(hex: "#0A84FF"), forKey: "titleTextColor")
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        alertController.overrideUserInterfaceStyle = .dark

        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - StatisticsViewDelegate
extension StatisticsViewController: StatisticsViewDelegate {
    func didTapView(type: StatisticsView.StatisticsType) {
        switch type {
        case .reading:
            showReadingStatistics()
        case .time:
            showTimeStatistics()
        case .genre:
            showGenreStatistics()
        case .author:
            showAuthorStatistics()
        }
    }
    
    private func showReadingStatistics() {
        let alertController = UIAlertController(title: L.readingStat(), message: L.trackProgress(), preferredStyle: .alert)

        alertController.addTextField { textField in
            textField.placeholder = "Placeholder"
            textField.keyboardType = .default
        }

        let cancelAction = UIAlertAction(title: L.close(), style: .default, handler: nil)

        let saveAction = UIAlertAction(title: L.save(), style: .cancel) { _ in
            guard let nameText = alertController.textFields?[0].text,
                  !nameText.isEmpty else {
                return
            }

            StatisticsDataManager.shared.saveData(.reading, value: nameText)
            self.readingView.configureValueLabel(with: nameText)
        }

        saveAction.setValue(UIColor(hex: "#0A84FF"), forKey: "titleTextColor")
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        alertController.overrideUserInterfaceStyle = .dark

        present(alertController, animated: true, completion: nil)
    }
    
    private func showTimeStatistics() {
        let alertController = UIAlertController(title: L.timeStat(), message: L.trackProgress(), preferredStyle: .alert)

        alertController.addTextField { textField in
            textField.placeholder = "Placeholder"
            textField.keyboardType = .default
        }

        let cancelAction = UIAlertAction(title: L.close(), style: .default, handler: nil)

        let saveAction = UIAlertAction(title: L.save(), style: .cancel) { _ in
            guard let nameText = alertController.textFields?[0].text,
                  !nameText.isEmpty else {
                return
            }

            StatisticsDataManager.shared.saveData(.time, value: nameText)
            self.timeView.configureValueLabel(with: nameText)
        }

        saveAction.setValue(UIColor(hex: "#0A84FF"), forKey: "titleTextColor")
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        alertController.overrideUserInterfaceStyle = .dark

        present(alertController, animated: true, completion: nil)
    }    
    
    private func showGenreStatistics() {
        let alertController = UIAlertController(title: L.genreStat(), message: L.trackProgress(), preferredStyle: .alert)

        alertController.addTextField { textField in
            textField.placeholder = "Placeholder"
            textField.keyboardType = .default
        }

        let cancelAction = UIAlertAction(title: L.close(), style: .default, handler: nil)

        let saveAction = UIAlertAction(title: L.save(), style: .cancel) { _ in
            guard let nameText = alertController.textFields?[0].text,
                  !nameText.isEmpty else {
                return
            }

            StatisticsDataManager.shared.saveData(.genre, value: nameText)
            self.genreView.configureValueLabel(with: nameText)
        }

        saveAction.setValue(UIColor(hex: "#0A84FF"), forKey: "titleTextColor")
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        alertController.overrideUserInterfaceStyle = .dark

        present(alertController, animated: true, completion: nil)
    }    
    
    private func showAuthorStatistics() {
        let alertController = UIAlertController(title: L.authorStat(), message: L.trackProgress(), preferredStyle: .alert)

        alertController.addTextField { textField in
            textField.placeholder = "Placeholder"
            textField.keyboardType = .default
        }

        let cancelAction = UIAlertAction(title: L.close(), style: .default, handler: nil)

        let saveAction = UIAlertAction(title: L.save(), style: .cancel) { _ in
            guard let nameText = alertController.textFields?[0].text,
                  !nameText.isEmpty else {
                return
            }

            StatisticsDataManager.shared.saveData(.author, value: nameText)
            self.authorView.configureValueLabel(with: nameText)
        }

        saveAction.setValue(UIColor(hex: "#0A84FF"), forKey: "titleTextColor")
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        alertController.overrideUserInterfaceStyle = .dark

        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - LanguageViewDelegate
extension StatisticsViewController: LanguageViewDelegate {
    func didTapLanguageButton() {
        let alertController = UIAlertController(title: L.favLanguage(), message: L.trackProgress(), preferredStyle: .alert)

        alertController.addTextField { textField in
            textField.placeholder = "Placeholder"
            textField.keyboardType = .default
        }

        let cancelAction = UIAlertAction(title: L.close(), style: .default, handler: nil)

        let saveAction = UIAlertAction(title: L.save(), style: .cancel) { _ in
            guard let nameText = alertController.textFields?[0].text,
                  !nameText.isEmpty else {
                return
            }

            LanguageDataManager.shared.saveData(nameText)
            self.languageView.configureValueLabel(with: nameText)
        }

        saveAction.setValue(UIColor(hex: "#0A84FF"), forKey: "titleTextColor")
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        alertController.overrideUserInterfaceStyle = .dark

        present(alertController, animated: true, completion: nil)
    }
}
