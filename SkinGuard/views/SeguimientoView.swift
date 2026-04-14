import SwiftUI

struct SeguimientoView: View {
    var body: some View {
        NavigationView {
            Text("Aquí irá el historial o registro de lesiones.")
                .foregroundColor(.gray)
                .navigationTitle("Registro")
        }
    }
}

#Preview {
    SeguimientoView()
}
