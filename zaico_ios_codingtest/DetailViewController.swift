//
//  DetailViewController.swift
//  zaico_ios_codingtest
//
//  Created by ryo hirota on 2025/03/11.
//

import UIKit

class DetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private let inventoryId: Int
    private var inventory: Inventory?
    private let tableView = UITableView()
    
    // セルのタイトル順序を変更：画像を最後に
    private let cellTitles = ["ID", "タイトル", "数量", "在庫画像"]
    
    // initメソッドでIDを渡す
    init(id: Int) {
        self.inventoryId = id
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "詳細情報"
        view.backgroundColor = .white
        
        setupTableView()
        
        Task {
            await fetchData()
        }
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.register(InventoryCell.self, forCellReuseIdentifier: "InventoryCell")
        tableView.register(InventoryImageCell.self, forCellReuseIdentifier: "InventoryImageCell")
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
            let data = try await APIClient.shared.fetchInventorie(id: inventoryId)
            await MainActor.run {
                inventory = data
                tableView.reloadData()
            }
        } catch {
            print("Error fetching data: \(error.localizedDescription)")
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellTitles.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0: // ID
            let cell = tableView.dequeueReusableCell(withIdentifier: "InventoryCell", for: indexPath) as! InventoryCell
            cell.configure(leftText: cellTitles[indexPath.row],
                           rightText: String(inventory?.id ?? 0))
            return cell
            
        case 1: // タイトル
            let cell = tableView.dequeueReusableCell(withIdentifier: "InventoryCell", for: indexPath) as! InventoryCell
            cell.configure(leftText: cellTitles[indexPath.row],
                           rightText: inventory?.title ?? "")
            return cell
            
        case 2: // 数量
            let cell = tableView.dequeueReusableCell(withIdentifier: "InventoryCell", for: indexPath) as! InventoryCell
            var quantity = "0"
            if let q = inventory?.quantity {
                quantity = String(q)
            }
            cell.configure(leftText: cellTitles[indexPath.row],
                           rightText: quantity)
            return cell
            
        case 3: // 在庫画像（最後に移動）
            let cell = tableView.dequeueReusableCell(withIdentifier: "InventoryImageCell", for: indexPath) as! InventoryImageCell
            if let imageURL = inventory?.itemImage?.url {
                cell.configure(leftText: cellTitles[indexPath.row],
                              rightImageURLString: imageURL)
            } else {
                cell.configure(leftText: cellTitles[indexPath.row],
                              rightImageURLString: "")
            }
            return cell
            
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "InventoryCell", for: indexPath) as! InventoryCell
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
