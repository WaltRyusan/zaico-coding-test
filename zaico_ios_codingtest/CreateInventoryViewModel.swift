//
//  CreateInventoryViewModel.swift
//  zaico_ios_codingtest
//
//  Created by Ryuzo Hiruma on 2025/05/21.
//

import Foundation
import SwiftUI

// 在庫データ作成画面のViewModel
class CreateInventoryViewModel: ObservableObject {
    // 入力フィールド
    @Published var title: String = ""
    @Published var quantity: String = ""
    @Published var unit: String = ""
    
    // 状態管理
    @Published var isLoading: Bool = false
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    @Published var isSuccess: Bool = false
    @Published var createdInventoryId: Int? = nil
    
    // APIクライアント - プロトコル型で依存関係を抽象化
    private let apiClient: APIClientProtocol
    
    // 依存性注入を使用した初期化
    init(apiClient: APIClientProtocol = APIClient.shared) {
        self.apiClient = apiClient
    }
    
    /// 在庫データを作成するメソッド
    func createInventory() async {
        // 読み込み中フラグをON
        await MainActor.run { isLoading = true }
        
        do {
            // 入力チェック
            guard !title.isEmpty else {
                await MainActor.run {
                    alertMessage = "タイトルを入力してください"
                    showAlert = true
                    isLoading = false
                }
                return
            }
            
            // リクエストモデルの作成
            let request = InventoryCreateRequest(
                title: title,
                quantity: quantity.isEmpty ? nil : quantity,
                unit: unit.isEmpty ? nil : unit
            )
            
            // API呼び出し
            // 注入されたAPIクライアントを使用
            let response = try await apiClient.createInventory(inventoryData: request)
            
            // 成功時の処理
            await MainActor.run {
                isLoading = false
                isSuccess = true
                createdInventoryId = response.dataId
                alertMessage = "在庫データが作成されました（ID: \(response.dataId)）"
                showAlert = true
                
                // 入力フィールドをクリア
                if isSuccess {
                    title = ""
                    quantity = ""
                    unit = ""
                }
                
                // APIClientのトークン更新を通知
                apiClient.tokenDidUpdate()
            }
        } catch {
            // エラー時の処理
            await MainActor.run {
                isLoading = false
                isSuccess = false
                alertMessage = "エラー: \(error.localizedDescription)"
                showAlert = true
            }
        }
    }
    
    /// キャンセル処理
    func cancel() {
        // デリゲートに通知
        InventoryCreationDelegateHolder.shared.delegate?.didCancelInventoryCreation()
    }
}

// テスト用の拡張
extension CreateInventoryViewModel {
    var isFormValid: Bool {
        return !title.isEmpty
    }
    
    func validateQuantity() {
        quantity = quantity.filter { "0123456789".contains($0) }
    }
}
