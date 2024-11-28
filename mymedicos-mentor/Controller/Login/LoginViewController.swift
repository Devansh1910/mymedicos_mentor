import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class LoginViewController: UIViewController, UITextFieldDelegate {

    let scrollView = UIScrollView()
    let contentView = UIView()
    
    let logoImageView = UIImageView()
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    
    let phoneNumberContainerView = UIView()
    let countrySelectorButton = UIButton()
    let phoneNumberTextField = UITextField()
    var phoneNumberLimit: Int = 10  // Default phone number limit
    let continueButton = UIButton()
    let termsLabel = UILabel()
    
    var countryCodeData: [[String: Any]] = []
    var countryPickerAlertController: UIAlertController?
    
    let activityIndicator = UIActivityIndicatorView(style: .large)
    
    private let firestore = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        view.backgroundColor = .white
        
        loadCountryCodes()
        setupScrollView()
        setupUI()
        setupCountrySelectorButtonAction()
        phoneNumberTextField.delegate = self
        preloadCountryPicker()
        setupContinueButtonAction()
        setupActivityIndicator()

    }
    
    private func setupActivityIndicator() {
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        containerView.center = view.center
        containerView.backgroundColor = .clear // Optional: set background color if needed
        addShadow(to: containerView, color: .gray, opacity: 0.8, offset: CGSize(width: 0, height: 1), radius: 2)
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(activityIndicator)
        view.addSubview(containerView)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            activityIndicator.widthAnchor.constraint(equalToConstant: 40),
            activityIndicator.heightAnchor.constraint(equalToConstant: 40)
        ])
    }




    private func loadCountryCodes() {
        if let path = Bundle.main.path(forResource: "CountryCode", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                if let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? [[String: Any]] {
                    countryCodeData = jsonResult
                    setInitialCountry()
                }
            } catch {
                print("Error loading country codes: \(error)")
            }
        }
    }

    private func setInitialCountry() {
        if let defaultCountry = countryCodeData.first(where: { $0["id"] as? String == "0101" }) {
            if let name = defaultCountry["name"] as? String,
               let dialCode = defaultCountry["dial_code"] as? String,
               let flag = defaultCountry["flag"] as? String,
               let limit = defaultCountry["limit"] as? Int {
                countrySelectorButton.setTitle("\(flag) \(dialCode)", for: .normal)
                phoneNumberLimit = limit
            }
        }
    }

    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
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

    private func setupUI() {
        addLogo()
        addTextLabels()
        addPhoneNumberInput()
        addContinueButton()
        addTermsText()
        setupConstraints()
    }

    private func addLogo() {
        logoImageView.image = UIImage(named: "logoImage")
        logoImageView.contentMode = .scaleAspectFit
        contentView.addSubview(logoImageView)
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            logoImageView.widthAnchor.constraint(equalToConstant: 40),
            logoImageView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    private func addTextLabels() {
        titleLabel.text = "India’s first premier medical community app, connecting healthcare experts seamlessly."
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)

        subtitleLabel.text = "MADE IN BHARAT ❤️"
        subtitleLabel.textAlignment = .center
        subtitleLabel.textColor = .gray
        subtitleLabel.font = UIFont.systemFont(ofSize: 14)

        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
    }

    private func addPhoneNumberInput() {
        phoneNumberContainerView.layer.borderWidth = 1.0
        phoneNumberContainerView.layer.borderColor = UIColor.gray.cgColor
        phoneNumberContainerView.layer.cornerRadius = 10.0
        contentView.addSubview(phoneNumberContainerView)
        
        countrySelectorButton.setTitleColor(.black, for: .normal)
        countrySelectorButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        countrySelectorButton.backgroundColor = .white
        phoneNumberContainerView.addSubview(countrySelectorButton)

        phoneNumberTextField.placeholder = "Enter your phone number"
        phoneNumberTextField.borderStyle = .none
        phoneNumberTextField.font = UIFont.systemFont(ofSize: 14)
        phoneNumberTextField.keyboardType = .phonePad  // Set the keyboard type to phonePad
        phoneNumberTextField.translatesAutoresizingMaskIntoConstraints = false
        phoneNumberContainerView.addSubview(phoneNumberTextField)

        let leftBorder = UIView()
        leftBorder.backgroundColor = UIColor.gray
        leftBorder.translatesAutoresizingMaskIntoConstraints = false
        phoneNumberContainerView.addSubview(leftBorder)

        NSLayoutConstraint.activate([
            leftBorder.leadingAnchor.constraint(equalTo: phoneNumberContainerView.leadingAnchor, constant: 80),
            leftBorder.widthAnchor.constraint(equalToConstant: 1),
            leftBorder.topAnchor.constraint(equalTo: phoneNumberContainerView.topAnchor),
            leftBorder.bottomAnchor.constraint(equalTo: phoneNumberContainerView.bottomAnchor),
            
            countrySelectorButton.leadingAnchor.constraint(equalTo: phoneNumberContainerView.leadingAnchor),
            countrySelectorButton.topAnchor.constraint(equalTo: phoneNumberContainerView.topAnchor),
            countrySelectorButton.bottomAnchor.constraint(equalTo: phoneNumberContainerView.bottomAnchor),
            countrySelectorButton.widthAnchor.constraint(equalToConstant: 100),
            
            phoneNumberTextField.leadingAnchor.constraint(equalTo: leftBorder.trailingAnchor, constant: 10),
            phoneNumberTextField.trailingAnchor.constraint(equalTo: phoneNumberContainerView.trailingAnchor, constant: -10),
            phoneNumberTextField.topAnchor.constraint(equalTo: phoneNumberContainerView.topAnchor),
            phoneNumberTextField.bottomAnchor.constraint(equalTo: phoneNumberContainerView.bottomAnchor)
        ])
    }

    private func addContinueButton() {
        continueButton.setTitle("Continue", for: .normal)
        continueButton.backgroundColor = .darkGray
        continueButton.layer.cornerRadius = 5.0
        contentView.addSubview(continueButton)
    }

    private func addTermsText() {
        termsLabel.text = "By Clicking, I accept the terms of service and privacy policy"
        termsLabel.textAlignment = .center
        termsLabel.numberOfLines = 0
        termsLabel.font = UIFont.systemFont(ofSize: 12)
        contentView.addSubview(termsLabel)
    }

    private func setupConstraints() {
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        phoneNumberContainerView.translatesAutoresizingMaskIntoConstraints = false
        countrySelectorButton.translatesAutoresizingMaskIntoConstraints = false
        phoneNumberTextField.translatesAutoresizingMaskIntoConstraints = false
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        termsLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            logoImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 30),
            logoImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 100),
            logoImageView.heightAnchor.constraint(equalToConstant: 100),
            
            titleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            phoneNumberContainerView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 30),
            phoneNumberContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            phoneNumberContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            phoneNumberContainerView.heightAnchor.constraint(equalToConstant: 50),
            
            countrySelectorButton.leadingAnchor.constraint(equalTo: phoneNumberContainerView.leadingAnchor),
            countrySelectorButton.topAnchor.constraint(equalTo: phoneNumberContainerView.topAnchor),
            countrySelectorButton.bottomAnchor.constraint(equalTo: phoneNumberContainerView.bottomAnchor),
            countrySelectorButton.widthAnchor.constraint(equalToConstant: 100),
            
            phoneNumberTextField.leadingAnchor.constraint(equalTo: countrySelectorButton.trailingAnchor, constant: 10),
            phoneNumberTextField.trailingAnchor.constraint(equalTo: phoneNumberContainerView.trailingAnchor, constant: -10),
            phoneNumberTextField.topAnchor.constraint(equalTo: phoneNumberContainerView.topAnchor),
            phoneNumberTextField.bottomAnchor.constraint(equalTo: phoneNumberContainerView.bottomAnchor),
            
            continueButton.topAnchor.constraint(equalTo: phoneNumberContainerView.bottomAnchor, constant: 20),
            continueButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            continueButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            continueButton.heightAnchor.constraint(equalToConstant: 50),
            
            termsLabel.topAnchor.constraint(equalTo: continueButton.bottomAnchor, constant: 20),
            termsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            termsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            termsLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }

    private func setupCountrySelectorButtonAction() {
        countrySelectorButton.addTarget(self, action: #selector(showCountryPicker), for: .touchUpInside)
    }

    private func preloadCountryPicker() {
        countryPickerAlertController = UIAlertController(title: "Select Country", message: nil, preferredStyle: .actionSheet)
        for country in countryCodeData {
            if let name = country["name"] as? String, let dialCode = country["dial_code"] as? String, let flag = country["flag"] as? String {
                let action = UIAlertAction(title: "\(flag) \(name) (\(dialCode))", style: .default) { [weak self] _ in
                    self?.countrySelectorButton.setTitle("\(flag) \(dialCode)", for: .normal)
                    self?.phoneNumberLimit = country["limit"] as? Int ?? 10
                }
                countryPickerAlertController?.addAction(action)
            }
        }
        countryPickerAlertController?.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    }

    @objc private func showCountryPicker() {
        if let countryPickerAlertController = countryPickerAlertController {
            present(countryPickerAlertController, animated: true, completion: nil)
        }
    }

    @objc private func continueButtonTapped() {
        // 1. Validate phone number input
        guard let phoneNumber = phoneNumberTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !phoneNumber.isEmpty else {
            showAlert(title: "Invalid Input", message: "Please enter a phone number.")
            return
        }
        
        // 2. Validate phone number length
        if phoneNumber.count < 10 || phoneNumber.count > 16 {
            showAlert(title: "Invalid Number", message: "Please enter a valid phone number with 10 to 16 digits.")
            return
        }
        
        // 3. Safely extract dial code
        guard let countryTitle = countrySelectorButton.titleLabel?.text,
              !countryTitle.isEmpty else {
            showAlert(title: "Error", message: "Country code not selected.")
            return
        }
        
        // 4. Parse country code more safely
        let components = countryTitle.split(separator: " ")
        guard components.count > 1,
              let dialCode = components.first(where: { $0.hasPrefix("+") })?.trimmingCharacters(in: .whitespaces) else {
            showAlert(title: "Error", message: "Invalid country code format.")
            return
        }
        
        // 5. Construct full phone number with proper formatting
        let sanitizedPhoneNumber = phoneNumber.replacingOccurrences(of: " ", with: "")
        let fullPhoneNumber = sanitizedPhoneNumber.hasPrefix("+") ? sanitizedPhoneNumber : "\(dialCode)\(sanitizedPhoneNumber)"
        
        // 6. Start loading state
        DispatchQueue.main.async {
            self.activityIndicator.startAnimating()
            self.view.isUserInteractionEnabled = false
            self.continueButton.isEnabled = false
        }
        
        // 7. Check user existence with proper error handling
        checkIfUserExists(phoneNumber: fullPhoneNumber)
    }

    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }

    private func checkIfUserExists(phoneNumber: String) {
        let collectionRef = firestore.collection("MentorRegistration")
        
        collectionRef
            .whereField("Phone Number", isEqualTo: phoneNumber)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    defer {
                        self.activityIndicator.stopAnimating()
                        self.view.isUserInteractionEnabled = true
                        self.continueButton.isEnabled = true
                    }
                    
                    if let error = error {
                        print("Firestore error: \(error.localizedDescription)")
                        self.handleLoginError(message: "Unable to verify account. Please try again.")
                        return
                    }
                    
                    guard let documents = snapshot?.documents, !documents.isEmpty else {
                        // Navigate to RegistrationViewController if no account is found
                        self.navigateToRegistration(with: phoneNumber)
                        return
                    }
                    
                    let data = documents.first?.data()
                    
                    // Check verification status
                    if let isVerified = data?["Verified"] as? Bool, isVerified {
                        self.sendOTP(to: phoneNumber)
                    } else {
                        self.handleLoginError(message: "Your account is pending verification. Please contact support.")
                    }
                }
            }
    }
    
    private func navigateToRegistration(with phoneNumber: String) {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.view.isUserInteractionEnabled = true
        }
        let registrationViewController = Registration1ViewController()
        registrationViewController.phoneNumber = phoneNumber
        navigationController?.pushViewController(registrationViewController, animated: true)
    }
    
    private func handleLoginError(message: String) {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.view.isUserInteractionEnabled = true
            self.showAlert(title: "Login Error", message: message)
        }
    }

    func addShadow(to view: UIView, color: UIColor = .black, opacity: Float = 0.5, offset: CGSize = CGSize(width: 0, height: 2), radius: CGFloat = 4) {
        view.layer.shadowColor = color.cgColor
        view.layer.shadowOpacity = opacity
        view.layer.shadowOffset = offset
        view.layer.shadowRadius = radius
        view.layer.masksToBounds = false
    }

    private func sendOTP(to phoneNumber: String) {
        // Ensure Fi rebase Auth is initialized
        let authProvider = PhoneAuthProvider.provider()

        // Start OTP request
        authProvider.verifyPhoneNumber(phoneNumber, uiDelegate: nil) { [weak self] verificationID, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if let error = error {
                    print("Failed to send OTP: \(error.localizedDescription)")
                    self.handleLoginError(message: "Failed to send OTP. Please check your number and try again.")
                    return
                }
                
                guard let verificationID = verificationID else {
                    print("Error: Verification ID is nil.")
                    self.handleLoginError(message: "Failed to generate OTP. Please try again.")
                    return
                }
                
                // Save verification ID and navigate to OTP input screen
                UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
                self.navigateToEnterOTP(phoneNumber: phoneNumber)
            }
        }
    }


    private func navigateToEnterOTP(phoneNumber: String) {
        DispatchQueue.main.async {
            let enterOTPViewController = EnterOtpViewController()
            enterOTPViewController.phoneNumber = phoneNumber
            self.navigationController?.pushViewController(enterOTPViewController, animated: true)
        }
    }

    private func setupContinueButtonAction() {
        continueButton.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }

        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)

        return updatedText.count <= 16
    }


    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.navigationController == nil {
            print("LoginViewController is not embedded in a UINavigationController.")
        } else {
            print("LoginViewController is embedded in a UINavigationController.")
        }
    }

    
}
