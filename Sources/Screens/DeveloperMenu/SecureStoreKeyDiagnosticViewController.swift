import GDSCommon
import SecureStore
import UIKit

final class SecureStoreKeyDiagnosticViewController: UIViewController {
    private let storeID: String
    private let accessControlLevel: SecureStorageConfiguration.AccessControlLevel

    private let resultLabel = UILabel()
    private let originalPublicKeyLabel = UILabel()
    private let storedPublicKeyLabel = UILabel()
    private let refreshButton = RoundedButton()
    private let deleteButton = RoundedButton()

    init(
        storeID: String = OLString.v13TokenInfoStore,
        accessControlLevel: SecureStorageConfiguration.AccessControlLevel = .open
    ) {
        self.storeID = storeID
        self.accessControlLevel = accessControlLevel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Secure Store Keys"
        view.backgroundColor = .systemBackground
        configureLayout()
        refreshKeys()
    }
}

private extension SecureStoreKeyDiagnosticViewController {
    func configureLayout() {
        let scrollView = UIScrollView()
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(
            top: 24,
            leading: 16,
            bottom: 24,
            trailing: 16
        )

        let headingLabel = makeLabel(
            text: "Store ID\n\(storeID)",
            font: .bodyBold
        )


        [resultLabel, originalPublicKeyLabel, storedPublicKeyLabel].forEach {
            $0.font = .body
            $0.numberOfLines = 0
            $0.lineBreakMode = .byCharWrapping
        }

        refreshButton.setTitle("Refresh Keys", for: .normal)
        refreshButton.titleLabel?.adjustsFontForContentSizeCategory = true
        refreshButton.addTarget(
            self,
            action: #selector(refreshKeys),
            for: .touchUpInside
        )

        deleteButton.setTitle("Delete Keys", for: .normal)
        deleteButton.titleLabel?.adjustsFontForContentSizeCategory = true
        deleteButton.addTarget(
            self,
            action: #selector(deleteKeysButtonAction),
            for: .touchUpInside
        )

        stackView.addArrangedSubview(headingLabel)
        stackView.addArrangedSubview(resultLabel)
        stackView.addArrangedSubview(originalPublicKeyLabel)
        stackView.addArrangedSubview(storedPublicKeyLabel)
        stackView.addArrangedSubview(refreshButton)
        stackView.addArrangedSubview(deleteButton)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
    }

    func makeLabel(text: String, font: UIFont) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = font
        label.numberOfLines = 0
        return label
    }

    func createKeysIfNeeded() {
        let configuration = SecureStorageConfiguration(
            id: storeID,
            accessControlLevel: accessControlLevel
        )
        _ = SecureStoreService(configuration: configuration)
    }

    func publicKeyData(privateKeyTag: String) throws -> Data {
        let privateKey = try privateKey(tag: privateKeyTag)
        guard let publicKey = SecKeyCopyPublicKey(privateKey) else {
            throw KeyDiagnosticError.cantCopyPublicKey
        }

        var error: Unmanaged<CFError>?
        guard let publicKeyData = SecKeyCopyExternalRepresentation(publicKey, &error) as Data? else {
            if let retainedError = error?.takeRetainedValue() {
                throw retainedError as Error
            }
            throw KeyDiagnosticError.cantExportPublicKey
        }

        return publicKeyData
    }

    func privateKey(tag: String) throws -> SecKey {
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: Data(tag.utf8),
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecReturnRef as String: true
        ]

        var privateKeyRef: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &privateKeyRef)

        guard status == errSecSuccess, let privateKey = privateKeyRef else {
            throw KeyDiagnosticError.cantRetrieveKey(tag: tag, status: status)
        }

        return privateKey as! SecKey
    }

    @objc func refreshKeys() {
        do {
            createKeysIfNeeded()

            let originalPublicKey = try publicKeyData(privateKeyTag: storeID)
            let storedPublicKey = try publicKeyData(privateKeyTag: "\(storeID)PrivateKey")
            let keysMatch = originalPublicKey == storedPublicKey

            resultLabel.textColor = keysMatch ? .accent : .red
            resultLabel.text = keysMatch ? "Result: PASS" : "Result: FAIL"
            originalPublicKeyLabel.text = """
            \(storeID) public key:
            \(originalPublicKey.base64EncodedString())
            """
            storedPublicKeyLabel.text = """
            \(storeID)PrivateKey public key:
            \(storedPublicKey.base64EncodedString())
            """
        } catch {
            resultLabel.textColor = .red
            resultLabel.text = "Result: ERROR\n\(error.localizedDescription)"
            originalPublicKeyLabel.text = "\(storeID) public key: unavailable"
            storedPublicKeyLabel.text = "\(storeID)PrivateKey public key: unavailable"
        }
    }

    @objc func deleteKeysButtonAction() {
        [
            storeID,
            "\(storeID)PrivateKey",
            "\(storeID)PublicKey"
        ].forEach(deleteKey)

        deleteButton.backgroundColor = .gdsBrightPurple
        resultLabel.textColor = .accent
        resultLabel.text = "Keys deleted"
        originalPublicKeyLabel.text = "\(storeID) public key: unavailable"
        storedPublicKeyLabel.text = "\(storeID)PrivateKey public key: unavailable"
    }

    func deleteKey(tag: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: Data(tag.utf8)
        ]
        SecItemDelete(query as CFDictionary)
    }
}

private enum KeyDiagnosticError: LocalizedError {
    case cantRetrieveKey(tag: String, status: OSStatus)
    case cantCopyPublicKey
    case cantExportPublicKey

    var errorDescription: String? {
        switch self {
        case let .cantRetrieveKey(tag, status):
            "Could not retrieve key tagged \(tag). OSStatus: \(status)"
        case .cantCopyPublicKey:
            "Could not copy the public key from the private key."
        case .cantExportPublicKey:
            "Could not export the public key."
        }
    }
}
