//
//  Date.swift
//  CashCurrency
//
//  Created by Maxim Poltoratsky on 09.09.2020.
//  Copyright © 2020 Brorgnanization. All rights reserved.
//

import UIKit

struct DateManager {
    
    static func currentDateTime() -> String {

        let date = DateFormatter.localizedString(from: Date(),
                                                 dateStyle: .medium,
                                                 timeStyle: .none)
        
        return "Курс грн. НБУ на " + date
        
    }
    
}
