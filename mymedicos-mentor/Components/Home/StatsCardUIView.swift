import UIKit

class StatsCardUIView: UIView {

    private let titleLabel = UILabel()
    private let valueLabel = UILabel()
    private let viewButton = UIButton(type: .system)

    init(title: String, value: String, buttonTitle: String, buttonTextColor: UIColor, buttonBackgroundColor: UIColor) {
        super.init(frame: .zero)
        setupView()
        titleLabel.text = title
        valueLabel.text = value
        configureViewButton(title: buttonTitle, textColor: buttonTextColor, backgroundColor: buttonBackgroundColor)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        layer.cornerRadius = 5
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.lightGray.cgColor
        backgroundColor = .white

        // Configure title label
        titleLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        titleLabel.textColor = .darkGray

        // Configure value label
        valueLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        valueLabel.textColor = .darkGray

        // Stack for layout
        let stackView = UIStackView(arrangedSubviews: [titleLabel, valueLabel, viewButton])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .leading
        stackView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
    }

    private func configureViewButton(title: String, textColor: UIColor, backgroundColor: UIColor) {
        // Configure view button
        viewButton.setTitle(title, for: .normal)
        viewButton.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        viewButton.setTitleColor(textColor, for: .normal)
        viewButton.backgroundColor = backgroundColor
        viewButton.layer.cornerRadius = 5
        viewButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        
        // Add action to the button if needed
        viewButton.addTarget(self, action: #selector(viewButtonTapped), for: .touchUpInside)
    }

    @objc private func viewButtonTapped() {
        // Handle the view button tap action here
        print("View button tapped")
    }
}
