import UIKit

final class NativeOnboardingViewController: UIViewController {
    enum Step {
        case welcome
        case permissions

        var title: String {
            switch self {
            case .welcome:
                return "Нативный iOS экран"
            case .permissions:
                return "Еще один native экран"
            }
        }

        var message: String {
            switch self {
            case .welcome:
                return "Здесь может быть welcome, авторизация или выбор региона."
            case .permissions:
                return "На этом шаге прогреваем Flutter engine перед переходом."
            }
        }

        var buttonTitle: String {
            switch self {
            case .welcome:
                return "Следующий native экран"
            case .permissions:
                return "Продолжить во Flutter"
            }
        }
    }

    private let step: Step

    init(step: Step) {
        self.step = step
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Native"
        configureLayout()

        if step == .permissions {
            FlutterCoordinator.shared.warmUp()
        }
    }

    private func configureLayout() {
        let titleLabel = UILabel()
        titleLabel.text = step.title
        titleLabel.font = .preferredFont(forTextStyle: .largeTitle)
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center

        let messageLabel = UILabel()
        messageLabel.text = step.message
        messageLabel.font = .preferredFont(forTextStyle: .body)
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center

        let button = UIButton(type: .system)
        button.setTitle(step.buttonTitle, for: .normal)
        button.titleLabel?.font = .preferredFont(forTextStyle: .headline)
        button.addTarget(self, action: #selector(didTapPrimaryButton), for: .touchUpInside)

        let stackView = UIStackView(arrangedSubviews: [titleLabel, messageLabel, button])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 24
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            stackView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
    }

    @objc
    private func didTapPrimaryButton() {
        switch step {
        case .welcome:
            navigationController?.pushViewController(
                NativeOnboardingViewController(step: .permissions),
                animated: true
            )
        case .permissions:
            let flutterViewController = FlutterCoordinator.shared.makeFlutterViewController()
            navigationController?.pushViewController(flutterViewController, animated: true)
        }
    }
}
