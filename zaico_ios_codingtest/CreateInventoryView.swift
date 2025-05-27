//
//  CreateInventoryView.swift
//  zaico_ios_codingtest
//
//  Created by Ryuzo Hiruma on 2025/05/21.
//

import SwiftUI

// 在庫データ作成画面のSwiftUIビュー
struct CreateInventoryView: View {
    // ビューモデル
    @StateObject private var viewModel = CreateInventoryViewModel()
    
    // 画面を閉じるための状態
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                // 在庫データ入力セクション
                Section(header: Text("在庫データ情報")) {
                    // タイトル入力（必須）-
                    TextField("タイトル (必須)", text: $viewModel.title)
                        .keyboardType(.default)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    // 数量入力（オプション）- 数字キーパッド表示
                    TextField("数量（任意）", text: $viewModel.quantity)
                        .keyboardType(.numberPad)
                        .onChange(of: viewModel.quantity) { oldValue, newValue in
                            // 数字以外の文字を削除
                            let filtered = newValue.filter { "0123456789".contains($0) }
                            if filtered != newValue {
                                viewModel.quantity = filtered
                            }
                        }
                    
                    // 単位入力（オプション）
                    TextField("単位（任意）", text: $viewModel.unit)
                        .keyboardType(.default)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
                
                // 登録ボタン
                Section {
                    Button(action: {
                        // 非同期処理として在庫データ作成を実行
                        Task {
                            await viewModel.createInventory()
                        }
                    }) {
                        HStack {
                            Spacer()
                            // 読み込み中はインジケータを表示
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                            } else {
                                Text("在庫データを作成")
                                    .fontWeight(.bold)
                            }
                            Spacer()
                        }
                    }
                    .disabled(viewModel.title.isEmpty || viewModel.isLoading)
                }
                
                // 注意書きセクション
                Section(header: Text("注意事項")) {
                    Text("タイトルは必須項目です。数量は整数のみ入力可能です。数量と単位はオプションです。")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .navigationTitle("在庫データ作成")
            .navigationBarTitleDisplayMode(.inline)  // タイトルを中央寄せ
            .navigationBarItems(
                trailing: Button("閉じる") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
            // キーボード用ツールバー（数字キーパッドには「完了」ボタンがないため）
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("完了") {
                        // キーボードを閉じる（フォーカスを外す）
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                }
            }
            // アラート表示
            .alert(isPresented: $viewModel.showAlert) {
                // 成功時と失敗時でアラートの内容を変更
                if viewModel.isSuccess {
                    return Alert(
                        title: Text("成功"),
                        message: Text(viewModel.alertMessage),
                        dismissButton: .default(Text("OK")) {
                            // 作成成功時は画面を閉じる
                            presentationMode.wrappedValue.dismiss()
                        }
                    )
                } else {
                    return Alert(
                        title: Text("エラー"),
                        message: Text(viewModel.alertMessage),
                        dismissButton: .default(Text("OK"))
                    )
                }
            }
        }
    }
}

/// プレビュー表示用
struct CreateInventoryView_Previews: PreviewProvider {
    static var previews: some View {
        CreateInventoryView()
    }
}
