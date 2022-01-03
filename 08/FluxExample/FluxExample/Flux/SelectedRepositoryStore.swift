//
//  SelectedRepositoryStore.swift
//  FluxExample
//
//  Created by marty-suzuki on 2018/09/16.
//  Copyright © 2018年 marty-suzuki. All rights reserved.
//

import GitHub

final class SelectedRepositoryStore: Store {
    // SelectedRepositoryStoreは1つしか存在しないのでシングルトン
    static let shared = SelectedRepositoryStore(dispatcher: .shared)

    private(set) var repository: GitHub.Repository?
    
    // ActionをDispatcherから受け取った場合…self.repositoryを更新
    override func onDispatch(_ action: Action) {
        switch action {
        case let .selectedRepository(repository):
            self.repository = repository

        case .searchRepositories,
             .clearSearchRepositories,
             .searchPagination,
             .isRepositoriesFetching,
             .isSearchFieldEditing,
             .error,
             .searchQuery,
             .setFavoriteRepositories:
            return
        }
        emitChange()
    }
}

