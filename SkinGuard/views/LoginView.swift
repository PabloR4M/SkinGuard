//
//  LoginView.swift
//  SkinGuard
//
//  Created by MaciOSLabAir29 on 14/04/26.
//


import SwiftUI

struct LoginView: View {
    @EnvironmentObject var appState: AppState
    @State private var mostrarRegistroMedico = false
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "shield.checkerboard")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            VStack(spacing: 10) {
                Text("SkinGuard")
                    .font(.largeTitle)
                    .bold()
                Text("Tu piel, bajo cuidado inteligente.")
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(spacing: 15) {
                // INGRESO USUARIO GENERAL
                Button(action: {
                    appState.isDoctor = false
                    appState.isLoggedIn = true
                }) {
                    Text("Ingresar como Usuario")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                }
                
                // INGRESO MÉDICO
                Button(action: {
                    mostrarRegistroMedico = true
                }) {
                    Text("Soy Médico (Licencia)")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(15)
                }
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 50)
        }
        .sheet(isPresented: $mostrarRegistroMedico) {
            NavigationView {
                Form {
                    Section(header: Text("Datos de Licencia"), footer: Text("Al continuar, aceptas los términos de la licencia médica.")) {
                        TextField("Número de Cédula Profesional", text: .constant(""))
                        TextField("Hospital / Clínica", text: .constant(""))
                    }
                }
                .navigationTitle("Registro Médico")
                .navigationBarItems(
                    leading: Button("Cancelar") { mostrarRegistroMedico = false },
                    trailing: Button("Comprar Licencia") {
                        mostrarRegistroMedico = false
                        appState.isDoctor = true
                        appState.isLoggedIn = true
                    }.bold()
                )
            }
        }
    }
}