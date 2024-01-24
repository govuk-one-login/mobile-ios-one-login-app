import UIKit

class AppAttestViewController: UIViewController {
    override var nibName: String? { "AppAttestView" }
        
    init() {
        super.init(nibName: "AppAttestView", bundle: nil)
    }
    
    @IBOutlet private var appAttestLabel: UILabel! {
        didSet {
            appAttestLabel.text = "App Attest Spike"
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBOutlet private var verifyButtonOutlet: UIButton! {
        didSet {
            verifyButtonOutlet.setTitle("Verify", for: .normal)
        }
    }
    
    @IBAction private func verifyButtonAction(_ sender: Any) {
        
    }
    
    @IBOutlet private var makeRequestOutlet: UIButton! {
        didSet {
            makeRequestOutlet.setTitle("Request", for: .normal)
        }
    }
    
    @IBAction private func makeRequestAction(_ sender: Any) {
        
    }
}
