//
//  Network.swift
//  CashCurrency
//
//  Created by Maxim Poltoratsky on 09.09.2020.
//  Copyright © 2020 Brorgnanization. All rights reserved.
//

import Foundation
import Combine

struct Agent {
    
    struct Response<T> {
        let value: T
        let response: URLResponse
    }
    
    func run<T: Decodable>(_ request: URLRequest,
                           _ decoder: JSONDecoder = JSONDecoder()) -> AnyPublisher<Response<T>, Error> {
        return URLSession.shared
            .dataTaskPublisher(for: request)
            .tryMap { result -> Response<T> in
                let value = try decoder.decode(T.self, from: result.data)
                return Response(value: value, response: result.response)
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
