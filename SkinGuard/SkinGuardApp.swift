import SwiftUI

@main
struct SkinGuardApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var seguimientoVM = SeguimientoViewModel()
    
    var body: some Scene {
        WindowGroup {
            // CONTROLADOR DE TRÁFICO
            if !appState.isLoggedIn {
                WelcomeView()
                    .environmentObject(appState)
            } else if appState.isDoctor {
                MainTabMedico()
                    .environmentObject(appState)
                    .environmentObject(seguimientoVM)
            } else {
                MainTabUsuario()
                    .environmentObject(appState)
                    .environmentObject(seguimientoVM)
            }
        }
    }
}
