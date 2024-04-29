//
//  TabbedTableViewCell.swift
//  OneLogin
//
//  Created by Dubey, Josh on 26/04/2024.
//

import UIKit

class TabbedTableViewCell: UITableViewCell {
    var viewModel: TabbedViewCellModel? {
        didSet {
            textLabel?.text = viewModel?.cellTitle?.value
        }
    }
}
