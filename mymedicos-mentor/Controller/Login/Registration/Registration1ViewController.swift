import UIKit
import FirebaseFirestore

class Registration1ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    var phoneNumber: String?
    var prefixOptions = ["Doctor", "Nurse", "Human Resource"]
    var prefixAbbreviations = ["Dr.", "Nu.", "Hr."] // Corresponding abbreviations
    var selectedPrefix: String?

    // UI Components
    let scrollView = UIScrollView()
    let contentView = UIView()
    let titleLabel = UILabel()
    let phoneLabel = UILabel()
    let prefixLabel = UILabel()
    let nameLabel = UILabel()
    let emailLabel = UILabel()
    let mcnLabel = UILabel()
    let aadharLabel = UILabel()

    let prefixTextField = UITextField()
    let nameTextField = UITextField()
    let emailTextField = UITextField()
    let mciTextField = UITextField()
    let aadharTextField = UITextField()
    let continueButton = UIButton()
    let prefixPicker = UIPickerView()

    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        view.backgroundColor = .white
        setupUI()
    }

    func setupUI() {
        setupScrollView()
        setupLabels()
        createTextField(placeholder: "Select your prefix", textField: prefixTextField, yPos: 150)
        createTextField(placeholder: "Enter your full name", textField: nameTextField, yPos: 225)
        createTextField(placeholder: "Enter your email address", textField: emailTextField, yPos: 315)
        createTextField(placeholder: "Enter your MCI number", textField: mciTextField, yPos: 405)
        createTextField(placeholder: "Enter your Aadhar number", textField: aadharTextField, yPos: 495)
        setupContinueButton()
        setupConstraints()
        setupPrefixPicker()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        scrollView.addGestureRecognizer(tapGesture)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    func setupPrefixPicker() {
        prefixPicker.delegate = self
        prefixPicker.dataSource = self
        prefixTextField.inputView = prefixPicker

        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donePicker))
        toolbar.setItems([doneButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        prefixTextField.inputAccessoryView = toolbar
    }

    @objc func donePicker() {
        prefixTextField.resignFirstResponder()
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return prefixOptions.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return prefixOptions[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        prefixTextField.text = prefixOptions[row]
        selectedPrefix = prefixAbbreviations[row] // Store the abbreviation for registration
    }

    func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])

        contentView.heightAnchor.constraint(equalToConstant: 800).isActive = true
    }

    func setupLabels() {
        titleLabel.text = "New Account Details"
        titleLabel.font = UIFont.systemFont(ofSize: 20)
        titleLabel.textColor = .black
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)

        phoneLabel.text = "Signing up as \(phoneNumber ?? "")"
        phoneLabel.font = UIFont.systemFont(ofSize: 16)
        phoneLabel.textColor = .gray
        phoneLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(phoneLabel)

        nameLabel.text = "Full Name*"
        nameLabel.font = UIFont.systemFont(ofSize: 16)
        nameLabel.textColor = .gray
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(nameLabel)

        emailLabel.text = "Email Address*"
        emailLabel.font = UIFont.systemFont(ofSize: 16)
        emailLabel.textColor = .gray
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(emailLabel)
        
        mcnLabel.text = "Enter medical council number*"
        mcnLabel.font = UIFont.systemFont(ofSize: 16)
        mcnLabel.textColor = .gray
        mcnLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(mcnLabel)
        
        aadharLabel.text = "Enter aadhar card number*"
        aadharLabel.font = UIFont.systemFont(ofSize: 16)
        aadharLabel.textColor = .gray
        aadharLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(aadharLabel)

        prefixLabel.text = "Prefix*"
        prefixLabel.font = UIFont.systemFont(ofSize: 16)
        prefixLabel.textColor = .gray
        prefixLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(prefixLabel)
    }

    func createTextField(placeholder: String, textField: UITextField, yPos: CGFloat) {
        textField.placeholder = placeholder
        textField.borderStyle = .roundedRect
        textField.textColor = UIColor.black
        textField.autocapitalizationType = placeholder.contains("email") ? .none : .words
        textField.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(textField)
    }

    func setupContinueButton() {
        continueButton.backgroundColor = .darkGray
        continueButton.setTitle("Continue", for: .normal)
        continueButton.setTitleColor(.white, for: .normal)
        continueButton.layer.cornerRadius = 8
        continueButton.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(continueButton)

        NSLayoutConstraint.activate([
            continueButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            continueButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            continueButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
            continueButton.heightAnchor.constraint(equalToConstant: 45)
        ])
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            phoneLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            phoneLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            phoneLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            prefixLabel.topAnchor.constraint(equalTo: phoneLabel.bottomAnchor, constant: 20),
            prefixLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            prefixLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            prefixTextField.topAnchor.constraint(equalTo: prefixLabel.bottomAnchor, constant: 10),
            prefixTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            prefixTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            prefixTextField.heightAnchor.constraint(equalToConstant: 50),

            nameLabel.topAnchor.constraint(equalTo: prefixTextField.bottomAnchor, constant: 20),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            nameTextField.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10),
            nameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            nameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            nameTextField.heightAnchor.constraint(equalToConstant: 50),

            emailLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 20),
            emailLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            emailLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            emailTextField.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 10),
            emailTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            emailTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            emailTextField.heightAnchor.constraint(equalToConstant: 50),
            
            mcnLabel.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
            mcnLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            mcnLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            mciTextField.topAnchor.constraint(equalTo: mcnLabel.bottomAnchor, constant: 20),
            mciTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            mciTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            mciTextField.heightAnchor.constraint(equalToConstant: 50),
            
            aadharLabel.topAnchor.constraint(equalTo: mciTextField.bottomAnchor, constant: 20),
            aadharLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            aadharLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            aadharTextField.topAnchor.constraint(equalTo: aadharLabel.bottomAnchor, constant: 20),
            aadharTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            aadharTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            aadharTextField.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    @objc func continueButtonTapped() {
        guard let prefix = selectedPrefix, !prefix.isEmpty,
              let name = nameTextField.text, !name.isEmpty,
              let email = emailTextField.text, !email.isEmpty,
              let mci = mciTextField.text, !mci.isEmpty,
              let aadhar = aadharTextField.text, !aadhar.isEmpty else {
            showAlert(message: "Please fill in all fields.")
            return
        }
        
        if !isValidEmail(email) {
            showAlert(message: "Please enter a valid email address.")
            return
        }

        // Proceed to next registration step
        let step2VC = Registration2ViewController()
        step2VC.phoneNumber = self.phoneNumber
        step2VC.prefix = prefix
        step2VC.name = name
        step2VC.email = email
        step2VC.mciNumber = mci
        step2VC.aadharNumber = aadhar
        navigationController?.pushViewController(step2VC, animated: true)
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailPattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailPattern)
        return emailPredicate.evaluate(with: email)
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Validation Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
