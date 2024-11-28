import UIKit

class ReviewBoxView: UIView {
    // MARK: - UI Components
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()
    
    private let avatarView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBlue.withAlphaComponent(0.1)
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
        return view
    }()
    
    private let avatarLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .systemBlue
        label.textAlignment = .center
        return label
    }()
    
    private let contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .leading
        return stack
    }()
    
    private let headerStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        stack.alignment = .center
        return stack
    }()
    
    private let userInfoStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 2
        return stack
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .label
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let ratingStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 4
        stack.distribution = .fillEqually
        return stack
    }()
    
    private let reviewLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = .label
        label.numberOfLines = 3
        return label
    }()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - Setup
    private func setupView() {
        backgroundColor = .clear
        
        // Add shadow to container
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 8
        layer.shadowOpacity = 0.08
        
        setupHierarchy()
        setupConstraints()
    }
    
    private func setupHierarchy() {
        addSubview(containerView)
        
        // Avatar setup
        containerView.addSubview(avatarView)
        avatarView.addSubview(avatarLabel)
        
        // Content setup
        containerView.addSubview(contentStackView)
        
        headerStackView.addArrangedSubview(avatarView)
        headerStackView.addArrangedSubview(userInfoStackView)
        
        userInfoStackView.addArrangedSubview(nameLabel)
        userInfoStackView.addArrangedSubview(dateLabel)
        userInfoStackView.addArrangedSubview(ratingStackView)
        
        contentStackView.addArrangedSubview(headerStackView)
        contentStackView.addArrangedSubview(reviewLabel)
    }
    
    private func setupConstraints() {
        [containerView, avatarView, avatarLabel, contentStackView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            // Container constraints
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Content stack constraints
            contentStackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            contentStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            contentStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            contentStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            
            // Avatar constraints
            avatarView.widthAnchor.constraint(equalToConstant: 40),
            avatarView.heightAnchor.constraint(equalToConstant: 40),
            
            // Avatar label constraints
            avatarLabel.centerXAnchor.constraint(equalTo: avatarView.centerXAnchor),
            avatarLabel.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor)
        ])
    }
    
    // MARK: - Public Methods
    func configure(with review: Review) {
        nameLabel.text = review.name
        avatarLabel.text = String(review.name.prefix(1))
        reviewLabel.text = review.content
        
        // Configure date
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateLabel.text = dateFormatter.string(from: review.date)
        
        // Configure rating
        ratingStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for i in 1...4 {
            let starImageView = UIImageView()
            starImageView.tintColor = .systemYellow
            starImageView.contentMode = .scaleAspectFit
            
            let starImage = i <= review.rating ? "star.fill" : "star"
            starImageView.image = UIImage(systemName: starImage)
            
            NSLayoutConstraint.activate([
                starImageView.widthAnchor.constraint(equalToConstant: 16),
                starImageView.heightAnchor.constraint(equalToConstant: 16)
            ])
            
            ratingStackView.addArrangedSubview(starImageView)
        }
    }
}

// MARK: - Review Model
struct Review {
    let name: String
    let content: String
    let rating: Int
    let date: Date
}
