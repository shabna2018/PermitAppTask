//
//  BluetoothManager.swift
//  PermitManager
//
//  Created by macbook on 01/08/25.
//
import SwiftUI
import Combine
import Foundation

class BluetoothManager: ObservableObject {
    @Published var isConnected = false
    @Published var deviceName = "Gate Device BT-001"
    @Published var connectionStatus = "Disconnected"
    
    func connectToDevice() {
        connectionStatus = "Connecting..."
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.isConnected = true
            self.connectionStatus = "Connected"
        }
    }
    
    func disconnectDevice() {
        isConnected = false
        connectionStatus = "Disconnected"
    }
    
    func sendPermitToGate(_ permit: Permit) -> Bool {
        guard isConnected else { return false }
        // Simulate sending permit data to gate device
        print("Sending permit \(permit.permitNumber) to gate device")
        return true
    }
}
