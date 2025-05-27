//
//  APIClient+Protocol.swift
//  zaico_ios_codingtest
//
//  Created by opst-7278 on 2025/05/25.
//

import Foundation

// 既存のAPIClientクラスをプロトコルに準拠させる
extension APIClient: APIClientProtocol {
    // fetchInventories(), fetchInventorie(id:), createInventory()は既に実装済み
    func tokenDidUpdate() {
    }
}

// トークン更新の通知名
extension Notification.Name {
    static let apiTokenDidUpdate = Notification.Name("APITokenDidUpdate")
}
