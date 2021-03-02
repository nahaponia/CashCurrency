//
//  CurrencyModel.swift
//  CashCurrency
//
//  Created by Maxim Poltoratsky on 09.09.2020.
//  Copyright © 2020 Brorgnanization. All rights reserved.
//

import Foundation

struct CurrencyModel: Codable {
    
    var name: String?
    var rate: Float?
    var exchangedate: String?
    var code: String?
    
    var stringRate: String  {
        return String(rate ?? 0)
    }
    
    enum CodingKeys: String, CodingKey {
        case name = "txt"
        case code = "cc"
        case rate
        case exchangedate
    }

}
