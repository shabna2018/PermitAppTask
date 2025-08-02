
import SwiftUI
import Combine
import Foundation

struct ContentView: View {
    @StateObject private var authViewModel = AuthenticationViewModel()
    @StateObject private var permitViewModel = PermitViewModel()
    @StateObject private var bluetoothViewModel = BluetoothViewModel()
    
    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                MainTabView()
                    .environmentObject(authViewModel)
                    .environmentObject(permitViewModel)
                    .environmentObject(bluetoothViewModel)
            } else {
                LoginView()
                    .environmentObject(authViewModel)
            }
        }
    }
}
