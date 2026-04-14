import SwiftUI

struct HomeView: View {
    // Estados para controlar la cámara/galería
    @State private var mostrarSelectorImagen = false
    @State private var imagenSeleccionada: UIImage?
    @State private var tipoDeFuente: UIImagePickerController.SourceType = .photoLibrary
    
    // Estados temporales para simular la IA
    @State private var estaProcesando = false
    @State private var analisisCompletado = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    
                    // 1. ÁREA DE IMAGEN Y RESULTADOS
                    if let imagen = imagenSeleccionada {
                        Image(uiImage: imagen)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 250)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                            .padding(.horizontal)
                        
                        // 2. CUADRO DE RECOMENDACIONES (Gestión de incertidumbre)
                        if analisisCompletado {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "shield.checkerboard")
                                        .foregroundColor(.blue)
                                    Text("Análisis Preliminar")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                }
                                
                                Text("Hemos detectado un patrón de pigmentación que sugiere revisión. Recuerda que SkinGuard es una herramienta de apoyo y **no un diagnóstico médico definitivo**.")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Text("💡 Recomendación:")
                                    .font(.subheadline)
                                    .bold()
                                    .padding(.top, 5)
                                
                                Text("Te sugerimos agendar una cita con un dermatólogo para una evaluación profesional y tener total tranquilidad.")
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
                                .padding(.horizontal, 40)
                        }
                        .padding(.top, 60)
                    }
                    
                    // 3. INDICADOR DE CARGA
                    if estaProcesando {
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
                    
                    // 4. BOTONES DE ACCIÓN
                    HStack(spacing: 20) {
                        Button(action: {
                            tipoDeFuente = .photoLibrary
                            mostrarSelectorImagen = true
                        }) {
                            VStack {
                                Image(systemName: "photo.on.rectangle")
                                    .font(.title)
                                Text("Galería")
                                    .font(.caption)
                                    .padding(.top, 2)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(15)
                        }
                        
                        Button(action: {
                            tipoDeFuente = .camera
                            mostrarSelectorImagen = true
                        }) {
                            VStack {
                                Image(systemName: "camera")
                                    .font(.title)
                                Text("Cámara")
                                    .font(.caption)
                                    .padding(.top, 2)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(15)
                            .shadow(color: Color.blue.opacity(0.3), radius: 5, x: 0, y: 3)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("SkinGuard")
            .sheet(isPresented: $mostrarSelectorImagen) {
                // Llama al ImagePicker que ya tienes en tu otro archivo
                ImagePicker(imagenSeleccionada: $imagenSeleccionada, sourceType: tipoDeFuente)
            }
            .onChange(of: imagenSeleccionada) { _ in
                if imagenSeleccionada != nil {
                    analisisCompletado = false
                    estaProcesando = true
                    // Simulación de espera de la IA
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        estaProcesando = false
                        analisisCompletado = true
                    }
                }
            }
        }
    }
}

#Preview {
    HomeView()
}
