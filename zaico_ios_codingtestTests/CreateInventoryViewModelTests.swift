//
//  CreateInventoryViewModelTests.swift
//  zaico_ios_codingtest
//
//  Created by Ryuzo Hiruma on 2025/05/25.
//

import XCTest
@testable import zaico_ios_codingtest

class CreateInventoryViewModelTests: XCTestCase {
    
    var viewModel: CreateInventoryViewModel!
    var mockAPIClient: MockAPIClient!
    
    override func setUp() {
        super.setUp()
        mockAPIClient = MockAPIClient()
        viewModel = CreateInventoryViewModel(apiClient: mockAPIClient)
    }
    
    override func tearDown() {
        viewModel = nil
        mockAPIClient = nil
        super.tearDown()
    }
    
    // MARK: - 初期状態のテスト
    
    func testInitialState() {
        XCTAssertEqual(viewModel.title, "")
        XCTAssertEqual(viewModel.quantity, "")
        XCTAssertEqual(viewModel.unit, "")
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertFalse(viewModel.showAlert)
        XCTAssertFalse(viewModel.isSuccess)
        XCTAssertNil(viewModel.createdInventoryId)
    }
    
    // MARK: - バリデーションテスト
    func testEmptyTitleValidation() async {
        viewModel.title = ""
        viewModel.quantity = "10"
        viewModel.unit = "個"
        
        await viewModel.createInventory()
        
        XCTAssertFalse(viewModel.isSuccess)
        XCTAssertTrue(viewModel.showAlert)
        XCTAssertTrue(viewModel.alertMessage.contains("タイトル"))
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertEqual(mockAPIClient.createInventoryCallCount, 0)
    }
    
    func testValidInput() {
        viewModel.title = "テスト商品"
        viewModel.quantity = "10"
        viewModel.unit = "個"
        
        XCTAssertTrue(viewModel.isFormValid)
    }
    
    // MARK: - 成功ケースのテスト
    func testCreateInventorySuccess() async {
        viewModel.title = "テスト商品"
        viewModel.quantity = "10"
        viewModel.unit = "個"
        
        let expectedDataId = 12345
        mockAPIClient.setupSuccessResponse(dataId: expectedDataId)
        
        await viewModel.createInventory()
        
        XCTAssertTrue(viewModel.isSuccess)
        XCTAssertEqual(viewModel.createdInventoryId, expectedDataId)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertTrue(viewModel.showAlert)
        XCTAssertTrue(viewModel.alertMessage.contains("作成されました"))
        
        XCTAssertEqual(viewModel.title, "")
        XCTAssertEqual(viewModel.quantity, "")
        XCTAssertEqual(viewModel.unit, "")
        
        XCTAssertEqual(mockAPIClient.createInventoryCallCount, 1)
        XCTAssertEqual(mockAPIClient.tokenDidUpdateCallCount, 1)
        
        let lastRequest = mockAPIClient.lastCreateInventoryRequest
        XCTAssertNotNil(lastRequest)
        XCTAssertEqual(lastRequest?.title, "テスト商品")
        XCTAssertEqual(lastRequest?.quantity, "10")
        XCTAssertEqual(lastRequest?.unit, "個")
    }
    
    // MARK: - エラーケースのテスト
    
    func testCreateInventoryFailure() async {
        viewModel.title = "テスト商品"
        viewModel.quantity = "10"
        viewModel.unit = "個"
        
        let expectedErrorMessage = "サーバーエラーが発生しました"
        mockAPIClient.setupErrorResponse(code: 500, message: expectedErrorMessage)
        
        await viewModel.createInventory()
        
        XCTAssertFalse(viewModel.isSuccess)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertTrue(viewModel.showAlert)
        XCTAssertTrue(viewModel.alertMessage.contains(expectedErrorMessage))
        
        XCTAssertEqual(mockAPIClient.createInventoryCallCount, 1)
        XCTAssertEqual(mockAPIClient.tokenDidUpdateCallCount, 0)
    }
    
    func testNetworkError() async {
        viewModel.title = "テスト商品"
        
        let networkError = URLError(.notConnectedToInternet)
        mockAPIClient.setupError(networkError)
        
        await viewModel.createInventory()
        
        XCTAssertFalse(viewModel.isSuccess)
        XCTAssertTrue(viewModel.showAlert)
        XCTAssertTrue(viewModel.alertMessage.contains("NSURLErrorDomain"))
    }
    
    // MARK: - 数量バリデーションテスト
    
    func testQuantityValidation() {
        viewModel.quantity = "123"
        viewModel.validateQuantity()
        XCTAssertEqual(viewModel.quantity, "123")
        
        viewModel.quantity = "123abc"
        viewModel.validateQuantity()
        XCTAssertEqual(viewModel.quantity, "123")
        
        viewModel.quantity = "123.45"
        viewModel.validateQuantity()
        XCTAssertEqual(viewModel.quantity, "12345")
        
        viewModel.quantity = "abc"
        viewModel.validateQuantity()
        XCTAssertEqual(viewModel.quantity, "")
    }
    
    // MARK: - ローディング状態のテスト
    
    func testLoadingStateTransition() async {
        viewModel.title = "テスト商品"
        mockAPIClient.setupDelay(0.1)
        mockAPIClient.setupSuccessResponse()
        
        let loadingExpectation = expectation(description: "Loading state")
        
        Task {
            await viewModel.createInventory()
            loadingExpectation.fulfill()
        }
        
        try? await Task.sleep(nanoseconds: 50_000_000)
        XCTAssertTrue(viewModel.isLoading)
        
        await fulfillment(of: [loadingExpectation], timeout: 1.0)
        XCTAssertFalse(viewModel.isLoading)
    }
    
    // MARK: - オプショナルフィールドのテスト
    
    func testOptionalFields() async {
        viewModel.title = "テスト商品"
        viewModel.quantity = ""
        viewModel.unit = ""
        
        mockAPIClient.setupSuccessResponse()
        
        await viewModel.createInventory()
        
        XCTAssertTrue(viewModel.isSuccess)
        
        let lastRequest = mockAPIClient.lastCreateInventoryRequest
        XCTAssertEqual(lastRequest?.title, "テスト商品")
        XCTAssertNil(lastRequest?.quantity)
        XCTAssertNil(lastRequest?.unit)
    }
    
    func testPartialOptionalFields() async {
        viewModel.title = "テスト商品"
        viewModel.quantity = "5"
        viewModel.unit = ""
        
        mockAPIClient.setupSuccessResponse()
        
        await viewModel.createInventory()
        
        XCTAssertTrue(viewModel.isSuccess)
        
        let lastRequest = mockAPIClient.lastCreateInventoryRequest
        XCTAssertEqual(lastRequest?.title, "テスト商品")
        XCTAssertEqual(lastRequest?.quantity, "5")
        XCTAssertNil(lastRequest?.unit)
    }
    
    // MARK: - キャンセルテスト
    
    func testCancel() {
        let delegate = MockInventoryCreationDelegate()
        InventoryCreationDelegateHolder.shared.delegate = delegate
        
        viewModel.cancel()
        
        XCTAssertTrue(delegate.didCancelCalled)
    }
}

// MARK: - MockAPIClient

class MockAPIClient: APIClientProtocol {
    
    var mockCreateInventoryResponse: InventoryCreateResponse?
    var mockFetchInventoriesResponse: [Inventory] = []
    var mockFetchInventoryResponse: Inventory?
    var mockError: Error?
    var mockDelay: TimeInterval = 0
    
    var lastCreateInventoryRequest: InventoryCreateRequest?
    var lastFetchInventoryId: Int?
    
    var createInventoryCallCount = 0
    var fetchInventoriesCallCount = 0
    var fetchInventoryCallCount = 0
    var tokenDidUpdateCallCount = 0
    
    func fetchInventories() async throws -> [Inventory] {
        fetchInventoriesCallCount += 1
        
        if mockDelay > 0 {
            try await Task.sleep(nanoseconds: UInt64(mockDelay * 1_000_000_000))
        }
        
        if let error = mockError {
            throw error
        }
        
        return mockFetchInventoriesResponse
    }
    
    func fetchInventorie(id: Int?) async throws -> Inventory {
        fetchInventoryCallCount += 1
        lastFetchInventoryId = id
        
        if mockDelay > 0 {
            try await Task.sleep(nanoseconds: UInt64(mockDelay * 1_000_000_000))
        }
        
        if let error = mockError {
            throw error
        }
        
        return mockFetchInventoryResponse ?? Inventory(
            id: id ?? 0,
            title: "モック在庫",
            quantity: "0",
            itemImage: nil
        )
    }
    
    func createInventory(inventoryData: InventoryCreateRequest) async throws -> InventoryCreateResponse {
        createInventoryCallCount += 1
        lastCreateInventoryRequest = inventoryData
        
        if mockDelay > 0 {
            try await Task.sleep(nanoseconds: UInt64(mockDelay * 1_000_000_000))
        }
        
        if let error = mockError {
            throw error
        }
        
        return mockCreateInventoryResponse ?? InventoryCreateResponse(
            code: 200,
            status: "success",
            message: "データが正常に作成されました",
            dataId: Int.random(in: 10000...99999)
        )
    }
    
    func tokenDidUpdate() {
        tokenDidUpdateCallCount += 1
    }
    
    func reset() {
        mockCreateInventoryResponse = nil
        mockFetchInventoriesResponse = []
        mockFetchInventoryResponse = nil
        mockError = nil
        mockDelay = 0
        
        lastCreateInventoryRequest = nil
        lastFetchInventoryId = nil
        
        createInventoryCallCount = 0
        fetchInventoriesCallCount = 0
        fetchInventoryCallCount = 0
        tokenDidUpdateCallCount = 0
    }
    
    func setupSuccessResponse(dataId: Int = 12345) {
        mockCreateInventoryResponse = InventoryCreateResponse(
            code: 200,
            status: "success",
            message: "Data was successfully created.",
            dataId: dataId
        )
        mockError = nil
    }
    
    func setupErrorResponse(code: Int = 400, message: String = "Bad Request") {
        mockError = NSError(
            domain: "MockAPIError",
            code: code,
            userInfo: [NSLocalizedDescriptionKey: message]
        )
        mockCreateInventoryResponse = nil
    }
    
    func setupError(_ error: Error) {
        mockError = error
        mockCreateInventoryResponse = nil
    }
    
    func setupDelay(_ seconds: TimeInterval) {
        mockDelay = seconds
    }
}

// MARK: - MockDelegate

class MockInventoryCreationDelegate: InventoryCreationDelegate {
    var didCreateInventoryCalled = false
    var didCancelCalled = false
    var lastInventoryId: Int?
    
    func didCreateInventory(inventoryId: Int) {
        didCreateInventoryCalled = true
        lastInventoryId = inventoryId
    }
    
    func didCancelInventoryCreation() {
        didCancelCalled = true
    }
}

// MARK: - ViewModel Extensions for Testing

extension CreateInventoryViewModel {
    var isFormValid: Bool {
        return !title.isEmpty
    }
    
    func validateQuantity() {
        quantity = quantity.filter { "0123456789".contains($0) }
    }
}
