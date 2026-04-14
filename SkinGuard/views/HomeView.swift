import SwiftUI

struct HomeView: View {
    // Conectamos la vista con su "Cerebro"
    @StateObject private var viewModel = HomeViewModel()
    
    // Estados exclusivos de la interfaz (Cámara/Galería)
    @State private var mostrarSelectorImagen = false
    @State private var tipoDeFuente: UIImagePickerController.SourceType = .photoLibrary
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    
                    // 1. ÁREA DE IMAGEN
                    if let imagen = viewModel.imagenSeleccionada {
                        Image(uiImage: imagen)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 250)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                            .padding(.horizontal)
                        
                        // 2. RESULTADOS DE LA IA
                        if viewModel.analisisCompletado {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: viewModel.resultadoPrediccion == "Irregulares" ? "exclamationmark.triangle.fill" : "checkmark.shield.fill")
                                        .foregroundColor(viewModel.resultadoPrediccion == "Irregulares" ? .orange : .green)
                                    
                                    Text(viewModel.resultadoPrediccion == "Irregulares" ? "Revisión Sugerida" : "Análisis Favorable")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                }
                                
                                Text(viewModel.resultadoPrediccion == "Irregulares" ?
                                     "Hemos detectado un patrón que sugiere revisión. Recuerda que SkinGuard es una herramienta de apoyo y **no un diagnóstico médico definitivo**." :
                                     "No se detectan irregularidades de alto riesgo, pero la prevención es clave.")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Text("💡 Recomendación:")
                                    .font(.subheadline)
                                    .bold()
                                    .padding(.top, 5)
                                
                                Text(viewModel.resultadoPrediccion == "Irregulares" ?
                                     "Te sugerimos agendar una cita con un dermatólogo para una evaluación profesional." :
                                     "Sigue usando protector solar y monitorea tu piel regularmente.")
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                            }
                            .padding(20)
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(20)
                            .padding(.horizontal)
                        }
                    } else {
                        // Estado Vacío
                        VStack {
                            Image(systemName: "viewfinder")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                                .foregroundColor(.gray.opacity(0.5))
                            
                            Text("Toma o sube una foto de la lesión para comenzar")
                                .multilineTextAlignment(.center)
                                .foregroundColor(.gray)
                                .padding(.top)
                        }
                        .padding(.top, 60)
                    }
                    
                    // 3. INDICADOR DE CARGA
                    if viewModel.estaProcesando {
                        VStack {
                            ProgressView()
                                .scaleEffect(1.5)
                            Text("Analizando patrón...")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .padding(.top, 8)
                        }
                        .padding(.top, 20)
                    }
                    
                    Spacer(minLength: 40)
                    
                    // 4. BOTONES
                    HStack(spacing: 20) {
                        Button(action: {
                            tipoDeFuente = .photoLibrary
                            mostrarSelectorImagen = true
                        }) {
                            VStack {
                                Image(systemName: "photo.on.rectangle").font(.title)
                                Text("Galería").font(.caption).padding(.top, 2)
                            }
                            .frame(maxWidth: .infinity).padding()
                            .background(Color.blue.opacity(0.1)).foregroundColor(.blue).cornerRadius(15)
                        }
                        
                        Button(action: {
                            tipoDeFuente = .camera
                            mostrarSelectorImagen = true
                        }) {
                            VStack {
                                Image(systemName: "camera").font(.title)
                                Text("Cámara").font(.caption).padding(.top, 2)
                            }
                            .frame(maxWidth: .infinity).padding()
                            .background(Color.blue).foregroundColor(.white).cornerRadius(15)
                            .shadow(color: Color.blue.opacity(0.3), radius: 5, x: 0, y: 3)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("SkinGuard")
            .sheet(isPresented: $mostrarSelectorImagen) {
                // El ImagePicker ahora guarda la foto en el ViewModel
                ImagePicker(imagenSeleccionada: $viewModel.imagenSeleccionada, sourceType: tipoDeFuente)
            }
            .onChange(of: viewModel.imagenSeleccionada) { oldValue, newValue in
                if newValue != nil {
                    // Cuando hay foto nueva, le decimos al cerebro que la analice con la IA
                    viewModel.analizarImagen()
                }
            }
        }
    }
}

#Preview {
    HomeView()
}
