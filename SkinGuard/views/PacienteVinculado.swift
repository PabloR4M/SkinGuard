import SwiftUI

// MARK: - 1. Modelo de Datos
struct PacienteVinculado: Identifiable {
    let id: String
    let nombre: String
    let edad: Int
    let riesgo: String
    var notas: String
}

// MARK: - 2. Vista Principal del Médico
struct SeguimientoPacientesView: View {
    @State private var listaPacientes: [PacienteVinculado] = [
        PacienteVinculado(id: "SG-221B", nombre: "Jair Sánchez", edad: 21, riesgo: "Moderado", notas: "Observación en zona dorsal."),
        PacienteVinculado(id: "SG-884X", nombre: "Elena Peña", edad: 29, riesgo: "Bajo", notas: "Sin cambios recientes.")
    ]
    
    @State private var mostrandoVinculador = false
    @State private var idABuscar = ""

    var body: some View {
        NavigationStack {
            // ZStack nos permite poner el botón flotando ENCIMA de la lista
            ZStack {
                // 1. LA LISTA DE PACIENTES (Fondo)
                List {
                    Section {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("\(listaPacientes.count)")
                                    .font(.title).bold()
                                Text("Pacientes Activos")
                                    .font(.caption).foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemName: "person.2.badge.gearshape.fill")
                                .font(.largeTitle)
                                .foregroundColor(.indigo.opacity(0.3))
                        }
                        .padding(.vertical, 8)
                    }

                    Section(header: Text("Seguimiento Activo 📋")) {
                        if listaPacientes.isEmpty {
                            Text("No tienes pacientes vinculados.")
                                .foregroundColor(.secondary)
                                .font(.subheadline)
                        } else {
                            ForEach(listaPacientes) { paciente in
                                NavigationLink(destination: DetallePacienteView(paciente: paciente)) {
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(paciente.nombre).font(.headline)
                                            Text("ID: \(paciente.id)").font(.caption).foregroundColor(.secondary)
                                        }
                                        Spacer()
                                        Text(paciente.riesgo)
                                            .font(.caption2).bold()
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(paciente.riesgo == "Moderado" ? Color.orange.opacity(0.2) : Color.green.opacity(0.2))
                                            .foregroundColor(paciente.riesgo == "Moderado" ? .orange : .green)
                                            .cornerRadius(8)
                                    }
                                }
                            }
                        }
                    }
                }
                .navigationTitle("Mis Pacientes")
                
                // 2. EL BOTÓN FLOTANTE (Al frente)
                VStack {
                    Spacer() // Empuja todo hacia abajo
                    HStack {
                        Spacer() // Empuja el botón hacia la derecha
                        
                        Button(action: { mostrandoVinculador = true }) {
                            Image(systemName: "plus")
                                .font(.title.weight(.semibold))
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(Color.indigo)
                                .clipShape(Circle())
                                .shadow(color: Color.indigo.opacity(0.4), radius: 10, x: 0, y: 5)
                        }
                        .padding(.trailing, 20) // Separación del borde derecho
                        .padding(.bottom, 10) // Separación del TabBar (Nabab)
                    }
                }
            }
            .sheet(isPresented: $mostrandoVinculador) {
                VincularIDView(idABuscar: $idABuscar) {
                    vincularNuevoPaciente()
                }
            }
        }
    }

    func vincularNuevoPaciente() {
        if !idABuscar.isEmpty {
            let nuevo = PacienteVinculado(id: idABuscar, nombre: "Paciente Nuevo", edad: 0, riesgo: "Pendiente", notas: "")
            listaPacientes.append(nuevo)
            idABuscar = ""
            mostrandoVinculador = false
        }
    }
}

// MARK: - 3. Vista de Detalle
struct DetallePacienteView: View {
    let paciente: PacienteVinculado
    @State private var notasEditables = ""

    var body: some View {
        Form {
            Section(header: Text("Información General")) {
                LabeledContent("Nombre", value: paciente.nombre)
                LabeledContent("Edad", value: "\(paciente.edad) años")
                LabeledContent("ID Único", value: paciente.id)
            }
            
            Section(header: Text("Evolución y Notas 📝")) {
                TextEditor(text: $notasEditables)
                    .frame(minHeight: 150)
            }
            
            Section {
                Button("Guardar cambios en expediente") {
                    // Lógica de guardado visual (Mock)
                }
                .frame(maxWidth: .infinity)
                .foregroundColor(.indigo)
            }
        }
        .navigationTitle("Expediente")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { notasEditables = paciente.notas }
    }
}

// MARK: - 4. Vista de Vinculación (Modal)
struct VincularIDView: View {
    @Binding var idABuscar: String
    var accionVincular: () -> Void
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Ingrese el ID proporcionado por el paciente"), footer: Text("El ID se encuentra en la sección 'Carta Médica' del usuario.")) {
                    TextField("SG-XXXX-X", text: $idABuscar)
                        .textInputAutocapitalization(.characters)
                }
            }
            .navigationTitle("Vincular Paciente")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Vincular", action: accionVincular)
                        .bold()
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
            }
        }
    }
}
