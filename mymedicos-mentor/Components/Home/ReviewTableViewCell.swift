import UIKit

class ReviewTableViewCell: UITableViewCell {
    private let nameLabel = UILabel()
    private let reviewLabel = UILabel()
    private let dateLabel = UILabel()
    private let ratingLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        // Configure nameLabel
        nameLabel.font = UIFont.boldSystemFont(ofSize: 16)
        nameLabel.textColor = .black
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        // Configure reviewLabel
        reviewLabel.font = UIFont.systemFont(ofSize: 14)
        reviewLabel.textColor = .darkGray
        reviewLabel.numberOfLines = 0
        reviewLabel.translatesAutoresizingMaskIntoConstraints = false

        // Configure dateLabel
        dateLabel.font = UIFont.systemFont(ofSize: 12)
        dateLabel.textColor = .lightGray
        dateLabel.translatesAutoresizingMaskIntoConstraints = false

        // Configure ratingLabel
        ratingLabel.font = UIFont.systemFont(ofSize: 14)
        ratingLabel.textColor = .systemYellow
        ratingLabel.translatesAutoresizingMaskIntoConstraints = false

        // Add subviews
        contentView.addSubview(nameLabel)
        contentView.addSubview(reviewLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(ratingLabel)

        // Apply constraints
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: ratingLabel.leadingAnchor, constant: -8),

            ratingLabel.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            ratingLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            reviewLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5),
            reviewLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            reviewLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            dateLabel.topAnchor.constraint(equalTo: reviewLabel.bottomAnchor, constant: 5),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(name: String, review: String, rating: Int, date: Date) {
        nameLabel.text = name
        reviewLabel.text = review
        ratingLabel.text = "⭐️ \(rating)"
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateLabel.text = dateFormatter.string(from: date)
    }
}
