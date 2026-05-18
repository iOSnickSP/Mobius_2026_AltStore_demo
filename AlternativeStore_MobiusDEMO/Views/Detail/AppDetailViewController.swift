import UIKit
import Combine
import MarketplaceKit
import _MarketplaceKit_UIKit

/// App detail screen — shows full info and both install button variants.
/// Экран деталей приложения: полная информация и оба варианта кнопки установки.
///
/// Demonstrates / Демонстрирует:
/// 1. Custom install button (transparent ActionButton overlay pattern)
///    Кастомная кнопка установки (паттерн прозрачного оверлея над ActionButton)
/// 2. Standard `MarketplaceKit.ActionButton`
///    Стандартный `MarketplaceKit.ActionButton`
final class AppDetailViewController: UIViewController {

    private let viewModel: AppDetailViewModel
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init

    init(viewModel: AppDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Subviews

    private lazy var scrollView = UIScrollView()
    private lazy var contentStack: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.spacing = 0
        return s
    }()

    private lazy var customInstallButton = CustomInstallButton()
    private var standardActionButton: UIView?

    private lazy var installLogStack: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.spacing = 4
        s.isHidden = true
        return s
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = viewModel.app.name
        navigationItem.largeTitleDisplayMode = .never

        setupScrollView()
        buildContent()
        bindViewModel()
    }

    // MARK: - Layout

    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -40),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
        ])
    }

    private func buildContent() {
        let app = viewModel.app

        contentStack.addArrangedSubview(buildHeader(app))
        if let screenshots = app.screenshotPlaceholders, !screenshots.isEmpty {
            contentStack.addArrangedSubview(makeDivider())
            contentStack.addArrangedSubview(buildScreenshots(screenshots, tintHex: app.iconColorHex))
        }
        contentStack.addArrangedSubview(makeDivider())
        contentStack.addArrangedSubview(buildButtonSection(app))
        contentStack.addArrangedSubview(buildInstallLogSection())
        contentStack.addArrangedSubview(makeDivider())
        contentStack.addArrangedSubview(buildDescription(app))
        contentStack.addArrangedSubview(makeDivider())
        contentStack.addArrangedSubview(buildInfoSection(app))
    }

    // MARK: - Header

    private func buildHeader(_ app: AppModel) -> UIView {
        let iconView = UIView()
        iconView.backgroundColor = app.iconColor
        iconView.layer.cornerRadius = 22
        iconView.layer.cornerCurve = .continuous
        iconView.clipsToBounds = true
        iconView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 100),
            iconView.heightAnchor.constraint(equalToConstant: 100),
        ])

        let emoji = UILabel()
        emoji.text = app.iconEmoji
        emoji.font = .systemFont(ofSize: 36)
        emoji.textAlignment = .center
        iconView.addSubview(emoji)
        emoji.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            emoji.centerXAnchor.constraint(equalTo: iconView.centerXAnchor),
            emoji.centerYAnchor.constraint(equalTo: iconView.centerYAnchor),
        ])

        let nameLabel = UILabel()
        nameLabel.text = app.name
        nameLabel.font = .systemFont(ofSize: 22, weight: .bold)
        nameLabel.numberOfLines = 2

        let devLabel = UILabel()
        devLabel.text = app.developerName
        devLabel.font = .systemFont(ofSize: 15)
        devLabel.textColor = .secondaryLabel

        let metaLabel = UILabel()
        metaLabel.text = "\(app.priceLabel)  ·  \(app.formattedSize)"
        metaLabel.font = .systemFont(ofSize: 13)
        metaLabel.textColor = .secondaryLabel

        let textStack = UIStackView(arrangedSubviews: [nameLabel, devLabel, metaLabel])
        textStack.axis = .vertical
        textStack.spacing = 4

        let row = UIStackView(arrangedSubviews: [iconView, textStack])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 16

        return padded(row, insets: .init(top: 16, left: 20, bottom: 16, right: 20))
    }

    // MARK: - Screenshots

    private func buildScreenshots(_ items: [ScreenshotPlaceholder], tintHex: String?) -> UIView {
        let title = UILabel()
        title.text = "Screenshots"
        title.font = .systemFont(ofSize: 20, weight: .bold)

        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        scrollView.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            stack.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
            scrollView.heightAnchor.constraint(equalToConstant: 420),
        ])

        for item in items {
            let card = UIView()
            card.backgroundColor = colorFromHex(item.colorHex)
            card.layer.cornerRadius = 12
            card.layer.cornerCurve = .continuous
            card.clipsToBounds = true
            card.translatesAutoresizingMaskIntoConstraints = false
            card.widthAnchor.constraint(equalToConstant: 230).isActive = true

            let label = UILabel()
            label.text = item.label
            label.font = .systemFont(ofSize: 20, weight: .semibold)
            label.textColor = .white
            label.textAlignment = .center
            card.addSubview(label)
            label.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: card.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            ])

            stack.addArrangedSubview(card)
        }

        let outer = UIStackView(arrangedSubviews: [padded(title, insets: .init(top: 0, left: 20, bottom: 0, right: 20)), spacer(10), scrollView])
        outer.axis = .vertical
        return padded(outer, insets: .init(top: 16, left: 0, bottom: 16, right: 0))
    }

    private func colorFromHex(_ hex: String) -> UIColor {
        var rgb: UInt64 = 0
        Scanner(string: hex.trimmingCharacters(in: CharacterSet(charactersIn: "#")))
            .scanHexInt64(&rgb)
        return UIColor(
            red: CGFloat((rgb >> 16) & 0xFF) / 255,
            green: CGFloat((rgb >> 8) & 0xFF) / 255,
            blue: CGFloat(rgb & 0xFF) / 255,
            alpha: 1
        )
    }

    // MARK: - Buttons Section

    private func buildButtonSection(_ app: AppModel) -> UIView {
        let sectionLabel = UILabel()
        sectionLabel.text = "Install Buttons"
        sectionLabel.font = .systemFont(ofSize: 20, weight: .bold)

        // -- 1. Custom button --
        let customLabel = UILabel()
        customLabel.text = "Custom Button (overlay pattern)"
        customLabel.font = .systemFont(ofSize: 13)
        customLabel.textColor = .secondaryLabel

        customInstallButton.onSimulatorTap = { [weak self] in
            self?.viewModel.simulateInstall()
        }

        // -- 2. Standard ActionButton --
        let standardLabel = UILabel()
        standardLabel.text = "Standard MarketplaceKit.ActionButton"
        standardLabel.font = .systemFont(ofSize: 13)
        standardLabel.textColor = .secondaryLabel

        let standardContainer = buildStandardButton(app)

        let stack = UIStackView(arrangedSubviews: [
            sectionLabel,
            spacer(12),
            customLabel,
            spacer(6),
            customInstallButton,
            spacer(16),
            standardLabel,
            spacer(6),
            standardContainer,
        ])
        stack.axis = .vertical

        return padded(stack, insets: .init(top: 16, left: 20, bottom: 16, right: 20))
    }

    private func buildStandardButton(_ app: AppModel) -> UIView {
        #if targetEnvironment(simulator)
        let btn = UIButton(type: .system)
        btn.setTitle(app.isFree ? "Install" : app.price, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        btn.backgroundColor = .systemGray3
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 14
        btn.layer.cornerCurve = .continuous
        btn.clipsToBounds = true
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.heightAnchor.constraint(equalToConstant: 50).isActive = true
        btn.addTarget(self, action: #selector(standardSimulatorTapped), for: .touchUpInside)

        let badge = UILabel()
        badge.text = "Simulator fallback"
        badge.font = .systemFont(ofSize: 9)
        badge.textColor = .systemOrange
        badge.backgroundColor = .systemOrange.withAlphaComponent(0.15)
        badge.textAlignment = .center
        badge.layer.cornerRadius = 8
        badge.clipsToBounds = true

        let container = UIView()
        container.addSubview(btn)
        container.addSubview(badge)
        btn.translatesAutoresizingMaskIntoConstraints = false
        badge.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            btn.topAnchor.constraint(equalTo: container.topAnchor),
            btn.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            btn.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            btn.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            badge.topAnchor.constraint(equalTo: container.topAnchor, constant: -4),
            badge.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -8),
            badge.widthAnchor.constraint(equalToConstant: 100),
            badge.heightAnchor.constraint(equalToConstant: 16),
        ])
        self.standardActionButton = container
        return container
        #else
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.heightAnchor.constraint(equalToConstant: 50).isActive = true

        if let config = viewModel.makeInstallConfiguration() {
            let btn = ActionButton(action: .install(config))
            btn.backgroundColor = .systemGray3
            btn.layer.cornerRadius = 14
            btn.clipsToBounds = true
            container.addSubview(btn)
            btn.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                btn.topAnchor.constraint(equalTo: container.topAnchor),
                btn.bottomAnchor.constraint(equalTo: container.bottomAnchor),
                btn.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                btn.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            ])
        } else {
            let label = UILabel()
            label.text = "No ADP URL configured"
            label.textColor = .secondaryLabel
            label.textAlignment = .center
            container.addSubview(label)
            label.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: container.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            ])
        }
        self.standardActionButton = container
        return container
        #endif
    }

    @objc private func standardSimulatorTapped() {
        viewModel.simulateInstall()
    }

    // MARK: - Install Log

    private func buildInstallLogSection() -> UIView {
        return padded(installLogStack, insets: .init(top: 12, left: 20, bottom: 0, right: 20))
    }

    // MARK: - Description

    private func buildDescription(_ app: AppModel) -> UIView {
        let title = UILabel()
        title.text = "Description"
        title.font = .systemFont(ofSize: 20, weight: .bold)

        let body = UILabel()
        body.text = app.description
        body.font = .systemFont(ofSize: 15)
        body.textColor = .secondaryLabel
        body.numberOfLines = 0

        let stack = UIStackView(arrangedSubviews: [title, spacer(8), body])
        stack.axis = .vertical
        return padded(stack, insets: .init(top: 16, left: 20, bottom: 16, right: 20))
    }

    // MARK: - Info

    private func buildInfoSection(_ app: AppModel) -> UIView {
        let title = UILabel()
        title.text = "Information"
        title.font = .systemFont(ofSize: 20, weight: .bold)

        let rows: [(String, String)] = [
            ("Version", app.shortVersionString),
            ("Bundle ID", app.bundleId),
            ("Apple Item ID", "\(app.appleItemId)"),
            ("Apple Version ID", "\(app.appleVersionId)"),
            ("Size", app.formattedSize),
            ("Category", app.category),
        ]

        var views: [UIView] = [title, spacer(12)]
        for (label, value) in rows {
            views.append(makeInfoRow(label: label, value: value))
        }

        let stack = UIStackView(arrangedSubviews: views)
        stack.axis = .vertical
        stack.spacing = 8
        return padded(stack, insets: .init(top: 16, left: 20, bottom: 16, right: 20))
    }

    private func makeInfoRow(label: String, value: String) -> UIView {
        let l = UILabel()
        l.text = label
        l.font = .systemFont(ofSize: 14)
        l.textColor = .secondaryLabel
        l.setContentHuggingPriority(.required, for: .horizontal)

        let v = UILabel()
        v.text = value
        v.font = .systemFont(ofSize: 14, weight: .medium)
        v.textAlignment = .right
        v.numberOfLines = 0

        let row = UIStackView(arrangedSubviews: [l, v])
        row.axis = .horizontal
        row.spacing = 8
        return row
    }

    // MARK: - Binding

    private func bindViewModel() {
        viewModel.$installState
            .receive(on: RunLoop.main)
            .sink { [weak self] state in
                guard let self else { return }
                let config = viewModel.makeInstallConfiguration()
                customInstallButton.configure(
                    app: viewModel.app,
                    state: state,
                    configuration: config
                )
            }
            .store(in: &cancellables)

        viewModel.$installLog
            .receive(on: RunLoop.main)
            .sink { [weak self] entries in
                guard let self else { return }
                installLogStack.isHidden = entries.isEmpty

                while installLogStack.arrangedSubviews.count < entries.count {
                    let idx = installLogStack.arrangedSubviews.count
                    let label = UILabel()
                    label.text = entries[idx]
                    label.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
                    label.textColor = .secondaryLabel
                    label.numberOfLines = 0
                    label.alpha = 0
                    installLogStack.addArrangedSubview(label)
                    UIView.animate(withDuration: 0.25) { label.alpha = 1 }
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Helpers

    private func makeDivider() -> UIView {
        let container = UIView()
        let line = UIView()
        line.backgroundColor = .separator
        container.addSubview(line)
        line.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            line.heightAnchor.constraint(equalToConstant: 0.5),
            line.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            line.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16),
            line.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            line.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
        ])
        return container
    }

    private func padded(_ view: UIView, insets: UIEdgeInsets) -> UIView {
        let container = UIView()
        container.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: container.topAnchor, constant: insets.top),
            view.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -insets.bottom),
            view.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: insets.left),
            view.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -insets.right),
        ])
        return container
    }

    private func spacer(_ height: CGFloat) -> UIView {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.heightAnchor.constraint(equalToConstant: height).isActive = true
        return v
    }
}
