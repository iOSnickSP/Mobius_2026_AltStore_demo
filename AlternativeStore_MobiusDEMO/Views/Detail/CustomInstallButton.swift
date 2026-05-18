import UIKit
import MarketplaceKit
import _MarketplaceKit_UIKit

/// Custom-styled install button with a transparent `MarketplaceKit.ActionButton` overlay.
///
/// Implements the transparent overlay pattern:
/// 1. A styled "skin" layer renders the visual button.
/// 2. On a real device, a transparent `ActionButton` sits on top and captures taps.
/// 3. On the simulator, a `UIButton` handles taps with mock behaviour.
final class CustomInstallButton: UIView {

    // MARK: - Public

    var onSimulatorTap: (() -> Void)?

    func configure(app: AppModel, state: AppInstallState, configuration: InstallConfiguration?) {
        self.currentApp = app
        self.installConfiguration = configuration
        updateSkin(for: state)
        updateOverlay(for: state, configuration: configuration)
    }

    // MARK: - Private state

    private var currentApp: AppModel?
    private var installConfiguration: InstallConfiguration?
    private var actionButton: ActionButton?

    // MARK: - Subviews

    private let skinLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 16, weight: .bold)
        l.textAlignment = .center
        return l
    }()

    private let skinBackground: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 14
        v.layer.cornerCurve = .continuous
        v.clipsToBounds = true
        return v
    }()

    private let progressView: UIProgressView = {
        let pv = UIProgressView(progressViewStyle: .default)
        pv.tintColor = .systemBlue
        pv.isHidden = true
        return pv
    }()

    private lazy var simulatorButton: UIButton = {
        let b = UIButton(type: .system)
        b.addTarget(self, action: #selector(simulatorTapped), for: .touchUpInside)
        b.backgroundColor = .clear
        return b
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Layout

    private func setupLayout() {
        addSubview(skinBackground)
        skinBackground.addSubview(skinLabel)
        addSubview(progressView)

        skinBackground.translatesAutoresizingMaskIntoConstraints = false
        skinLabel.translatesAutoresizingMaskIntoConstraints = false
        progressView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            skinBackground.topAnchor.constraint(equalTo: topAnchor),
            skinBackground.bottomAnchor.constraint(equalTo: bottomAnchor),
            skinBackground.leadingAnchor.constraint(equalTo: leadingAnchor),
            skinBackground.trailingAnchor.constraint(equalTo: trailingAnchor),
            skinBackground.heightAnchor.constraint(equalToConstant: 50),

            skinLabel.centerXAnchor.constraint(equalTo: skinBackground.centerXAnchor),
            skinLabel.centerYAnchor.constraint(equalTo: skinBackground.centerYAnchor),

            progressView.centerXAnchor.constraint(equalTo: centerXAnchor),
            progressView.centerYAnchor.constraint(equalTo: centerYAnchor),
            progressView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            progressView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
        ])

        #if targetEnvironment(simulator)
        addSubview(simulatorButton)
        simulatorButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            simulatorButton.topAnchor.constraint(equalTo: topAnchor),
            simulatorButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            simulatorButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            simulatorButton.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
        #endif
    }

    // MARK: - Skin

    private func updateSkin(for state: AppInstallState) {
        progressView.isHidden = true
        skinBackground.isHidden = false

        switch state {
        case .available:
            let label = currentApp?.isFree == true ? "Install" : (currentApp?.price ?? "Install")
            skinLabel.text = label
            skinLabel.textColor = .white
            skinBackground.backgroundColor = .systemBlue

        case .installing(let progress):
            skinBackground.isHidden = true
            progressView.isHidden = false
            progressView.setProgress(Float(progress ?? 0), animated: true)

        case .installed:
            skinLabel.text = "Open"
            skinLabel.textColor = .systemBlue
            skinBackground.backgroundColor = .systemBlue.withAlphaComponent(0.12)
        }
    }

    // MARK: - ActionButton Overlay

    private func updateOverlay(for state: AppInstallState, configuration: InstallConfiguration?) {
        #if !targetEnvironment(simulator)
        actionButton?.removeFromSuperview()
        actionButton = nil

        guard let config = configuration else { return }

        switch state {
        case .available:
            let btn = ActionButton(action: .install(config))
            btn.backgroundColor = .clear
            addSubview(btn)
            btn.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                btn.topAnchor.constraint(equalTo: topAnchor),
                btn.bottomAnchor.constraint(equalTo: bottomAnchor),
                btn.leadingAnchor.constraint(equalTo: leadingAnchor),
                btn.trailingAnchor.constraint(equalTo: trailingAnchor),
            ])
            actionButton = btn

        case .installed:
            guard let app = currentApp else { return }
            let btn = ActionButton(action: .launch(AppleItemID(app.appleItemId)))
            btn.backgroundColor = .clear
            addSubview(btn)
            btn.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                btn.topAnchor.constraint(equalTo: topAnchor),
                btn.bottomAnchor.constraint(equalTo: bottomAnchor),
                btn.leadingAnchor.constraint(equalTo: leadingAnchor),
                btn.trailingAnchor.constraint(equalTo: trailingAnchor),
            ])
            actionButton = btn

        case .installing:
            break
        }
        #endif
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        actionButton?.size = bounds.size
    }

    @objc private func simulatorTapped() {
        onSimulatorTap?()
    }
}
