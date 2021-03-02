//
//  CurrencyAPI.swift
//  CashCurrency
//
//  Created by Maxim Poltoratsky on 11.09.2020.
//  Copyright © 2020 Brorgnanization. All rights reserved.
//

import Foundation
import Combine

enum CurrencyAPI {
    static let agent = Agent()
    static let base = URL(string: "https://bank.gov.ua/NBUStatService/v1/statdirectory/exchange?json")!
}

enum EndPoint {
    static let currentRate = ""
}


extension CurrencyAPI {
    
    static func currency() -> AnyPublisher<[CurrencyModel], Error> {
        
        let request = URLRequest(url: base)
        
        return agent.run(request)
            .map(\.value)
            .eraseToAnyPublisher()
    }
}


