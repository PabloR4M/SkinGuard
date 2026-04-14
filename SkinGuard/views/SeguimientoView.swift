import SwiftUI

struct SeguimientoView: View {
    // Escucha los cambios globales del historial
    @EnvironmentObject var viewModel: SeguimientoViewModel
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemGroupedBackground).ignoresSafeArea()
                
                if viewModel.registros.isEmpty {
                    VStack(spacing: 15) {
                        Image(systemName: "waveform.path.ecg")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("Sin Análisis")
                            .font(.title2).bold()
                        Text("Tus análisis guardados aparecerán aquí para que lleves un control de tu piel.")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                    }
                } else {
                    List {
                        Section(header: Text("Historial de Análisis"), footer: Text("SkinGuard guarda tus registros localmente para tu privacidad.")) {
                            ForEach(viewModel.registros) { registro in
                                NavigationLink(destination: DetalleRegistroView(registro: registro)) {
                                    TarjetaSeguimiento(registro: registro)
                                }
                            }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                }
            }
            .navigationTitle("Seguimiento")
        }
    }
}

// Tarjeta Individual
struct TarjetaSeguimiento: View {
    let registro: AnalisisRegistro
    @EnvironmentObject var viewModel: SeguimientoViewModel
    
    var body: some View {
        HStack(spacing: 15) {
            // Carga la imagen desde la memoria del teléfono
            if let uiImage = viewModel.cargarImagenLocal(nombre: registro.nombreImagen) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            } else {
                RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.3)).frame(width: 60, height: 60)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(registro.ubicacion).font(.headline)
                HStack {
                    Image(systemName: "calendar").font(.caption2)
                    Text(registro.fechaFormateada).font(.caption)
                }.foregroundColor(.secondary)
            }
            Spacer()
            // Indicador visual del resultado
            Circle()
                .fill(registro.resultado == "Irregulares" ? Color.orange : Color.green)
                .frame(width: 12, height: 12)
        }
        .padding(.vertical, 4)
    }
}

// Detalle del registro
struct DetalleRegistroView: View {
    let registro: AnalisisRegistro
    @EnvironmentObject var viewModel: SeguimientoViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        List {
            Section {
                if let uiImage = viewModel.cargarImagenLocal(nombre: registro.nombreImagen) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(12)
                        .padding(.vertical, 10)
                }
            }
            Section(header: Text("Resultado del Análisis")) {
                HStack {
                    Image(systemName: registro.resultado == "Irregulares" ? "exclamationmark.triangle.fill" : "checkmark.shield.fill")
                        .foregroundColor(registro.resultado == "Irregulares" ? .orange : .green)
                    Text(registro.resultado == "Irregulares" ? "Revisión Sugerida" : "Análisis Favorable")
                        .bold()
                }
            }
            Section(header: Text("Detalles")) {
                LabeledContent("Ubicación", value: registro.ubicacion)
                LabeledContent("Fecha", value: registro.fechaFormateada)
            }
            if !registro.notas.isEmpty {
                Section(header: Text("Notas del Paciente")) {
                    Text(registro.notas)
                }
            }
            Section {
                Button(role: .destructive, action: {
                    viewModel.eliminarRegistro(registro)
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Label("Eliminar del historial", systemImage: "trash")
                }
            }
        }
        .navigationTitle("Detalle")
        .navigationBarTitleDisplayMode(.inline)
    }
}
