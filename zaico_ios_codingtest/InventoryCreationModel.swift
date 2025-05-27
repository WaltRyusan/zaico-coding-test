//
//  InventoryCreationModel.swift
//  zaico_ios_codingtest
//
//  Created by Ryuzo Hiruma on 2025/05/21.
//

import Foundation

/// 在庫データ作成リクエスト用のモデル
struct InventoryCreateRequest: Encodable {
    let title: String       // 在庫データのタイトル（必須項目）
    let quantity: String?   // 数量（オプション）
    let unit: String?       // 単位（オプション）
    
    // リクエストの初期化
    init(title: String, quantity: String? = nil, unit: String? = nil) {
        self.title = title
        self.quantity = quantity
        self.unit = unit
    }
}

/// 在庫データ作成レスポンス用のモデル
struct InventoryCreateResponse: Decodable {
    let code: Int          // ステータスコード
    let status: String     // 状態
    let message: String    // メッセージ
    let dataId: Int        // 作成した在庫データのID
    
    enum CodingKeys: String, CodingKey {
        case code
        case status
        case message
        case dataId = "data_id"
    }
}

/// 在庫データ作成APIエラーレスポンスのモデル
struct InventoryCreateErrorResponse: Decodable {
    let code: Int          // エラーコード
    let status: String     // エラー状態
    let message: String    // エラーメッセージ
}
