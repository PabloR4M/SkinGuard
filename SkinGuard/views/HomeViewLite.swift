import SwiftUI

struct HomeViewLite: View {
    @StateObject private var viewModel = HomeViewModel()
    @EnvironmentObject var seguimientoVM: SeguimientoViewModel
    
    @State private var mostrarSelectorImagen = false
    @State private var tipoDeFuente: UIImagePickerController.SourceType = .photoLibrary
    
    // Estados para la ventana de guardar
    @State private var mostrarHojaGuardar = false
    @State private var inputNotas = ""
    
    // NUEVO: Lista de partes del cuerpo y estado inicial del Picker
    let opcionesCuerpo = ["Cara / Cabeza", "Cuello", "Pecho", "Espalda", "Abdomen", "Brazo Izquierdo", "Brazo Derecho", "Pierna Izquierda", "Pierna Derecha", "Zonas Íntimas", "Otro"]
    @State private var inputUbicacion = "Cara / Cabeza"
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    if let imagen = viewModel.imagenSeleccionada {
                        Image(uiImage: imagen)
                            .resizable().scaledToFill().frame(height: 250)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                            .padding(.horizontal)
                        
                        if viewModel.analisisCompletado {
                            VStack(alignment: .leading, spacing: 15) {
                                HStack {
                                    Image(systemName: viewModel.resultadoPrediccion == "Irregulares" ? "exclamationmark.triangle.fill" : "checkmark.shield.fill")
                                        .foregroundColor(viewModel.resultadoPrediccion == "Irregulares" ? .orange : .green)
                                    Text(viewModel.resultadoPrediccion == "Irregulares" ? "Revisión Sugerida" : "Análisis Favorable").font(.headline).foregroundColor(.primary)
                                }
                            
                                
                                Text(viewModel.resultadoPrediccion == "Irregulares" ? "Hemos detectado un patrón que sugiere revisión. Recuerda que SkinGuard es una herramienta de apoyo y no un diagnóstico médico definitivo." : "No se detectan irregularidades de alto riesgo, pero la prevención es clave.").font(.subheadline).foregroundColor(.secondary)
                            }
                            .padding(20).background(Color(UIColor.secondarySystemBackground)).cornerRadius(20).padding(.horizontal)
                            
                            HStack(spacing: 15) {
                                Button(action: descartar) {
                                    Text("Descartar").bold().frame(maxWidth: .infinity).padding()
                                        .background(Color.red.opacity(0.1)).foregroundColor(.red).cornerRadius(15)
                                }
                                
                                Button(action: { mostrarHojaGuardar = true }) {
                                    Text("Guardar Registro").bold().frame(maxWidth: .infinity).padding()
                                        .background(Color.blue).foregroundColor(.white).cornerRadius(15)
                                }
                            }
                            .padding(.horizontal)
                        }
                    } else {
                        VStack {
                            Image(systemName: "viewfinder").resizable().scaledToFit().frame(width: 80, height: 80).foregroundColor(.gray.opacity(0.5))
                            Text("Sube una foto de la lesión").foregroundColor(.gray).padding(.top)
                        }.padding(.top, 60)
                    }
                    
                    if viewModel.estaProcesando { ProgressView().scaleEffect(1.5).padding() }
                    Spacer(minLength: 40)
                    
                    if !viewModel.analisisCompletado && !viewModel.estaProcesando {
                        HStack(spacing: 20) {
                            Button(action: { tipoDeFuente = .photoLibrary; mostrarSelectorImagen = true }) {
                                VStack { Image(systemName: "photo.on.rectangle").font(.title); Text("Galería").font(.caption) }
                                .frame(maxWidth: .infinity).padding().background(Color.blue.opacity(0.1)).foregroundColor(.blue).cornerRadius(15)
                            }
                            Button(action: { tipoDeFuente = .camera; mostrarSelectorImagen = true }) {
                                VStack { Image(systemName: "camera").font(.title); Text("Cámara").font(.caption) }
                                .frame(maxWidth: .infinity).padding().background(Color.blue).foregroundColor(.white).cornerRadius(15)
                            }
                        }.padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("SkinGuard")
            .sheet(isPresented: $mostrarSelectorImagen) {
                ImagePicker(imagenSeleccionada: $viewModel.imagenSeleccionada, sourceType: tipoDeFuente)
            }
            .onChange(of: viewModel.imagenSeleccionada) { _, newValue in
                if newValue != nil { viewModel.analizarImagen() }
            }
            .sheet(isPresented: $mostrarHojaGuardar) {
                NavigationView {
                    Form {
                        Section(header: Text("Detalles de la lesión")) {
                            
                            // NUEVO: MENÚ DESPLEGABLE (PICKER)
                            Picker("Ubicación en el cuerpo", selection: $inputUbicacion) {
                                ForEach(opcionesCuerpo, id: \.self) { opcion in
                                    Text(opcion).tag(opcion)
                                }
                            }
                            
                            TextField("Notas u observaciones...", text: $inputNotas, axis: .vertical).lineLimit(3...6)
                        }
                    }
                    .navigationTitle("Guardar Análisis")
                    .navigationBarItems(
                        leading: Button("Cancelar") { mostrarHojaGuardar = false },
                        trailing: Button("Guardar") {
                            guardarRegistroFinal()
                        }
                    )
                }
            }
        }
    }
    
    private func descartar() {
        withAnimation {
            viewModel.imagenSeleccionada = nil
            viewModel.analisisCompletado = false
            viewModel.resultadoPrediccion = ""
            viewModel.nivelConfianza = 0.0
            inputUbicacion = "Cara / Cabeza" // Reinicia al valor por defecto
            inputNotas = ""
        }
    }
    
    private func guardarRegistroFinal() {
        if let imagen = viewModel.imagenSeleccionada {
            // Se le pasa la confianza al guardar
            seguimientoVM.guardarRegistro(imagen: imagen, ubicacion: inputUbicacion, notas: inputNotas, resultado: viewModel.resultadoPrediccion, confianza: viewModel.nivelConfianza)
        }
        mostrarHojaGuardar = false
        descartar()
    }
}
