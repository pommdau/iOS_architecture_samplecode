//
//  Dispatcher.swift
//  FluxExample
//
//  Created by marty-suzuki on 2018/07/30.
//  Copyright © 2018年 marty-suzuki. All rights reserved.
//
// 複数のスレッドからActionがdipatchされる可能性があるので、Dispatcherでは排他制御が必要

import Foundation

typealias DispatchToken = String

final class Dispatcher {

    static let shared = Dispatcher()  // Dispatcherは1つのコンテキストに応じて1つだけ存在する。そのためシングルトン。

    let lock: NSLocking
    private var callbacks: [DispatchToken: (Action) -> ()]

    init() {
        self.lock = NSRecursiveLock()
        self.callbacks = [:]
    }
    
    
    // Storeから呼び出される
    func register(callback: @escaping (Action) -> ()) -> DispatchToken {
        lock.lock(); defer { lock.unlock() }

        let token =  UUID().uuidString
        callbacks[token] = callback
        return token
    }

    func unregister(_ token: DispatchToken) {
        lock.lock(); defer { lock.unlock() }

        callbacks.removeValue(forKey: token)
    }
    
    // dispatchが呼ばれると、callbacksに登録されているすべてのcallbackに対してActionを伝える
    func dispatch(_ action: Action) {
        lock.lock(); defer { lock.unlock() }
        
        callbacks.forEach { _, callback in
            callback(action)
        }
    }
}
