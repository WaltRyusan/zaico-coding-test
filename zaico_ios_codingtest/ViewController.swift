//
//  ViewController.swift
//  zaico_ios_codingtest
//
//  Created by ryo hirota on 2025/03/11.
//

import UIKit
import SwiftUI

// 在庫一覧を表示するメイン画面のビューコントローラー
class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, InventoryCreationDelegate {
    private let tableView = UITableView()
    private var inventories: [Inventory] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "在庫一覧"
        
        setupTableView()
        
        // 在庫作成ボタンを追加
        addCreateButton()
        
        // デリゲートを登録
        InventoryCreationDelegateHolder.shared.delegate = self
        
        Task {
            await fetchData()
        }
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.register(InventoryCell.self, forCellReuseIdentifier: "InventoryCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    private func fetchData() async {
        do {
            let data = try await APIClient.shared.fetchInventories()
            await MainActor.run {
                inventories = data
                tableView.reloadData()
            }
        } catch {
            print("Error fetching data: \(error.localizedDescription)")
            
            // エラー表示を追加
            await MainActor.run {
                showErrorAlert(message: error.localizedDescription)
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return inventories.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InventoryCell", for: indexPath) as! InventoryCell
        cell.configure(leftText: String(inventories[indexPath.row].id),
                       rightText: inventories[indexPath.row].title)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailVC = DetailViewController(id: inventories[indexPath.row].id)
        navigationController?.pushViewController(detailVC, animated: true)
        
        // 選択状態を解除
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - SwiftUI在庫作成画面の表示
    /// SwiftUIの在庫作成画面を表示する
    @objc func presentInventoryCreationView() {
        // SwiftUIのビューを作成
        let createInventoryView = CreateInventoryView()
        
        // UIHostingControllerでラップ
        let hostingController = UIHostingController(rootView: createInventoryView)
        
        // モーダルとして表示
        if #available(iOS 15.0, *) {
            // iOS 15以上でシートプレゼンテーションとして表示
            if let sheet = hostingController.sheetPresentationController {
                sheet.detents = [.medium(), .large()]
                sheet.prefersGrabberVisible = true
            }
        }
        
        present(hostingController, animated: true)
    }
    
    /// ナビゲーションバーの「+」ボタンを追加するメソッド
    func addCreateButton() {
        let addButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(presentInventoryCreationView)
        )
        navigationItem.rightBarButtonItem = addButton
    }
    
    // MARK: - InventoryCreationDelegate
    func didCreateInventory(inventoryId: Int) {
        // モーダルを閉じる
        if let presentedVC = presentedViewController {
            presentedVC.dismiss(animated: true) {
                // 在庫一覧を再読み込み
                Task {
                    await self.fetchData()
                }
                
                // 成功メッセージを表示
                self.showSuccessAlert(message: "在庫データID: \(inventoryId)が作成されました")
            }
        }
    }
    
    func didCancelInventoryCreation() {
        // モーダルを閉じる
        if let presentedVC = presentedViewController {
            presentedVC.dismiss(animated: true)
        }
    }
    
    // MARK: - HelperMethod
    /// 成功メッセージを表示
    private func showSuccessAlert(message: String) {
        let alert = UIAlertController(
            title: "成功",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    /// エラーメッセージを表示
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "エラー",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
