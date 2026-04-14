import SwiftUI
import Combine

// MARK: - MODELO DE DATOS PERSISTENTE
struct DatosPaciente: Codable {
    var edad: String = ""
    var tipoPiel: String = "Intermedio"
    var ubicacion: String = "Brazo"
    var evolucion: String = "Semanas"
    var cambios: Set<String> = []
    var exposicionSol: String = "Media"
    var antecedentePersonal: Bool = false
    var antecedenteFamiliar: Bool = false
    
    // Guardado local
    func guardar() {
        if let encoded = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(encoded, forKey: "DatosSkinGuard")
        }
    }
    
    static func cargar() -> DatosPaciente {
        if let data = UserDefaults.standard.data(forKey: "DatosSkinGuard"),
           let decoded = try? JSONDecoder().decode(DatosPaciente.self, from: data) {
            return decoded
        }
        return DatosPaciente()
    }
}

// MARK: - VIEW MODEL PARA EL FLUJO
class FlujoCartaViewModel: ObservableObject {
    @Published var datos = DatosPaciente.cargar()
    @Published var pasoActual: Int = 0
    @Published var mostrarFormulario: Bool = false
    
    let totalPasos = 6
    
    func finalizarYGuardar() {
        datos.guardar()
        mostrarFormulario = false
        pasoActual = 0
    }
}

// MARK: - VISTA PRINCIPAL
struct CartaMedicaAIView: View {
    @StateObject private var viewModel = FlujoCartaViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // LA CARTA MÉDICA (VISUALIZACIÓN)
                        VistaDocumentoMedico(datos: viewModel.datos)
                        
                        Button(action: { viewModel.mostrarFormulario = true }) {
                            Label("Editar Ficha Médica", systemImage: "doc.text.badge.plus")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(14)
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Carta Médica")
            .fullScreenCover(isPresented: $viewModel.mostrarFormulario) {
                ContenedorFormulario(viewModel: viewModel)
            }
        }
    }
}

// MARK: - CONTENEDOR DEL FLUJO POR PANTALLAS
struct ContenedorFormulario: View {
    @ObservedObject var viewModel: FlujoCartaViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            VStack {
                // Indicador de Progreso
                ProgressView(value: Double(viewModel.pasoActual + 1), total: Double(viewModel.totalPasos))
                    .padding()

                // Pantallas dinámicas
                ZStack {
                    switch viewModel.pasoActual {
                    case 0: PasoGenerico(titulo: "¿Cuál es tu edad?", contenido: AnyView(TextField("Ej: 21", text: $viewModel.datos.edad).keyboardType(.numberPad).font(.system(size: 40, weight: .bold)).multilineTextAlignment(.center)))
                    case 1: PasoSelector(titulo: "Tipo de piel", seleccion: $viewModel.datos.tipoPiel, opciones: ["Me quemo fácil", "Intermedio", "Me bronceo fácil"])
                    case 2: PasoSelector(titulo: "Ubicación", seleccion: $viewModel.datos.ubicacion, opciones: ["Cara", "Brazo", "Espalda", "Pierna", "Otro"])
                    case 3: PasoSelector(titulo: "Evolución", seleccion: $viewModel.datos.evolucion, opciones: ["Días", "Semanas", "Meses", "Años"])
                    case 4: PasoChecks(titulo: "Cambios recientes", seleccion: $viewModel.datos.cambios)
                    case 5: PasoHistorial(personal: $viewModel.datos.antecedentePersonal, familiar: $viewModel.datos.antecedenteFamiliar)
                    default: EmptyView()
                    }
                }
                .animation(.spring(), value: viewModel.pasoActual)
                
                Spacer()
                
                // Botonera
                HStack {
                    if viewModel.pasoActual > 0 {
                        Button("Atrás") { viewModel.pasoActual -= 1 }
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                    }
                    
                    Button(action: {
                        if viewModel.pasoActual < viewModel.totalPasos - 1 {
                            viewModel.pasoActual += 1
                        } else {
                            viewModel.finalizarYGuardar()
                        }
                    }) {
                        Text(viewModel.pasoActual == viewModel.totalPasos - 1 ? "Finalizar" : "Siguiente")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                }
                .padding()
            }
            .navigationTitle("Ficha Médica")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cerrar") { dismiss() }
                }
            }
        }
    }
}

// MARK: - DISEÑO DE LA CARTA (OUTPUT)
struct VistaDocumentoMedico: View {
    let datos: DatosPaciente
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                VStack(alignment: .leading) {
                    Text("SKINGUARD")
                        .font(.system(.title3, design: .serif)).bold()
                        .foregroundColor(.blue)
                    Text("INFORME DE PACIENTE (OFFLINE)")
                        .font(.caption2).tracking(1).foregroundColor(.secondary)
                }
                Spacer()
                Text(Date().formatted(date: .abbreviated, time: .omitted))
                    .font(.caption2).foregroundColor(.secondary)
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 12) {
                FilaMedica(label: "EDAD", valor: datos.edad.isEmpty ? "--" : "\(datos.edad) AÑOS")
                FilaMedica(label: "FOTOTIPO", valor: datos.tipoPiel.uppercased())
                FilaMedica(label: "UBICACIÓN", valor: datos.ubicacion.uppercased())
                FilaMedica(label: "EVOLUCIÓN", valor: datos.evolucion.uppercased())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("CAMBIOS NOTADOS:").font(.system(size: 9, weight: .bold)).foregroundColor(.blue)
                    Text(datos.cambios.isEmpty ? "NINGUNO" : datos.cambios.joined(separator: ", ").uppercased())
                        .font(.system(.caption, design: .monospaced))
                }
                
                HStack {
                    FilaMedica(label: "ANT. PERSONAL", valor: datos.antecedentePersonal ? "SÍ" : "NO")
                    Spacer()
                    FilaMedica(label: "ANT. FAMILIAR", valor: datos.antecedenteFamiliar ? "SÍ" : "NO")
                }
            }
            
            Spacer(minLength: 20)
            
            Text("Este documento es una recopilación de datos ingresados por el usuario para su uso personal.")
                .font(.system(size: 7))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
        }
        .padding(25)
        .background(Color.white)
        .cornerRadius(2)
        .shadow(color: .black.opacity(0.1), radius: 10)
        .padding(.horizontal)
    }
}

// MARK: - COMPONENTES REUTILIZABLES DEL FORMULARIO
struct PasoGenerico: View {
    let titulo: String
    let contenido: AnyView
    var body: some View {
        VStack(spacing: 20) {
            Text(titulo).font(.title2).bold()
            contenido
        }.padding()
    }
}

struct PasoSelector: View {
    let titulo: String
    @Binding var seleccion: String
    let opciones: [String]
    var body: some View {
        VStack {
            Text(titulo).font(.title2).bold().padding()
            List(opciones, id: \.self) { opcion in
                HStack {
                    Text(opcion)
                    Spacer()
                    if seleccion == opcion { Image(systemName: "checkmark").foregroundColor(.blue) }
                }
                .contentShape(Rectangle())
                .onTapGesture { seleccion = opcion }
            }.listStyle(.insetGrouped)
        }
    }
}

struct PasoChecks: View {
    let titulo: String
    @Binding var seleccion: Set<String>
    let opciones = ["Creció", "Cambió de color", "Sangra", "Duele o pica", "No ha cambiado"]
    var body: some View {
        VStack {
            Text(titulo).font(.title2).bold().padding()
            List(opciones, id: \.self) { opcion in
                Toggle(opcion, isOn: Binding(
                    get: { seleccion.contains(opcion) },
                    set: { val in
                        if val { seleccion.insert(opcion) } else { seleccion.remove(opcion) }
                    }
                ))
            }.listStyle(.insetGrouped)
        }
    }
}

struct PasoHistorial: View {
    @Binding var personal: Bool
    @Binding var familiar: Bool
    var body: some View {
        VStack {
            Text("Antecedentes").font(.title2).bold().padding()
            List {
                Toggle("Personal de Cáncer", isOn: $personal)
                Toggle("Familiar de Cáncer", isOn: $familiar)
            }.listStyle(.insetGrouped)
        }
    }
}

struct FilaMedica: View {
    let label: String
    let valor: String
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label).font(.system(size: 9, weight: .bold)).foregroundColor(.blue)
            Text(valor).font(.system(.body, design: .monospaced))
        }
    }
}

#Preview {
    CartaMedicaAIView()
}
