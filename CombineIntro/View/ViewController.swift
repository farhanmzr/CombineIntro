//
//  ViewController.swift
//  CombineIntro
//
//  Created by Farhan Mazario on 13/03/23.
//

import UIKit
import Combine

class ViewController: UIViewController {
    
    private var subscriptions = Set<AnyCancellable>()
    //    private var users: [User] = []
    
    private var viewModel = ViewModel()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.frame = view.bounds
        
        ///without ViewModel
        //        APICaller.shared.getData(type: User.self)
        //            .sink(receiveCompletion: { completion in
        //                switch completion {
        //                case .failure(let err):
        //                    print("Error is \(err.localizedDescription)")
        //                case .finished:
        //                    print("Finished")
        //                }
        //            }, receiveValue: { [weak self] usersData in
        //                self?.users = usersData
        //                self?.tableView.reloadData()
        //            }).store(in: &subscriptions)
        
        viewModel.tweets.sink { [unowned self] message in
            print("message:\(message.description)")
            self.tableView.reloadData()
        }.store(in: &subscriptions)
        
    }
    
    //    func fetchUser() -> AnyPublisher<[User], Never> {
    //        guard let url = url else {
    //            return Just([]).eraseToAnyPublisher()
    //        }
    //
    //        let publisher = URLSession.shared.dataTaskPublisher(for: url)
    //            .map({$0.data})
    //            .decode(type: [User].self, decoder: JSONDecoder())
    //            .catch ({ _ in
    //                Just([])
    //            }).eraseToAnyPublisher()
    //
    //        return publisher
    //    }
}

extension ViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.tweets.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = viewModel.tweets.value[indexPath.row].name
        return cell
    }
    
    
}

