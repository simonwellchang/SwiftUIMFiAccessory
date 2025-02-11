import SwiftUI
import ExternalAccessory

struct MFiAccessoryView: View {
    @ObservedObject var accessoryManager = MFiAccessoryManager()
    
    var body: some View {
        NavigationView {
            VStack {
                // 顯示錯誤信息或設備的狀態
                if !accessoryManager.errorMessage.isEmpty {
                    Text("錯誤: \(accessoryManager.errorMessage)")
                        .foregroundColor(.red)
                        .padding()
                }
                
                // 顯示配件連接狀態
                if accessoryManager.isConnected {
                    Text("已連接到配件: \(accessoryManager.currentAccessory?.name ?? "未知設備")")
                        .padding()
                } else {
                    Text("未連接任何配件")
                        .padding()
                }
                
                // 顯示接收到的數據
                if !accessoryManager.receivedData.isEmpty {
                    Text("收到數據: \(accessoryManager.receivedData)")
                        .padding()
                }
                
                // 開始掃描和連接
                Button(action: {
                    accessoryManager.scanForAccessories()
                }) {
                    Text("掃描並連接配件")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()
            }
            .navigationTitle("MFi 配件管理")
        }
    }
}

struct MFiAccessoryView_Previews: PreviewProvider {
    static var previews: some View {
        MFiAccessoryView()
    }
}


// 模擬配件信息
class MFiAccessoryManager: NSObject, ObservableObject, EAAccessoryDelegate {
    
    @Published var accessoryName: String = "Fake MFi Accessory"
    @Published var manufacturer: String = "Apple"
    @Published var modelNumber: String = "12345"
    @Published var serialNumber: String = "67890"
    @Published var isConnected = false
    @Published var receivedData: String = ""
    @Published var errorMessage: String = ""
    
    var session: EASession?
    var currentAccessory: EAAccessory?  // 用來保存當前連接的配件
    
    // 開始掃描配件
    func scanForAccessories() {
        // 檢查是否有可用的配件
        let accessories = EAAccessoryManager.shared().connectedAccessories
        if !accessories.isEmpty {
            // 假設我們只連接第一個配件
            self.currentAccessory = accessories.first
            self.isConnected = true
            startSession(with: self.currentAccessory!)
        } else {
            self.errorMessage = "沒有找到已連接的配件"
        }
    }
    
    // 開始會話並與配件進行通信
    func startSession(with accessory: EAAccessory) {
        let protocolName = "com.fake.mfi.protocol"
        
        // 創建會話
        session = EASession(accessory: accessory, forProtocol: protocolName)
        
        // 設置配件的名稱和其他屬性
        self.accessoryName = accessory.name
        self.manufacturer = accessory.manufacturer
        self.modelNumber = accessory.modelNumber
        self.serialNumber = accessory.serialNumber
        
        // 模擬數據交換
        simulateDataExchange()
    }
    
    // 模擬數據交換
    func simulateDataExchange() {
        // 模擬接收到的數據
        let fakeData = "這是來自假配件的數據"
        self.receivedData = fakeData
    }
    
    // 處理錯誤
    func session(_ session: EASession, didEncounterError error: Error) {
        self.errorMessage = error.localizedDescription
    }
}
