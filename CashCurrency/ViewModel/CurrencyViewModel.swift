//
//  CurrencyViewModel.swift
//  CashCurrency
//
//  Created by Maxim Poltoratsky on 10.09.2020.
//  Copyright © 2020 Brorgnanization. All rights reserved.
//

import Foundation
import Combine

final class CurrencyViewModel {
    
    var currency = [CurrencyModel]()
    private var storage = Set<AnyCancellable>()
    
    func loadCurrency(completion: @escaping () -> ()) {
        CurrencyAPI.currency()
            .sink(receiveCompletion:  { _ in },
                  receiveValue: { [weak self] data in
                    self?.currency = data
                    print(data)
                    completion()
                    
                  })
            .store(in: &storage)
    }
    
}
