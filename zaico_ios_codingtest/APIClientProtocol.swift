//
//  APIClientProtocol.swift
//  zaico_ios_codingtest
//
//  Created by Ryuzo Hiruma on 2025/05/25.
//

import Foundation

// APIクライアントが提供すべき機能を定義するプロトコル
protocol APIClientProtocol {
    // 在庫一覧を取得する
    func fetchInventories() async throws -> [Inventory]
    // 特定の在庫詳細を取得する
    func fetchInventorie(id: Int?) async throws -> Inventory
    // 在庫データを作成する
    func createInventory(inventoryData: InventoryCreateRequest) async throws -> InventoryCreateResponse
    // トークンが更新されたことを通知する
    func tokenDidUpdate()
}
