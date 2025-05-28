
//
//  InventoryCell 2.swift
//  zaico_ios_codingtest
//
//  Created by ryo hirota on 2025/03/11.
//

import UIKit

class InventoryImageCell: UITableViewCell {
    
    // MARK: - Constants
    private enum Constants {
        static let horizontalPadding: CGFloat = 16
        static let verticalPadding: CGFloat = 12
        static let labelSpacing: CGFloat = 8
        static let cornerRadius: CGFloat = 8
        static let noImageText = "no image"
    }
    
    // MARK: - UI Components
    private let titleLabel = UILabel()
    private let inventoryImageView = UIImageView()
    private let noImageLabel = UILabel()
    
    // MARK: - Properties
    private var imageTask: Task<Void, Never>?
    private var imageViewHeightConstraint: NSLayoutConstraint?
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUserInterface()
        setupConstraints()
        setupAccessibility()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func prepareForReuse() {
        super.prepareForReuse()
        imageTask?.cancel()
        inventoryImageView.image = nil
        inventoryImageView.isHidden = true
        noImageLabel.isHidden = true
    }
    
    // MARK: - Setup Methods
    private func setupUserInterface() {
        // セルの基本設定
        selectionStyle = .none
        
        // Title Label設定
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Image View設定（画面横幅いっぱい、1:1の正方形）
        inventoryImageView.contentMode = .scaleAspectFit  // アスペクト比保持でフィット
        inventoryImageView.clipsToBounds = true
        inventoryImageView.layer.cornerRadius = Constants.cornerRadius
        inventoryImageView.translatesAutoresizingMaskIntoConstraints = false
        inventoryImageView.isHidden = true  // 初期状態は非表示
        
        // No Image Label設定
        noImageLabel.text = Constants.noImageText
        noImageLabel.font = .systemFont(ofSize: 14)
        noImageLabel.textColor = .systemGray3
        noImageLabel.textAlignment = .center
        noImageLabel.translatesAutoresizingMaskIntoConstraints = false
        noImageLabel.isHidden = true  // 初期状態は非表示
        
        // Content Hugging & Compression Resistance
        titleLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        
        // Add subviews
        contentView.addSubview(titleLabel)
        contentView.addSubview(inventoryImageView)
        contentView.addSubview(noImageLabel)
    }
    
    private func setupConstraints() {
        // 初期制約設定（後でlayoutSubviewsで正確な値に更新）
        imageViewHeightConstraint = inventoryImageView.heightAnchor.constraint(equalToConstant: 300)
        
        NSLayoutConstraint.activate([
            // Title Label制約（一番上）
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.verticalPadding),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.horizontalPadding),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.horizontalPadding),
            
            // Image View制約（一番下、画面横幅いっぱいの正方形）
            inventoryImageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Constants.labelSpacing),
            inventoryImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.horizontalPadding),
            inventoryImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.horizontalPadding),
            inventoryImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.verticalPadding),
            imageViewHeightConstraint!,
            
            // No Image Label制約（Image Viewと同じ位置）
            noImageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Constants.labelSpacing),
            noImageLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.horizontalPadding),
            noImageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.horizontalPadding),
            noImageLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.verticalPadding)
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // セルの実際の幅を取得して正方形サイズを計算
        let cellWidth = contentView.frame.width
        let imageViewWidth = cellWidth - (Constants.horizontalPadding * 2)
        
        // 正方形になるよう高さ制約を更新
        imageViewHeightConstraint?.constant = imageViewWidth
    }
    
    private func setupAccessibility() {
        // アクセシビリティ設定
        titleLabel.isAccessibilityElement = true
        inventoryImageView.isAccessibilityElement = true
        inventoryImageView.accessibilityLabel = "在庫画像"
        noImageLabel.isAccessibilityElement = true
        noImageLabel.accessibilityLabel = "画像なし"
        
        // セル全体のアクセシビリティ
        isAccessibilityElement = false
        accessibilityElements = [titleLabel]  // 画像は状況に応じて追加
    }
    
    // MARK: - Configuration
    func configure(leftText: String, rightImageURLString: String) {
        titleLabel.text = leftText
        titleLabel.accessibilityLabel = leftText
        
        // 画像URLが無効または空の場合
        if rightImageURLString.isEmpty || rightImageURLString == "imageURL" {
            showNoImageState()
        } else {
            // 画像読み込み処理
            loadImage(from: rightImageURLString)
        }
    }
    
    // MARK: - Private Methods
    private func showNoImageState() {
        inventoryImageView.isHidden = true
        noImageLabel.isHidden = false
        
        // アクセシビリティ要素を更新
        accessibilityElements = [titleLabel, noImageLabel]
    }
    
    private func showImageLoadedState() {
        inventoryImageView.isHidden = false
        noImageLabel.isHidden = true
        
        // アクセシビリティ要素を更新
        accessibilityElements = [titleLabel, inventoryImageView]
    }
    
    private func loadImage(from urlString: String) {
        // 前のタスクをキャンセル
        imageTask?.cancel()
        
        // 画像ビューを表示状態にして、画像をクリア
        inventoryImageView.isHidden = false
        noImageLabel.isHidden = true
        inventoryImageView.image = nil
        
        // 無効なURLの場合は"no image"状態にする
        guard let url = URL(string: urlString) else {
            showNoImageState()
            return
        }
        
        // 非同期で画像読み込み
        imageTask = Task { [weak self] in
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                
                // タスクがキャンセルされていないかチェック
                guard !Task.isCancelled else { return }
                
                // UIImageを作成
                guard let image = UIImage(data: data) else {
                    await self?.handleImageLoadFailure()
                    return
                }
                
                // メインスレッドでUI更新
                await MainActor.run { [weak self] in
                    self?.inventoryImageView.image = image
                    self?.showImageLoadedState()
                    self?.inventoryImageView.accessibilityLabel = "在庫画像: \(image.size.width)×\(image.size.height)"
                }
            } catch {
                // エラー時の処理
                await self?.handleImageLoadFailure()
            }
        }
    }
    
    @MainActor
    private func handleImageLoadFailure() {
        showNoImageState()
        inventoryImageView.accessibilityLabel = "在庫画像: 読み込み失敗"
    }
}
