//
//  ViewModel.swift
//  CombineIntro
//
//  Created by Farhan Mazario on 13/03/23.
//

import Foundation
import Combine

class ViewModel {
    
    let tweets = CurrentValueSubject<[User], Never>([User]())
    private var subscriptions = Set<AnyCancellable>()
    private var users: [User] = []
    

    init() {
        APICaller.shared.getData(type: User.self)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let err):
                    print("Error is \(err.localizedDescription)")
                case .finished:
                    print("Finished")
                }
            }, receiveValue: { [weak self] usersData in
                self?.users = usersData
                self?.tweets.send(usersData)
            }).store(in: &subscriptions)
    }
    
    
    
    
}
