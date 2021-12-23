//
//  SearchUserViewController.swift
//  MVPSample
//
//  Created by Kenji Tanaka on 2018/09/23.
//  Copyright © 2018年 Kenji Tanaka. All rights reserved.
//

import UIKit
import GitHub

final class SearchUserViewController: UIViewController {
    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var tableView: UITableView!

    private var presenter: SearchUserPresenterInput!
    func inject(presenter: SearchUserPresenterInput) {
        self.presenter = presenter
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }

    private func setup() {
        tableView.estimatedRowHeight = 64
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(UINib(nibName: "UserCell", bundle: nil), forCellReuseIdentifier: "UserCell")
    }
}

// MARK: - UISearchBarDelegate

// ユーザ入力をPresenterに伝える
// 入力値に関するロジックはViewに持たない
extension SearchUserViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        presenter.didTapSearchButton(text: searchBar.text)
    }
}

// MARK: - UITableViewDelegate

extension SearchUserViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        presenter.didSelectRow(at: indexPath)
    }
}

// MARK: - UITableViewDataSource

extension SearchUserViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return presenter.numberOfUsers
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell") as! UserCell

        if let user = presenter.user(forRow: indexPath.row) {
            cell.configure(user: user)
        }

        return cell
    }
}

// MARK: - SearchUserPresenterOutput

// protocol extensionで画面の描画処理を実装
// Viewを受け身にする
extension SearchUserViewController: SearchUserPresenterOutput {
    func updateUsers(_ users: [User]) {
        tableView.reloadData()
    }
    
    func transitionToUserDetail(userName: String) {
        let userDetailVC = UIStoryboard(
            name: "UserDetail",
            bundle: nil)
            .instantiateInitialViewController() as! UserDetailViewController
        let model = UserDetailModel(userName: userName)
        let presenter = UserDetailPresenter(
            userName: userName,
            view: userDetailVC,
            model: model)
        userDetailVC.inject(presenter: presenter)

        navigationController?.pushViewController(userDetailVC, animated: true)
    }
}
