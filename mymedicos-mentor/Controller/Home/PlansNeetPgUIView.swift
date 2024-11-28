import UIKit
import FirebaseAuth
import FirebaseFirestore

struct PlanData {
    var documentID: String // New property for document ID
    var title: String
    var subtitle: String
    var startingPrice: String
    var discountedPrice: String
    var originalPrice: String
    var features: [String]
}

class PlansNeetPgUIView: UIView {
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    let startingAtLabel = UILabel()
    let priceLabel = UILabel()
    let dividerView = UIView()
    let whatYouGetLabel = UILabel()
    let featureListView = UIStackView()
    let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Enroll now", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.darkGray
        button.layer.cornerRadius = 10
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 0.3
        button.clipsToBounds = false
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var enrollAction: ((_ documentID: String) -> Void)? // Closure now takes document ID as a parameter
    var documentID: String? // New property to store the document ID
    let topContainerView = UIView()  // Container for the views above the divider
    var selectedCollection: String? // Add this to store the section
    var segmentName: String!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    @objc private func handleAttempt() {
        if let documentID = documentID {
            enrollAction?(documentID)
        }

        // Get the current authenticated user and their phone number
        guard let user = Auth.auth().currentUser, let userPhoneNumber = user.phoneNumber else {
            print("User not authenticated or phone number not available")
            return
        }

        let db = Firestore.firestore()

        // Query Firestore to get the user data based on phone number
        db.collection("users").whereField("Phone Number", isEqualTo: userPhoneNumber).getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching user data from Firestore: \(error)")
                return
            }

            guard let document = snapshot?.documents.first else {
                print("No matching user found")
                return
            }

            // Extract user details from Firestore
            let data = document.data()
            let userId = data["DocID"] as? String ?? "Unknown DocID"
            let userName = data["Name"] as? String ?? "Unknown Name"
            let userEmail = data["Email ID"] as? String ?? "Unknown Email"
            let phoneNumber = data["Phone Number"] as? String ?? "Unknown Phone Number"

            // Plan details
            let planId = self.documentID ?? "Unknown Plan ID"
            let planName = self.titleLabel.text ?? "Unknown Plan Name"
            let section = self.segmentName  // Use the segmentName property directly

            // Prepare the data to store in Firestore under a `sales` collection
            let enrollmentData: [String: Any] = [
                "user_id": userId,
                "user_name": userName,
                "user_email": userEmail,
                "phone_number": phoneNumber,
                "plan_id": planId,
                "plan_name": planName,
                "segment": section,  // Add the selected segment here
                "enrolled_at": Timestamp()
            ]

            // Store the user data in Firestore
            db.collection("sales").document(userId).setData(enrollmentData) { error in
                if let error = error {
                    print("Error saving data to Firestore: \(error)")
                } else {
                    print("Enrollment data successfully saved for sales tracking in Firestore!")
                }
            }
        }
    }


    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupViews() {
        backgroundColor = UIColor(red: 250/255, green: 250/255, blue: 245/255, alpha: 1)
        layer.cornerRadius = 10
        clipsToBounds = true

        setupLabels()
        setupFeatureList()
        setupDivider()
        setupTopContainer()

        addSubviews(topContainerView, dividerView, whatYouGetLabel, featureListView, actionButton)
        setupConstraints()
    }

    private func setupLabels() {
        titleLabel.text = "🔥 PRO Plan"
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        titleLabel.textAlignment = .left
        titleLabel.textColor = .black

        subtitleLabel.text = "India's Only Clinical QBank"
        subtitleLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        subtitleLabel.textAlignment = .left
        subtitleLabel.textColor = .darkGray

        startingAtLabel.text = "Starting at ✨"
        startingAtLabel.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        startingAtLabel.textAlignment = .left
        startingAtLabel.textColor = .darkGray

        priceLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        priceLabel.textAlignment = .left
        priceLabel.textColor = .black

        whatYouGetLabel.text = "WHAT YOU'LL GET"
        whatYouGetLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        whatYouGetLabel.textAlignment = .left
        whatYouGetLabel.textColor = .darkGray
    }

    private func setupDivider() {
        dividerView.backgroundColor = .lightGray
        dividerView.translatesAutoresizingMaskIntoConstraints = false
    }

    private func setupTopContainer() {
        topContainerView.backgroundColor = UIColor(red: 255/255, green: 227/255, blue: 174/255, alpha: 1)
        topContainerView.layer.cornerRadius = 10
        topContainerView.clipsToBounds = true
        topContainerView.addSubview(titleLabel)
        topContainerView.addSubview(subtitleLabel)
        topContainerView.addSubview(startingAtLabel)
        topContainerView.addSubview(priceLabel)
    }

    private func setupFeatureList() {
        featureListView.axis = .vertical
        featureListView.distribution = .equalSpacing
        featureListView.alignment = .leading
        featureListView.spacing = 10
    }

    private func addSubviews(_ views: UIView...) {
        views.forEach { addSubview($0) }
    }

    func configure(with planData: PlanData) {
        titleLabel.text = planData.title
        subtitleLabel.text = planData.subtitle
        documentID = planData.documentID

        let priceText = NSMutableAttributedString(string: "\(formatPrice(planData.discountedPrice)) ", attributes: [
            .font: UIFont.systemFont(ofSize: 20, weight: .bold),
            .foregroundColor: UIColor.black
        ])
        priceText.append(NSAttributedString(string: formatPrice(planData.originalPrice), attributes: [
            .font: UIFont.systemFont(ofSize: 14),
            .foregroundColor: UIColor.gray,
            .strikethroughStyle: NSUnderlineStyle.single.rawValue
        ]))
        priceLabel.attributedText = priceText

        featureListView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for feature in planData.features {
            let label = UILabel()
            label.text = "✓ \(feature)"
            label.font = UIFont.systemFont(ofSize: 14)
            label.textColor = .darkGray
            label.numberOfLines = 0
            featureListView.addArrangedSubview(label)
        }

        layer.borderColor = colorForPlan(planData.title).cgColor
        layer.borderWidth = 1
    }

    private func colorForPlan(_ planName: String) -> UIColor {
        switch planName {
        case "ELITE Plan":
            return UIColor.systemGray
        case "Foundation Plan":
            return UIColor.systemGray
        case "PRO Plan":
            return UIColor.systemGray
        default:
            return UIColor.clear
        }
    }

    private func formatPrice(_ price: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "₹"
        formatter.currencyGroupingSeparator = ","
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: Int(price) ?? 0)) ?? "₹0"
    }

    private func setupConstraints() {
        subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        topContainerView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        startingAtLabel.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        dividerView.translatesAutoresizingMaskIntoConstraints = false
        whatYouGetLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            topContainerView.topAnchor.constraint(equalTo: topAnchor),
            topContainerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            topContainerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            topContainerView.bottomAnchor.constraint(equalTo: dividerView.topAnchor),

            titleLabel.topAnchor.constraint(equalTo: topContainerView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: topContainerView.leadingAnchor, constant: 15),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            subtitleLabel.leadingAnchor.constraint(equalTo: topContainerView.leadingAnchor, constant: 15),

            startingAtLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 10),
            startingAtLabel.leadingAnchor.constraint(equalTo: topContainerView.leadingAnchor, constant: 15),

            priceLabel.topAnchor.constraint(equalTo: startingAtLabel.bottomAnchor, constant: 5),
            priceLabel.leadingAnchor.constraint(equalTo: topContainerView.leadingAnchor, constant: 15),

            dividerView.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 10),
            dividerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            dividerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            dividerView.heightAnchor.constraint(equalToConstant: 1),

            whatYouGetLabel.topAnchor.constraint(equalTo: dividerView.bottomAnchor, constant: 20),
            whatYouGetLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),

            featureListView.topAnchor.constraint(equalTo: whatYouGetLabel.bottomAnchor, constant: 15),
            featureListView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            featureListView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),

            actionButton.topAnchor.constraint(equalTo: featureListView.bottomAnchor, constant: 20),
            actionButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            actionButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            actionButton.heightAnchor.constraint(equalToConstant: 40),
            actionButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20)
        ])
        
        actionButton.addTarget(self, action: #selector(handleAttempt), for: .touchUpInside)
    }
}
