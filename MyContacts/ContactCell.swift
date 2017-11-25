//
//  ContactCell.swift
//  MyContacts
//
//  Created by Alexey Danilov on 25/11/2017.
//  Copyright © 2017 DanilovDev. All rights reserved.
//

import Foundation
import UIKit

protocol FavoriteDelegate {
    func favoriteTapped(cell: ContactCell)
}

class ContactCell: UITableViewCell {
    
    var favoriteDelegate: FavoriteDelegate!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let starImage = UIImage(named: "ic_star_48pt")?.withRenderingMode(.alwaysTemplate)
        let starButton = UIButton(type: .system)
        starButton.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        starButton.setImage(starImage, for: .normal)
        starButton.tintColor = .lightGray
        starButton.addTarget(self, action: #selector(favoriteTapped), for: .touchUpInside)
        self.accessoryView = starButton
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func favoriteTapped() {
        self.favoriteDelegate.favoriteTapped(cell: self)
    }
}
