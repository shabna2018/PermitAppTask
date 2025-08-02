
import SwiftUI
import Combine
import Foundation

struct ContentView: View {
    @StateObject private var authManager = AuthenticationManager()
    @StateObject private var permitManager = PermitManager()
    @StateObject private var bluetoothManager = BluetoothManager()
    
    var body: some View {
        Group {
            if authManager.isAuthenticated {
                MainTabView()
                    .environmentObject(authManager)
                    .environmentObject(permitManager)
                    .environmentObject(bluetoothManager)
            } else {
                LoginView()
                    .environmentObject(authManager)
            }
        }
    }
}
