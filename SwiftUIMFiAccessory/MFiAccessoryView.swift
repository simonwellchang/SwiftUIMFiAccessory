import ExternalAccessory
import SwiftUI

// MARK: - View
struct MFiAccessoryView: View {
    @StateObject private var accessoryManager = MFiAccessoryManager()

    var body: some View {
        NavigationView {
            contentView
                .navigationTitle("MFi 配件管理")
        }
    }

    private var contentView: some View {
        VStack(spacing: 16) {
            errorMessageView
            connectionStatusView
            receivedDataView
            scanButton
        }
        .padding()
    }

    private var errorMessageView: some View {
        Group {
            if !accessoryManager.errorMessage.isEmpty {
                Text("錯誤: \(accessoryManager.errorMessage)")
                    .foregroundColor(.red)
            }
        }
    }

    private var connectionStatusView: some View {
        Text(
            accessoryManager.isConnected
                ? "已連接到配件: \(accessoryManager.currentAccessory?.name ?? "未知設備")" : "未連接任何配件")
    }

    private var receivedDataView: some View {
        Group {
            if !accessoryManager.receivedData.isEmpty {
                Text("收到數據: \(accessoryManager.receivedData)")
            }
        }
    }

    private var scanButton: some View {
        Button(action: accessoryManager.scanForAccessories) {
            Text("掃描並連接配件")
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
    }
}

// MARK: - Manager
final class MFiAccessoryManager: NSObject, ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var accessoryInfo = AccessoryInfo()
    @Published private(set) var isConnected = false
    @Published private(set) var receivedData: String = ""
    @Published private(set) var errorMessage: String = ""

    // MARK: - Private Properties
    private var session: EASession?
    private(set) var currentAccessory: EAAccessory?

    // MARK: - Public Methods
    func scanForAccessories() {
        let accessories = EAAccessoryManager.shared().connectedAccessories
        guard let firstAccessory = accessories.first else {
            handleError("沒有找到已連接的配件")
            return
        }

        connectToAccessory(firstAccessory)
    }

    // MARK: - Private Methods
    private func connectToAccessory(_ accessory: EAAccessory) {
        currentAccessory = accessory
        isConnected = true
        startSession(with: accessory)
    }

    private func startSession(with accessory: EAAccessory) {
        let protocolName = "com.fake.mfi.protocol"

        session = EASession(accessory: accessory, forProtocol: protocolName)
        updateAccessoryInfo(from: accessory)
        simulateDataExchange()
    }

    private func updateAccessoryInfo(from accessory: EAAccessory) {
        accessoryInfo = AccessoryInfo(
            name: accessory.name,
            manufacturer: accessory.manufacturer,
            modelNumber: accessory.modelNumber,
            serialNumber: accessory.serialNumber
        )
    }

    private func simulateDataExchange() {
        receivedData = "這是來自假配件的數據"
    }

    private func handleError(_ message: String) {
        errorMessage = message
        isConnected = false
    }
}

// MARK: - EAAccessoryDelegate
extension MFiAccessoryManager: EAAccessoryDelegate {
    func accessoryDidDisconnect(_ accessory: EAAccessory) {
        DispatchQueue.main.async { [weak self] in
            self?.handleError("配件已斷開連接")
        }
    }
}

// MARK: - Models
struct AccessoryInfo {
    var name: String = "Fake MFi Accessory"
    var manufacturer: String = "Apple"
    var modelNumber: String = "12345"
    var serialNumber: String = "67890"
}
