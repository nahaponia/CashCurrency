//
//  TableViewCell.swift
//  CashCurrency
//
//  Created by Maxim Poltoratsky on 09.09.2020.
//  Copyright © 2020 Brorgnanization. All rights reserved.
//

import UIKit

final class CurrencyTableViewCell: UITableViewCell {

    @IBOutlet private weak var lblCountryFlag: UILabel!
    @IBOutlet private weak var lblCurrencyName: UILabel!
    @IBOutlet private weak var lblRate: UILabel!
    
    func setupCell(model: CurrencyModel) {
        lblCurrencyName.text = model.name ?? ""
        let flag = countryFlag(countryCode: String(model.code?.dropLast() ?? ""))
        lblRate.text = model.stringRate
        lblCountryFlag.text = flag
    }
    
    private func countryFlag(countryCode: String) -> String {
      return String(String.UnicodeScalarView(
         countryCode.unicodeScalars.compactMap(
           { UnicodeScalar(127397 + $0.value) })))
    }
    
}
