import UIKit

class GreetingUIView: UIView {

    private let greetingLabel = UILabel()
    private let subtitleLabel = UILabel()

    // Initialize the view and configure the labels
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        updateGreetingLabel()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        updateGreetingLabel()
    }

    private func setupView() {
        // Configure the view appearance
        self.backgroundColor = .white
        self.layer.cornerRadius = 8
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.borderWidth = 0.5
        self.translatesAutoresizingMaskIntoConstraints = false

        // Configure the greeting label
        greetingLabel.font = UIFont.boldSystemFont(ofSize: 16)
        greetingLabel.textColor = .black
        greetingLabel.translatesAutoresizingMaskIntoConstraints = false

        // Configure the subtitle label
        subtitleLabel.font = UIFont.systemFont(ofSize: 14)
        subtitleLabel.textColor = .gray
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = "Here is what's happening with your store today"

        // Add labels to the view
        addSubview(greetingLabel)
        addSubview(subtitleLabel)

        // Set up constraints for labels
        NSLayoutConstraint.activate([
            greetingLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
            greetingLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            greetingLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),

            subtitleLabel.topAnchor.constraint(equalTo: greetingLabel.bottomAnchor, constant: 2),
            subtitleLabel.leadingAnchor.constraint(equalTo: greetingLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: greetingLabel.trailingAnchor),
            subtitleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10)
        ])
    }

    // Update greeting based on the time of day
    private func updateGreetingLabel() {
        let hour = Calendar.current.component(.hour, from: Date())
        var greetingText = "Good Morning"
        
        if hour >= 12 && hour < 16 {
            greetingText = "Good Afternoon"
        } else if hour >= 16 {
            greetingText = "Good Evening"
        }
        
        // Assuming "Devansh" is a placeholder, replace with dynamic user name if available
        greetingLabel.text = "\(greetingText), Devansh"
    }
}
