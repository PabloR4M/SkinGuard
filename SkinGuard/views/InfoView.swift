import SwiftUI

struct InfoView: View {
    var body: some View {
        NavigationView {
            Text("Aquí irá la información educativa sobre el cuidado de la piel.")
                .foregroundColor(.gray)
                .navigationTitle("Información")
        }
    }
}

#Preview {
    InfoView()
}
