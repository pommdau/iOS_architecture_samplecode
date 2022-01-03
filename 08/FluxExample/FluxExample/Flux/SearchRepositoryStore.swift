//
//  SearchRepositoryStore.swift
//  FluxExample
//
//  Created by marty-suzuki on 2018/09/16.
//  Copyright © 2018年 marty-suzuki. All rights reserved.
//

import GitHub

final class SearchRepositoryStore: Store {
    // SearchRepositoryStoreは1つしか存在しないのでシングルトン
    static let shared = SearchRepositoryStore(dispatcher: .shared)

    // MARK: - Properties
        
    private(set) var query: String?
    private(set) var pagination: GitHub.Pagination?
    private(set) var isSearchFieldEditing = false
    private(set) var isFetching = false
    private(set) var error: Error?

    private(set) var repositories: [GitHub.Repository] = []  // リポジトリ一覧の配列。Store内でのみ変更可能。
    
    // MARK: - Overrides
    
    // Dispatcherから受け取ったActionに関する処理の実装
    // Dispatcherから受け取ったActionでのみStoreの状態が変更できる
    override func onDispatch(_ action: Action) {
        switch action {
        case let .searchRepositories(repositories):
            self.repositories.append(contentsOf: repositories)

        case .clearSearchRepositories:
            self.repositories.removeAll()

        case let .searchPagination(pagination):
            self.pagination = pagination

        case let .isRepositoriesFetching(isFetching):
            self.isFetching = isFetching

        case let .isSearchFieldEditing(isEditing):
            self.isSearchFieldEditing = isEditing

        case let .error(e):
            self.error = e

        case let .searchQuery(query):
            self.query = query

        case .selectedRepository,
             .setFavoriteRepositories:
            return

        }
        emitChange()  // Storeの変更をViewへ送信
    }
}

