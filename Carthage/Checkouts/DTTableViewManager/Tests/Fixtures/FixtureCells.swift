//
//  NiblessCell.swift
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 15.07.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//

import UIKit
import DTModelStorage

class BaseTestCell : UITableViewCell, ModelTransfer, ModelRetrievable
{
    var model : Any! = nil
    var awakedFromNib = false
    var inittedWithStyle = false
    
#if swift(>=4.2)
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.inittedWithStyle = true
    }
#else
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.inittedWithStyle = true
    }
#endif
    

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.awakedFromNib = true
    }
    
    func update(with model: Int) {
        self.model = model
    }
}

class NiblessCell: BaseTestCell {}

class NibCell: BaseTestCell {
    @IBOutlet weak var customLabel: UILabel?
}

class StringCell : UITableViewCell, ModelTransfer
{
    func update(with model: String) {
        
    }
}

class WrongReuseIdentifierCell : BaseTestCell {}
