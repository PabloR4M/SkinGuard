import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Analizar", systemImage: "camera.viewfinder")
                }
            
            SeguimientoView()
                .tabItem {
                    Label("Seguimiento", systemImage: "waveform.path.ecg")
                }
            
            CartaMedicaAIView()
                .tabItem {
                    Label("Mi Carta", systemImage: "person.text.rectangle.fill")
                }
        }
        .tint(.blue)
    }
}

#Preview {
    MainTabView()
}
