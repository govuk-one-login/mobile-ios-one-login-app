import GDSCommon
import UIKit

class TabbedViewSectionFooter: UIView {
    private let title: GDSLocalisedString?
    private var sectionFooterLabel = UILabel()
    
    init(title: GDSLocalisedString? = nil) {
        self.title = title
        super.init(frame: .zero)
        configureView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureView() {
        sectionFooterLabel.numberOfLines = 0
        sectionFooterLabel.lineBreakMode = .byWordWrapping
        sectionFooterLabel.text = title?.value
        sectionFooterLabel.font = .footnote
        sectionFooterLabel.textColor = .secondaryLabel
        sectionFooterLabel.adjustsFontForContentSizeCategory = true
        sectionFooterLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(sectionFooterLabel)
        sectionFooterLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
        sectionFooterLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
        sectionFooterLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8).isActive = true
        sectionFooterLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }

}
