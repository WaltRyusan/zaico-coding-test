//
//  InventoryCreationDelegate.swift
//  zaico_ios_codingtest
//
//  Created by Ryuzo Hiruma on 2025/05/21.
//

import Foundation

//  在庫作成の結果をUIKitコントローラーに通知するためのデリゲート
protocol InventoryCreationDelegate: AnyObject {
    /// 在庫作成が成功した時に呼ばれるメソッド
    /// - Parameter inventoryId: 作成された在庫のID
    func didCreateInventory(inventoryId: Int)
    
    /// 在庫作成がキャンセルされた時に呼ばれるメソッド
    func didCancelInventoryCreation()
}

/// デリゲートを保持するクラス（SwiftUIとUIKit間のブリッジ）
class InventoryCreationDelegateHolder {
    /// シングルトンインスタンス
    static let shared = InventoryCreationDelegateHolder()
    
    /// デリゲート
    weak var delegate: InventoryCreationDelegate?
    
    /// プライベート初期化
    private init() {}
}
