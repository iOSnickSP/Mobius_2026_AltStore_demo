import UIKit
import Combine

/// Feed screen — displays a list of available apps in the marketplace.
/// Tapping a row pushes `AppDetailViewController`.
final class FeedViewController: UIViewController {

    private let viewModel: FeedViewModel
    private let appLibraryProvider: AppLibraryServiceImpl
    private let installationService: InstallationSupportService
    private let networkService: NetworkService
    private var cancellables = Set<AnyCancellable>()

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.register(AppCell.self, forCellReuseIdentifier: AppCell.reuseID)
        tv.dataSource = self
        tv.delegate = self
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = 84
        return tv
    }()

    private let activityIndicator = UIActivityIndicatorView(style: .large)

    private var apps: [AppModel] = []

    // MARK: - Init

    init(
        viewModel: FeedViewModel,
        appLibraryProvider: AppLibraryServiceImpl,
        installationService: InstallationSupportService,
        networkService: NetworkService
    ) {
        self.viewModel = viewModel
        self.appLibraryProvider = appLibraryProvider
        self.installationService = installationService
        self.networkService = networkService
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Marketplace"
        view.backgroundColor = .systemBackground

        if MarketplaceConfiguration.useMockData {
            let badge = UIBarButtonItem(
                title: "MOCK",
                style: .plain,
                target: nil,
                action: nil
            )
            badge.tintColor = .systemOrange
            badge.isEnabled = false
            navigationItem.rightBarButtonItem = badge
        }

        view.addSubview(tableView)
        view.addSubview(activityIndicator)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])

        bindViewModel()
        viewModel.loadApps()
    }

    // MARK: - Binding

    private func bindViewModel() {
        viewModel.$state
            .receive(on: RunLoop.main)
            .sink { [weak self] state in
                guard let self else { return }
                switch state {
                case .loading:
                    activityIndicator.startAnimating()
                    tableView.isHidden = true
                case .loaded(let apps):
                    self.apps = apps
                    activityIndicator.stopAnimating()
                    tableView.isHidden = false
                    tableView.reloadData()
                case .error(let message):
                    activityIndicator.stopAnimating()
                    showError(message)
                }
            }
            .store(in: &cancellables)
    }

    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(.init(title: "Retry", style: .default) { [weak self] _ in
            self?.viewModel.loadApps()
        })
        alert.addAction(.init(title: "OK", style: .cancel))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension FeedViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        apps.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AppCell.reuseID, for: indexPath) as! AppCell
        let app = apps[indexPath.row]
        cell.configure(with: app, installState: viewModel.installState(for: app))
        return cell
    }
}

// MARK: - UITableViewDelegate

extension FeedViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let app = apps[indexPath.row]

        let detailVM = AppDetailViewModel(
            app: app,
            appLibraryProvider: appLibraryProvider,
            installationService: installationService
        )
        let detailVC = AppDetailViewController(viewModel: detailVM)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
