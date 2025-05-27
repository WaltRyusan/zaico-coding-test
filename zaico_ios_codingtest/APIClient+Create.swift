//
//  APIClient+Create.swift
//  zaico_ios_codingtest
//
//  Created by Ryuzo Hiruma on 2025/05/21.
//

import Foundation

// APIClientクラスに在庫作成機能を追加する拡張
extension APIClient {
    /// 在庫データを作成するメソッド
    /// - Parameter inventoryData: 作成する在庫データのモデル
    /// - Returns: 作成成功時のレスポンス
    func createInventory(inventoryData: InventoryCreateRequest) async throws -> InventoryCreateResponse {
        // APIエンドポイントの設定
        let endpoint = "/api/v1/inventories"
        
        // URL構築
        guard let url = URL(string: getBaseURL() + endpoint) else {
            throw URLError(.badURL)
        }
        
        // HTTPリクエストの構築
        var request = URLRequest(url: url)
        request.httpMethod = "POST"  // POSTメソッドを使用
        request.setValue("Bearer \(getToken())", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            // リクエストボディをJSONに変換
            let jsonData = try JSONEncoder().encode(inventoryData)
            request.httpBody = jsonData
            
            // デバッグ用にリクエストの内容を出力
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("[APIClient] API Request: \(jsonString)")
            }
            
            // APIリクエストの実行
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // HTTPレスポンスのステータスコードを確認
            if let httpResponse = response as? HTTPURLResponse {
                // デバッグ用にレスポンスの内容を出力
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("[APIClient] API Response: \(jsonString)")
                }
                
                // ステータスコードによって処理を分岐
                switch httpResponse.statusCode {
                case 200...299:
                    // 成功の場合、レスポンスをデコードして返す
                    return try JSONDecoder().decode(InventoryCreateResponse.self, from: data)
                case 400, 406:
                    // エラーの場合、エラーレスポンスをデコードして例外をスロー
                    let errorResponse = try JSONDecoder().decode(InventoryCreateErrorResponse.self, from: data)
                    throw NSError(domain: "APIError",
                                 code: errorResponse.code,
                                 userInfo: ["message": errorResponse.message])
                default:
                    // その他の不明なエラー
                    throw URLError(.badServerResponse)
                }
            }
            
            // HTTPレスポンスでない場合（通常起きない）
            throw URLError(.badServerResponse)
        } catch {
            // その他のエラーを再スロー
            throw error
        }
    }
}
