import UIKit
import FirebaseStorage
import FirebaseFirestore

// MARK: - Document Upload View
class DocumentUploadView: UIView {
    enum DocumentType {
        case aadhaar
        case pan
        
        var title: String {
            switch self {
            case .aadhaar: return "Aadhaar Card"
            case .pan: return "PAN Card"
            }
        }
    }
    
    private let titleLabel = UILabel()
    private let frontPreviewView = UIView()
    private let backPreviewView = UIView()
    private let frontImageView = UIImageView()
    private let backImageView = UIImageView()
    private let frontUploadButton = UIButton()
    private let backUploadButton = UIButton()
    private let frontProgressView = UIProgressView()
    private let backProgressView = UIProgressView()
    
    private let documentType: DocumentType
    private var frontImageURL: String?
    private var backImageURL: String?
    private var onUploadComplete: ((String, String) -> Void)?
    
    init(documentType: DocumentType, onUploadComplete: @escaping (String, String) -> Void) {
        self.documentType = documentType
        self.onUploadComplete = onUploadComplete
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .systemBackground
        layer.cornerRadius = 12
        layer.borderWidth = 1
        layer.borderColor = UIColor.systemGray5.cgColor
        
        setupTitleLabel()
        setupPreviewViews()
        setupButtons()
        setupProgressViews()
        setupConstraints()
    }
    
    private func setupTitleLabel() {
        titleLabel.text = documentType.title
        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
    }
    
    private func setupPreviewViews() {
        [frontPreviewView, backPreviewView].forEach { view in
            view.backgroundColor = .systemGray6
            view.layer.cornerRadius = 8
            view.clipsToBounds = true
            view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(view)
        }
        
        [frontImageView, backImageView].forEach { imageView in
            imageView.contentMode = .scaleAspectFit
            imageView.backgroundColor = .clear
            imageView.translatesAutoresizingMaskIntoConstraints = false
        }
        
        frontPreviewView.addSubview(frontImageView)
        backPreviewView.addSubview(backImageView)
    }
    
    private func setupButtons() {
        [frontUploadButton, backUploadButton].forEach { button in
            button.backgroundColor = .systemBlue
            button.layer.cornerRadius = 8
            button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
            button.translatesAutoresizingMaskIntoConstraints = false
            addSubview(button)
        }
        
        frontUploadButton.setTitle("Upload Front", for: .normal)
        backUploadButton.setTitle("Upload Back", for: .normal)
        
        frontUploadButton.addTarget(self, action: #selector(uploadFrontTapped), for: .touchUpInside)
        backUploadButton.addTarget(self, action: #selector(uploadBackTapped), for: .touchUpInside)
    }
    
    private func setupProgressViews() {
        [frontProgressView, backProgressView].forEach { progressView in
            progressView.progressTintColor = .systemBlue
            progressView.trackTintColor = .systemGray5
            progressView.progress = 0
            progressView.isHidden = true
            progressView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(progressView)
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            frontPreviewView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            frontPreviewView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            frontPreviewView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.45),
            frontPreviewView.heightAnchor.constraint(equalTo: frontPreviewView.widthAnchor, multiplier: 0.63),
            
            backPreviewView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            backPreviewView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            backPreviewView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.45),
            backPreviewView.heightAnchor.constraint(equalTo: backPreviewView.widthAnchor, multiplier: 0.63),
            
            frontImageView.topAnchor.constraint(equalTo: frontPreviewView.topAnchor),
            frontImageView.leadingAnchor.constraint(equalTo: frontPreviewView.leadingAnchor),
            frontImageView.trailingAnchor.constraint(equalTo: frontPreviewView.trailingAnchor),
            frontImageView.bottomAnchor.constraint(equalTo: frontPreviewView.bottomAnchor),
            
            backImageView.topAnchor.constraint(equalTo: backPreviewView.topAnchor),
            backImageView.leadingAnchor.constraint(equalTo: backPreviewView.leadingAnchor),
            backImageView.trailingAnchor.constraint(equalTo: backPreviewView.trailingAnchor),
            backImageView.bottomAnchor.constraint(equalTo: backPreviewView.bottomAnchor),
            
            frontUploadButton.topAnchor.constraint(equalTo: frontPreviewView.bottomAnchor, constant: 8),
            frontUploadButton.leadingAnchor.constraint(equalTo: frontPreviewView.leadingAnchor),
            frontUploadButton.trailingAnchor.constraint(equalTo: frontPreviewView.trailingAnchor),
            frontUploadButton.heightAnchor.constraint(equalToConstant: 40),
            
            backUploadButton.topAnchor.constraint(equalTo: backPreviewView.bottomAnchor, constant: 8),
            backUploadButton.leadingAnchor.constraint(equalTo: backPreviewView.leadingAnchor),
            backUploadButton.trailingAnchor.constraint(equalTo: backPreviewView.trailingAnchor),
            backUploadButton.heightAnchor.constraint(equalToConstant: 40),
            
            frontProgressView.topAnchor.constraint(equalTo: frontUploadButton.bottomAnchor, constant: 8),
            frontProgressView.leadingAnchor.constraint(equalTo: frontPreviewView.leadingAnchor),
            frontProgressView.trailingAnchor.constraint(equalTo: frontPreviewView.trailingAnchor),
            
            backProgressView.topAnchor.constraint(equalTo: backUploadButton.bottomAnchor, constant: 8),
            backProgressView.leadingAnchor.constraint(equalTo: backPreviewView.leadingAnchor),
            backProgressView.trailingAnchor.constraint(equalTo: backPreviewView.trailingAnchor),
            
            bottomAnchor.constraint(equalTo: frontProgressView.bottomAnchor, constant: 16)
        ])
    }
    
    @objc private func uploadFrontTapped() {
        presentImagePicker(for: .front)
    }
    
    @objc private func uploadBackTapped() {
        presentImagePicker(for: .back)
    }
    
    private enum Side {
        case front
        case back
    }
    
    private func presentImagePicker(for side: Side) {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.accessibilityHint = "\(documentType.title)_\(side)"
        
        if let topVC = UIApplication.shared.keyWindow?.rootViewController {
            topVC.present(picker, animated: true)
        }
    }
    
    private func uploadImage(_ image: UIImage, for side: Side) {
        let fileName = "\(UUID().uuidString)_\(documentType.title)_\(side).jpg"
        let storageRef = Storage.storage().reference().child("documents/\(fileName)")
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }
        
        let progressView = side == .front ? frontProgressView : backProgressView
        let uploadButton = side == .front ? frontUploadButton : backUploadButton
        
        progressView.isHidden = false
        uploadButton.isEnabled = false
        
        let uploadTask = storageRef.putData(imageData, metadata: nil) { [weak self] metadata, error in
            guard let self = self else { return }
            
            progressView.isHidden = true
            uploadButton.isEnabled = true
            
            if let error = error {
                self.showError(error.localizedDescription)
                return
            }
            
            storageRef.downloadURL { url, error in
                if let error = error {
                    self.showError(error.localizedDescription)
                    return
                }
                
                if let downloadURL = url?.absoluteString {
                    if side == .front {
                        self.frontImageURL = downloadURL
                    } else {
                        self.backImageURL = downloadURL
                    }
                    
                    if let frontURL = self.frontImageURL,
                       let backURL = self.backImageURL {
                        self.onUploadComplete?(frontURL, backURL)
                    }
                }
            }
        }
        
        uploadTask.observe(.progress) { snapshot in
            let progress = Float(snapshot.progress?.completedUnitCount ?? 0) / Float(snapshot.progress?.totalUnitCount ?? 1)
            progressView.progress = progress
        }
    }
    
    private func showError(_ message: String) {
        if let topVC = UIApplication.shared.keyWindow?.rootViewController {
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            topVC.present(alert, animated: true)
        }
    }
}

// MARK: - Document Upload View UIImagePickerController Extension
extension DocumentUploadView: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage,
              let hint = picker.accessibilityHint else {
            picker.dismiss(animated: true)
            return
        }
        
        let side: Side = hint.contains("front") ? .front : .back
        
        if side == .front {
            frontImageView.image = image
        } else {
            backImageView.image = image
        }
        
        picker.dismiss(animated: true) { [weak self] in
            self?.uploadImage(image, for: side)
        }
    }
}
