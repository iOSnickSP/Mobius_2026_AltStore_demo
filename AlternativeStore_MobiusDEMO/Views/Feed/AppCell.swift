import UIKit

/// Table view cell for a single app in the feed — icon, name, developer, price pill.
final class AppCell: UITableViewCell {

    static let reuseID = "AppCell"

    // MARK: - Subviews

    private let iconView: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 14
        v.layer.cornerCurve = .continuous
        v.clipsToBounds = true
        return v
    }()

    private let iconLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 22, weight: .bold)
        l.textColor = .white
        l.textAlignment = .center
        return l
    }()

    private let nameLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 17, weight: .semibold)
        return l
    }()

    private let developerLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13)
        l.textColor = .secondaryLabel
        return l
    }()

    private let categoryLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12)
        l.textColor = .tertiaryLabel
        return l
    }()

    private let pricePill: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 15, weight: .bold)
        l.textColor = .systemBlue
        l.textAlignment = .center
        l.backgroundColor = .systemGray5
        l.layer.cornerRadius = 16
        l.layer.cornerCurve = .continuous
        l.clipsToBounds = true
        return l
    }()

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Configure

    func configure(with app: AppModel, installState: AppInstallState) {
        nameLabel.text = app.name
        developerLabel.text = app.developerName
        categoryLabel.text = app.category
        iconView.backgroundColor = app.iconColor
        iconLabel.text = app.iconEmoji

        switch installState {
        case .available:
            pricePill.text = app.isFree ? "GET" : app.price
        case .installing:
            pricePill.text = "..."
        case .installed:
            pricePill.text = "OPEN"
        }

        accessoryType = .disclosureIndicator
    }

    // MARK: - Layout

    private func setupLayout() {
        let textStack = UIStackView(arrangedSubviews: [nameLabel, developerLabel, categoryLabel])
        textStack.axis = .vertical
        textStack.spacing = 2

        iconView.addSubview(iconLabel)
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iconLabel.centerXAnchor.constraint(equalTo: iconView.centerXAnchor),
            iconLabel.centerYAnchor.constraint(equalTo: iconView.centerYAnchor),
        ])

        let row = UIStackView(arrangedSubviews: [iconView, textStack, pricePill])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 14

        contentView.addSubview(row)
        row.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 64),
            iconView.heightAnchor.constraint(equalToConstant: 64),
            pricePill.widthAnchor.constraint(equalToConstant: 75),
            pricePill.heightAnchor.constraint(equalToConstant: 32),
            row.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            row.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            row.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            row.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
        ])
    }
}
