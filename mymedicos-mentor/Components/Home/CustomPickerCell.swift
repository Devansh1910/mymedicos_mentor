import UIKit

class CustomPickerCell: UITableViewCell {

    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .gray
        label.isHidden = true // Hidden by default; shown conditionally
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let radioButton: UIButton = {
        let button = UIButton(type: .custom)
        let normalImage = UIImage(systemName: "circle")?.withTintColor(.gray, renderingMode: .alwaysOriginal)
        let selectedImage = UIImage(systemName: "circle.inset.filled")?.withTintColor(.gray, renderingMode: .alwaysOriginal)
        button.setImage(normalImage, for: .normal)
        button.setImage(selectedImage, for: .selected)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.isHidden = true // Hidden by default; shown conditionally
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(containerView)
        containerView.addSubview(iconImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(subtitleLabel)
        containerView.addSubview(radioButton)
        
        NSLayoutConstraint.activate([
            // Container view constraints
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            
            // Icon constraints
            iconImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            iconImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalTo: titleLabel.heightAnchor, multiplier: 2.0), // Matching height with title and subtitle
            
            // Title label constraints
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 10),
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 15),
            
            // Subtitle label constraints
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            subtitleLabel.trailingAnchor.constraint(equalTo: radioButton.leadingAnchor, constant: -10),
            subtitleLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -15),
            
            // Radio button constraints
            radioButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            radioButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(for option: String, isSelected: Bool, isDisabled: Bool = false) {
        titleLabel.text = option
        radioButton.isSelected = isSelected
        
        // Set subtitle and icon based on option
        if option == "mymedicos exclusive" {
            subtitleLabel.text = "Current Access"
            subtitleLabel.isHidden = false
            iconImageView.isHidden = false
            iconImageView.image = UIImage(systemName: "wand.and.stars.inverse")?.withTintColor(.gray, renderingMode: .alwaysOriginal)
        } else if option == "Create another access" {
            subtitleLabel.text = "Contact at service@mymedicos.in"
            subtitleLabel.isHidden = false
            iconImageView.isHidden = false
            iconImageView.image = UIImage(systemName: "plus")?.withTintColor(.gray, renderingMode: .alwaysOriginal)
        } else {
            subtitleLabel.isHidden = true
            iconImageView.isHidden = true
        }

        // Adjust the container appearance
        if isDisabled {
            containerView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
            containerView.layer.borderColor = UIColor.gray.cgColor
            containerView.layer.borderWidth = 1
        } else {
            containerView.backgroundColor = .white
            containerView.layer.borderColor = UIColor.black.cgColor
            containerView.layer.borderWidth = 1
        }
    }
}
