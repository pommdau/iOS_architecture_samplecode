//
//  RepositorySearchViewController.swift
//  FluxExample
//
//  Created by marty-suzuki on 2018/09/16.
//  Copyright © 2018年 marty-suzuki. All rights reserved.
//

import UIKit

final class RepositorySearchViewController: UIViewController {

    // MARK: - Properties
        
    @IBOutlet private(set) weak var tableView: UITableView!
    @IBOutlet private(set) weak var searchBar: UISearchBar!
    
    // ViewがStoreを持つ: SearchRepositoryStore / SelectedRepositoryStore
    private let searchStore: SearchRepositoryStore
    private let selectedStore: SelectedRepositoryStore
    
    // // ViewがActionCreater持つ
    private let actionCreator: ActionCreator
    
    private let dataSource: RepositorySearchDataSource
    
    private let debounce = DispatchQueue.main.debounce(delay: .milliseconds(300))

    private lazy var reloadSubscription: Subscription = {
        // SearchRepositoryStoreのaddListenerで変更を監視している
        // -> Storeが更新されるとcallBackが呼び出される
        // -> callBackではUITableViewの更新を行う(リポジトリの一覧が画面に反映される)
        return searchStore.addListener { [weak self] in
            self?.debounce {
                self?.tableView.reloadData()
                self?.refrectEditing()
            }
        }
    }()

    // MARK: - Lifecycles
    
    deinit {
        searchStore.removeListener(reloadSubscription)
    }

    init(searchStore: SearchRepositoryStore = .shared,
         selectedStore: SelectedRepositoryStore = .shared,
         actionCreator: ActionCreator = .init()) {
        self.searchStore = searchStore
        self.selectedStore = selectedStore
        self.actionCreator = actionCreator
        self.dataSource = RepositorySearchDataSource(searchStore: searchStore,
                                                     actionCreator: actionCreator)
        super.init(nibName: "RepositorySearchViewController", bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Search Repositories"

        dataSource.configure(tableView)
        searchBar.delegate = self 

        _ = reloadSubscription
    }
    
    // MARK: - Helpers
    
    private func refrectEditing() {
        UIView.animate(withDuration: 0.3) {
            if self.searchStore.isSearchFieldEditing {
                self.view.backgroundColor = .black
                self.tableView.isUserInteractionEnabled = false
                self.tableView.alpha = 0.5
                self.searchBar.setShowsCancelButton(true, animated: true)
            } else {
                self.searchBar.resignFirstResponder()
                self.view.backgroundColor = .white
                self.tableView.isUserInteractionEnabled = true
                self.tableView.alpha = 1
                self.searchBar.setShowsCancelButton(false, animated: true)
            }
        }
    }
}

// MARK: - UISearchBarDelegate

extension RepositorySearchViewController: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        actionCreator.setIsSearchFieldEditing(true)
        return true
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        actionCreator.setIsSearchFieldEditing(false)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let text = searchBar.text, !text.isEmpty {
            actionCreator.clearRepositories()  // actionCreaterで配列を空にする
            actionCreator.searchRepositories(query: text)  // リポジトリを検索
            actionCreator.setIsSearchFieldEditing(false)
        }
    }
}
