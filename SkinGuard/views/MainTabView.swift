import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Inicio", systemImage: "house.fill")
                }
            
            RegisterView()
                .tabItem {
                    Label("Registro", systemImage: "clipboard.fill")
                }
            
            InfoView()
                .tabItem {
                    Label("Info", systemImage: "info.circle.fill")
            }
        }
        .tint(.blue)
    }
}

#Preview {
    MainTabView()
}
