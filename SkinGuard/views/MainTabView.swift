import SwiftUI

struct MainTabView: View {
    
    @StateObject private var seguimientoVM = SeguimientoViewModel()
    
    var body: some View {
        // El TabView es el contenedor principal
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
            
            
        } // <--- Aquí cerramos el TabView
        .tint(.blue) // Ahora este modificador afecta al TabView
        .environmentObject(seguimientoVM) // Y este inyecta el VM a todas sus pestañas
    } // <--- Aquí cerramos el body
}
