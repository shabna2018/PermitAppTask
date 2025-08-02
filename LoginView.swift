//
//  LoginView.swift
//  PermitManager
//
//  Created by macbook on 01/08/25.
//

import SwiftUI
import Combine
import Foundation

struct LoginView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var username = ""
    @State private var password = ""
    @State private var isLoading = false

    var body: some View {
        ZStack {
           
            LinearGradient(
                colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)

            VStack(spacing: 30) {
                VStack(spacing: 10) {
                    Image(systemName: "shield.lefthalf.filled")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .foregroundColor(.white)

                    Text("Site Inspector")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)

                    Text("Permit Management System")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }

                VStack(spacing: 18) {
                    customInputField(icon: "person.fill", placeholder: "Username", text: $username, isSecure: false)
                    customInputField(icon: "lock.fill", placeholder: "Password", text: $password, isSecure: true)
                }

                Button(action: login) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)
                            .shadow(radius: 5)

                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: Color.blue))
                                .padding()
                        } else {
                            Text("Login")
                                .foregroundColor(.blue)
                                .font(.headline)
                                .padding()
                        }
                    }
                    .frame(height: 50)
                }
                .padding(.top)

                // Demo credentials
                VStack(spacing: 4) {
                    Text("Demo Credentials:")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))

                    Text("Username: steeladmin")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.7))

                    Text("Password: 123456")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.7))
                }

                Spacer()
            }
            .padding()
            .alert(isPresented: .constant(authManager.loginErrorMessage != nil)) {
                Alert(
                    title: Text("Login Failed"),
                    message: Text(authManager.loginErrorMessage ?? "Unknown error"),
                    dismissButton: .default(Text("OK"), action: {
                        authManager.loginErrorMessage = nil
                    })
                )
            }
        }
        .navigationBarHidden(true)
    }

    private func login() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            authManager.login(username: username, password: password)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                isLoading = false
            }
        }
    }

    // MARK: - Custom Input Field
    @ViewBuilder
    private func customInputField(icon: String, placeholder: String, text: Binding<String>, isSecure: Bool) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.white)
                .frame(width: 24)

            if isSecure {
                SecureField(placeholder, text: text)
                    .foregroundColor(.white)
                    .textInputAutocapitalization(.never)
            } else {
                TextField(placeholder, text: text)
                    .foregroundColor(.white)
                    .textInputAutocapitalization(.never)
            }
        }
        .padding()
        .background(Color.white.opacity(0.2))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
        )
    }
}
