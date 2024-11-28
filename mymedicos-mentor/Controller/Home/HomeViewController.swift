import UIKit
import Lottie
import FirebaseFirestore

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CustomPickerCell", for: indexPath) as? CustomPickerCell else {
            return UITableViewCell()
        }
        let option = options[indexPath.row]
        let isSelected = indexPath.row == selectedOptionIndex
        let isDisabled = false // You can modify this based on your requirements

        // Configure the cell
        cell.configure(for: option, isSelected: isSelected, isDisabled: isDisabled)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedOption = options[indexPath.row]
        
        if selectedOption == "Create another access" {
            // Show alert if "Create another access" is selected
            let alert = UIAlertController(
                title: "Access Restricted",
                message: "Contact mymedicos admin for another access at service@mymedicos.in",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true, completion: nil)
            
            // Do not allow selection change
            return
        }
        
        // If not restricted, update the selected option
        selectedOptionIndex = indexPath.row
        dropdownButton.setTitle("\(options[selectedOptionIndex]) ▼", for: .normal)
        customPickerTableView?.reloadData()
        dismissCustomPickerView()
    }




    var userId: String?
    var sessionId: String?

    private let options = ["mymedicos exclusive", "Create another access"]
    private var selectedOptionIndex = 0

    private let dropdownButton = UIButton(type: .system)
    private var customPickerTableView: UITableView?
    private var customPickerContainerView: UIView?
    private var blurEffectView: UIVisualEffectView?
    private var rotationTimer: Timer?
    private let logoImageView = UIImageView()
    private let greetingUIView = GreetingUIView()
    private let statsGridView = UIStackView()

    private let reviewLabel = UILabel()
    private var reviews: [[String: Any]] = [] // Array to hold review data
    private let helpLabel = UILabel()

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private var reviewCollectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: "#E3E3E3")
        configureNavbar()
        setupScrollView()
        configureGreetingUIView()
        setupStatsGridView()
        setupReviewLabel()
        setupReviewCollectionView()
        fetchReviews(for: "+919305506538")
    }

    private func configureNavbar() {
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]

        let logo = UIImage(named: "logoImage")?.withRenderingMode(.alwaysOriginal)
        logoImageView.image = logo
        logoImageView.contentMode = .scaleAspectFit
        let containerView = UIView()
        containerView.addSubview(logoImageView)
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            logoImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            logoImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            logoImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 5),
            logoImageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8),
            logoImageView.widthAnchor.constraint(equalToConstant: 40),
            logoImageView.heightAnchor.constraint(equalToConstant: 40)
        ])
        let logoItem = UIBarButtonItem(customView: containerView)

        dropdownButton.setTitle("\(options[selectedOptionIndex]) ▼", for: .normal)
        dropdownButton.setTitleColor(.black, for: .normal)
        dropdownButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        dropdownButton.addTarget(self, action: #selector(didTapDropdown), for: .touchUpInside)

        let dropdownItem = UIBarButtonItem(customView: dropdownButton)

        navigationItem.leftBarButtonItems = [logoItem, dropdownItem]

        setupIcons()
    }

    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }

    private func configureGreetingUIView() {
        contentView.addSubview(greetingUIView)

        NSLayoutConstraint.activate([
            greetingUIView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            greetingUIView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            greetingUIView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            greetingUIView.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    private func setupStatsGridView() {
        let statsTitleLabel = UILabel()
        statsTitleLabel.text = "Statistics Overview"
        statsTitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        statsTitleLabel.textColor = .black
        statsTitleLabel.textAlignment = .left
        statsTitleLabel.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(statsTitleLabel)
        statsGridView.axis = .vertical
        statsGridView.spacing = 15
        statsGridView.distribution = .fillProportionally

        let firstRowStack = createRowStack(
            leftCard: StatsCardUIView(title: "No. of Subscribers", value: "04", buttonTitle: "34% Increase", buttonTextColor: .white, buttonBackgroundColor: .systemBlue),
            rightCard: StatsCardUIView(title: "Overall ratings", value: "04", buttonTitle: "Good", buttonTextColor: .black, buttonBackgroundColor: .systemYellow)
        )

        let secondRowStack = createRowStack(
            leftCard: StatsCardUIView(title: "Total Revenue", value: "₹1,82,325", buttonTitle: "Estimated", buttonTextColor: .white, buttonBackgroundColor: .systemGreen),
            rightCard: StatsCardUIView(title: "Platform Rating", value: "3.0", buttonTitle: "Community Performance", buttonTextColor: .white, buttonBackgroundColor: .systemRed)
        )

        statsGridView.addArrangedSubview(firstRowStack)
        statsGridView.addArrangedSubview(secondRowStack)

        contentView.addSubview(statsGridView)
        statsGridView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            statsTitleLabel.topAnchor.constraint(equalTo: greetingUIView.bottomAnchor, constant: 10),
            statsTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            statsTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),

            statsGridView.topAnchor.constraint(equalTo: statsTitleLabel.bottomAnchor, constant: 10),
            statsGridView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            statsGridView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
        ])
    }

    private func setupReviewLabel() {
        contentView.addSubview(reviewLabel)

        reviewLabel.text = "Reviews"
        reviewLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        reviewLabel.textColor = .black
        reviewLabel.textAlignment = .left
        reviewLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            reviewLabel.topAnchor.constraint(equalTo: statsGridView.bottomAnchor, constant: 20),
            reviewLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            reviewLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupHelpLabel() {
        contentView.addSubview(reviewLabel)

        helpLabel.text = "Support Helpline"
        helpLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        helpLabel.textColor = .black
        helpLabel.textAlignment = .left
        helpLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            helpLabel.topAnchor.constraint(equalTo: reviewCollectionView.bottomAnchor, constant: 20),
            helpLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            helpLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }

    private func setupIcons() {
        let notificationButton = UIButton(type: .custom)
        if let notificationImage = UIImage(systemName: "bell")?.withTintColor(.black, renderingMode: .alwaysOriginal) {
            notificationButton.setImage(notificationImage, for: .normal)
        }
        notificationButton.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        notificationButton.addTarget(self, action: #selector(didTapNotification), for: .touchUpInside)
        let notificationItem = UIBarButtonItem(customView: notificationButton)

        let lottieAnimationView = LottieAnimationView(name: "premiumlottie")
        lottieAnimationView.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        lottieAnimationView.contentMode = .scaleAspectFit
        lottieAnimationView.play()
        let lottieItem = UIBarButtonItem(customView: lottieAnimationView)

        navigationItem.rightBarButtonItems = [notificationItem, lottieItem]
    }

    @objc private func didTapDropdown() {
        showCustomPickerView()
    }
    
    private func showCustomPickerView() {
        guard customPickerTableView == nil else { return }
        
        let containerView = UIView(frame: CGRect(x: 0, y: view.bounds.height, width: view.bounds.width, height: 250))
        containerView.backgroundColor = .white
        containerView.overrideUserInterfaceStyle = .light
        view.addSubview(containerView)
        
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
        self.blurEffectView = blurEffectView
        
        let tableView = UITableView(frame: CGRect(x: 0, y: 50, width: view.bounds.width, height: 200), style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        
        // Register the custom cell
        tableView.register(CustomPickerCell.self, forCellReuseIdentifier: "CustomPickerCell")
        
        tableView.separatorStyle = .none
        tableView.layer.cornerRadius = 10
        tableView.layer.masksToBounds = true
        containerView.addSubview(tableView)
        
        let doneButton = UIButton(type: .system)
        doneButton.setTitle("Done", for: .normal)
        doneButton.addTarget(self, action: #selector(dismissCustomPickerView), for: .touchUpInside)
        containerView.addSubview(doneButton)
        doneButton.frame = CGRect(x: view.bounds.width - 70, y: 10, width: 60, height: 30)
        
        self.customPickerContainerView = containerView
        self.customPickerTableView = tableView
        
        view.bringSubviewToFront(containerView)
        
        UIView.animate(withDuration: 0.3) {
            containerView.frame.origin.y = self.view.bounds.height - 250
        }
    }



    private func fetchReviews(for mentorPhoneNumber: String) {
        let db = Firestore.firestore()

        db.collection("MentorReview").document(mentorPhoneNumber).getDocument { [weak self] (document, error) in
            guard let self = self else { return }
            guard let data = document?.data(), let reviews = data["reviews"] as? [[String: Any]], error == nil else {
                print("Error fetching reviews: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            self.reviews = reviews
            DispatchQueue.main.async {
                self.reviewCollectionView.reloadData()
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return reviews.count
    }

    @objc private func didTapNotification() {
        // Code for notification action
    }

    @objc private func dismissCustomPickerView() {
        UIView.animate(withDuration: 0.3, animations: {
            self.customPickerContainerView?.frame.origin.y = self.view.bounds.height
            self.blurEffectView?.alpha = 0
        }, completion: { _ in
            self.customPickerContainerView?.removeFromSuperview()
            self.customPickerTableView?.removeFromSuperview()
            self.blurEffectView?.removeFromSuperview()
            self.customPickerContainerView = nil
            self.customPickerTableView = nil
            self.blurEffectView = nil
        })
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReviewCell", for: indexPath) as! ReviewCollectionViewCell
        let review = reviews[indexPath.item]
        let studentName = review["studentname"] as? String ?? "Anonymous"
        let studentReview = review["studentreview"] as? String ?? "No review available"
        let rating = review["rating"] as? Int ?? 0
        let timestamp = review["date"] as? Timestamp
        let date = timestamp?.dateValue() ?? Date()

        cell.configure(name: studentName, review: studentReview, rating: rating, date: date)
        return cell
    }
    
    private let checkoutAllButton: UIButton = {
        let button = UIButton(type: .system)
        
        // Set the title
        button.setTitle("Checkout All", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        
        // Add the system icon (chevron.right)
        let arrowImage = UIImage(systemName: "chevron.right")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        button.setImage(arrowImage, for: .normal)
        
        // Position the icon to the right of the text
        button.semanticContentAttribute = .forceRightToLeft
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: -8) // Adjust spacing
        
        // Style the button background
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        
        // Add padding
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
        
        // Add action
        button.addTarget(self, action: #selector(didTapCheckoutAll), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()



    private func setupReviewCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        layout.itemSize = CGSize(width: 300, height: 150)

        reviewCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        reviewCollectionView.delegate = self
        reviewCollectionView.dataSource = self
        reviewCollectionView.translatesAutoresizingMaskIntoConstraints = false
        reviewCollectionView.register(ReviewCollectionViewCell.self, forCellWithReuseIdentifier: "ReviewCell")
        reviewCollectionView.backgroundColor = .clear
        reviewCollectionView.showsHorizontalScrollIndicator = false

        contentView.addSubview(reviewCollectionView)
        contentView.addSubview(checkoutAllButton) // Add the button to the view hierarchy

        NSLayoutConstraint.activate([
            reviewCollectionView.topAnchor.constraint(equalTo: reviewLabel.bottomAnchor, constant: 10),
            reviewCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            reviewCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            reviewCollectionView.heightAnchor.constraint(equalToConstant: 160),
            
            checkoutAllButton.topAnchor.constraint(equalTo: reviewCollectionView.bottomAnchor, constant: 10),
            checkoutAllButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            checkoutAllButton.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -20)
        ])
    }

    @objc private func didTapCheckoutAll() {
        let allReviewsView = AllReviewsUIView() // Assuming AllReviewsUIView is your target view controller
        allReviewsView.reviews = reviews // Pass the reviews if needed
        navigationController?.pushViewController(allReviewsView, animated: true)
    }

    

    private func createRowStack(leftCard: UIView, rightCard: UIView) -> UIStackView {
        let rowStack = UIStackView(arrangedSubviews: [leftCard, rightCard])
        rowStack.axis = .horizontal
        rowStack.spacing = 10
        rowStack.distribution = .fillEqually
        return rowStack
    }
}
