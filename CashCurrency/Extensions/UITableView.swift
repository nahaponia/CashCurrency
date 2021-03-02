//
//  UITableView.swift
//  CashCurrency
//
//  Created by Maxim Poltoratsky on 09.09.2020.
//  Copyright © 2020 Brorgnanization. All rights reserved.
//

import UIKit

extension UITableView {
    
    /// Nib name and reuseIdentifier must be equal to the class name
    ///
    /// - Parameter cellClass: any class that inherit from UICollectionViewCell
    func registerCell(_ cellClass: UITableViewCell.Type) {
        register(UINib(nibName: "\(cellClass)", bundle: nil), forCellReuseIdentifier: "\(cellClass)")
    }
    
    /// Cell reusable Identifier must be equal to cell class name
    func dequeueReusableCell<T: UITableViewCell>(with type: T.Type, for indexPath: IndexPath) -> T {
        return dequeueReusableCell(withIdentifier: "\(type)", for: indexPath) as! T
    }
    
}
