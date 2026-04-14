import SwiftUI

struct MainTabView: View {
    
    @StateObject private var seguimientoVM = SeguimientoViewModel()
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Análisis", systemImage: "viewfinder")
                }
            
            SeguimientoView()
                .tabItem {
                    Label("Historial", systemImage: "clock.fill")
                }
            
            CartaMedicaAIView()
                .tabItem {
                    Label("Educación", systemImage: "info.circle.fill")
                }
        }
        .tint(.blue)
        .environmentObject(seguimientoVM) // 🌟 Inyecta el cerebro a toda la app
    }
}
