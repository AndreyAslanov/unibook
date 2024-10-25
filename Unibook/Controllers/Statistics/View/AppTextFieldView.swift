import SnapKit
import UIKit

protocol AppTextFieldDelegate: AnyObject {
    func didTapTextField(type: AppTextFieldView.TextFieldType)
}

final class AppTextFieldView: UIControl {
    enum TextFieldType {
        case name
        case bookTitle
        case author
        case genre
        case feedback
        case note

        var placeholder: String {
            switch self {
            case .name: L.name()
            case .bookTitle: L.bookTitle()
            case .author: L.author()
            case .genre: L.genre()
            case .feedback: L.feedback()
            case .note: L.note()
            }
        }
    }

    private let type: TextFieldType
    weak var delegate: AppTextFieldDelegate?

    let textField = UITextField()
    let textView = UITextView()
    let placeholderLabel = UILabel()

    init(type: TextFieldType) {
        self.type = type
        super.init(frame: .zero)
        drawSelf()
        setupConstraints()
        configureButtonActions()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func drawSelf() {
        backgroundColor = .white.withAlphaComponent(0.2)
        layer.cornerRadius = 6
        
        if type == .feedback || type == .note {
            textView.do { make in
                make.font = .systemFont(ofSize: 17)
                make.textColor = .white
                make.textAlignment = .left
                make.backgroundColor = .clear
                make.delegate = self
                make.showsVerticalScrollIndicator = false
                make.showsHorizontalScrollIndicator = false
            }
            
            placeholderLabel.do { make in
                make.text = type.placeholder
                make.font = .systemFont(ofSize: 17)
                make.textColor = UIColor.white.withAlphaComponent(0.4)
                make.isHidden = !textView.text.isEmpty
            }

            addSubviews(textView, placeholderLabel)
        } else {
            textField.do { make in
                make.font = .systemFont(ofSize: 17)
                make.textColor = .white
                make.textAlignment = .left
                
                let placeholderColor = UIColor.white.withAlphaComponent(0.4)
                let placeholderFont = UIFont.systemFont(ofSize: 17)
                let placeholderText = type.placeholder
                
                textField.attributedPlaceholder = NSAttributedString(
                    string: placeholderText,
                    attributes: [
                        NSAttributedString.Key.foregroundColor: placeholderColor,
                        NSAttributedString.Key.font: placeholderFont
                    ]
                )
            }

            addSubviews(textField)
        }
    }

    private func setupConstraints() {
        if type == .feedback || type == .note {
            textView.snp.makeConstraints { make in
                make.top.bottom.equalToSuperview().inset(7)
                make.leading.trailing.equalToSuperview().inset(10)
            }
            
            placeholderLabel.snp.makeConstraints { make in
                make.top.equalTo(textView.snp.top).offset(7)
                make.leading.equalTo(textView.snp.leading).offset(5)
            }
        } else {
            textField.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview().inset(16)
                make.top.bottom.equalToSuperview()
            }
        }
    }

    private func configureButtonActions() {
        textView.delegate = self
        textView.isEditable = true
        NotificationCenter.default.addObserver(self, selector: #selector(textViewDidChangeNotification(_:)), name: UITextView.textDidChangeNotification, object: textView)
        addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        addTarget(self, action: #selector(didTapButton), for: .touchUpOutside)

        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }

    @objc private func textFieldDidChange(_ textField: UITextField) {
        delegate?.didTapTextField(type: type)
    }

    @objc private func didTapButton() {
        delegate?.didTapTextField(type: type)
    }

    @objc private func textViewDidChangeNotification(_ notification: Notification) {
        if let textView = notification.object as? UITextView {
            placeholderLabel.isHidden = !textView.text.isEmpty
            delegate?.didTapTextField(type: type)
        }
    }
}

// MARK: - UITextViewDelegate
extension AppTextFieldView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
        delegate?.didTapTextField(type: type)
    }
}
