//
//  Store.swift
//  FluxExample
//
//  Created by marty-suzuki on 2018/07/31.
//  Copyright © 2018年 marty-suzuki. All rights reserved.
//
// 今回はGitHubのりポジとr検索という役割でStoreを実装する

import Foundation

typealias Subscription = NSObjectProtocol

class Store {
    
    // MARK: - Properties
    
    private enum NotificationName {
        static let storeChanged = Notification.Name("store-changed")
    }

    private lazy var dispatchToken: DispatchToken = {
        // callbackを登録
        return dispatcher.register(callback: { [weak self] action in
            // Callbackでは、受け取ったActonを処理するための処理を呼び出す
            self?.onDispatch(action)
        })
    }()

    private let dispatcher: Dispatcher  // StoreはDispatcherを持つ
    private let notificationCenter: NotificationCenter
    
    // MARK: - Lifecycles
    
    deinit {
        // Storeが破棄される際には、DispathcerからStoreのcallbackの登録解除をする
        dispatcher.unregister(dispatchToken)
    }

    init(dispatcher: Dispatcher) {
        self.dispatcher = dispatcher
        self.notificationCenter = NotificationCenter()
        _ = dispatchToken
    }
    
    // MARK: - Helpers

    func onDispatch(_ action: Action) {
        // Storeでオーバライドする
        fatalError("must override")
    }

    // Storeの変更をViewへ送信する
    final func emitChange() {
        notificationCenter.post(name: NotificationName.storeChanged, object: nil)
    }

    // ViewがStoreの変更を監視するためのもの
    final func addListener(callback: @escaping () -> ()) -> Subscription {
        let using: (Notification) -> () = { notification in
            if notification.name == NotificationName.storeChanged {
                callback()
            }
        }
        // StoreのNotificationCenterに監視登録する
        return notificationCenter.addObserver(forName: NotificationName.storeChanged,
                                              object: nil,
                                              queue: nil,
                                              using: using)
    }
    
    // ViewがStoreの監視を中止する
    final func removeListener(_ subscription: Subscription) {
        notificationCenter.removeObserver(subscription)
    }
}
