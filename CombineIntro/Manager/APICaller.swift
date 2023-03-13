//
//  APICaller.swift
//  CombineIntro
//
//  Created by Farhan Mazario on 13/03/23.
//

import Foundation
import Combine

class APICaller {
    
    static let shared = APICaller()
    
    let url = URL(string: "https://jsonplaceholder.typicode.com/users")
    
    private init(){
        
    }
    
    private var subscriptions = Set<AnyCancellable>()
    
    func getData<T: Decodable>(type: T.Type) -> Future<[T], Error> {
            return Future<[T], Error> { [weak self] promise in
                guard let self = self, let url = self.url else {
                    return promise(.failure(NetworkError.invalidURL))
                }
                
                URLSession.shared.dataTaskPublisher(for: url)
                    .tryMap { (data, response) -> Data in
                        guard let httpResponse = response as? HTTPURLResponse, 200...299 ~= httpResponse.statusCode else {
                            throw NetworkError.responseError
                        }
                        return data
                    }
                    .decode(type: [T].self, decoder: JSONDecoder())
                    .receive(on: DispatchQueue.main)
                    .sink(receiveCompletion: { (completion) in
                        if case let .failure(error) = completion {
                            switch error {
                            case let decodingError as DecodingError:
                                promise(.failure(decodingError))
                            case let apiError as NetworkError:
                                promise(.failure(apiError))
                            default:
                                promise(.failure(NetworkError.unknown))
                            }
                        }
                    }, receiveValue: { promise(.success($0)) })
                    .store(in: &self.subscriptions)
            }
        }
    }
    


enum NetworkError: Error {
    case invalidURL
    case responseError
    case unknown
}

extension NetworkError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return NSLocalizedString("Invalid URL", comment: "Invalid URL")
        case .responseError:
            return NSLocalizedString("Unexpected status code", comment: "Invalid response")
        case .unknown:
            return NSLocalizedString("Unknown error", comment: "Unknown error")
        }
    }
}
