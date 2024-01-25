import Attestation
import UIKit

@available(iOS 14.0, *)
class AppAttestViewController: UIViewController {
    override var nibName: String? { "AppAttestView" }
    let attestService = AttestationService.self
        
    init() {
        super.init(nibName: "AppAttestView", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        Task {
            do {
                try await attestService.generate()
            } catch {
                print("No Key generated")
            }
        }
    }
    
    @IBOutlet private var appAttestLabel: UILabel! {
        didSet {
            appAttestLabel.text = "App Attest Spike"
        }
    }
    
    @IBOutlet private var verifyButtonOutlet: UIButton! {
        didSet {
            verifyButtonOutlet.setTitle("Verify", for: .normal)
        }
    }
    
    @IBAction private func verifyButtonAction(_ sender: Any) {
        Task {
            do {
                try await attestService.verify()
            } catch {
                print("Not verified error: \(error)")
            }
        }
    }
    
    @IBOutlet private var makeRequestOutlet: UIButton! {
        didSet {
            makeRequestOutlet.setTitle("Request", for: .normal)
        }
    }
    
    @IBAction private func makeRequestAction(_ sender: Any) {
        Task {
            do {
                print(try await String(data: attestService.makeSignedRequest(), encoding: .utf8))
            } catch {
                print("Request not successful: \(error)")
            }
        }
    }
}
