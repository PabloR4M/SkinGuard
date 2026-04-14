import SwiftUI

// MARK: - TAB PARA USUARIOS (Sin porcentaje)
struct MainTabUsuario: View {
    var body: some View {
        TabView {
            HomeViewLite() // Tu vista sin el porcentaje
                .tabItem { Label("Análisis", systemImage: "viewfinder") }
            
            SeguimientoView() // El historial
                .tabItem { Label("Historial", systemImage: "clock.fill") }
            
            CartaMedicaAIView() // El código que me pasaste arriba
                .tabItem { Label("Mi Cartilla", systemImage: "menucard.fill") }
        }
        .tint(.blue)
    }
}

// MARK: - TAB PARA MÉDICOS (Con porcentaje)
struct MainTabMedico: View {
    var body: some View {
        TabView {
            HomeView() // Tu vista original con el porcentaje
                .tabItem { Label("Escáner", systemImage: "camera.badge.ellipsis") }
            
            SeguimientoPacientesView() // Vista Mock
                .tabItem { Label("Pacientes", systemImage: "person.2.fill") }
            
            InfoMedicoView() // Vista Mock
                .tabItem { Label("Perfil", systemImage: "stethoscope") }
        }
        .tint(.indigo) // Un color diferente para que el médico sepa que está en su perfil
    }
}

// MARK: - VISTAS MOCK PARA EL MÉDICO
struct SeguimientoPacientesView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView("Módulo en Desarrollo", systemImage: "person.3.sequence.fill", description: Text("Aquí el médico gestionará el historial vinculado a las cuentas de sus pacientes."))
                .navigationTitle("Mis Pacientes")
        }
    }
}

struct InfoMedicoView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Mi Licencia")) {
                    LabeledContent("Estado", value: "Activa (Premium)")
                    LabeledContent("Cédula", value: "12345678")
                }
                Section {
                    Button(role: .destructive, action: { appState.cerrarSesion() }) {
                        Text("Cerrar Sesión")
                    }
                }
            }
            .navigationTitle("Perfil Médico")
        }
    }
}
