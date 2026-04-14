import SwiftUI
import Combine
import UIKit
import CoreML
import Vision
import CoreImage

class HomeViewModel: ObservableObject {
    // Estas variables avisan a la vista cuando cambian (@Published)
    @Published var imagenSeleccionada: UIImage?
    @Published var estaProcesando = false
    @Published var analisisCompletado = false
    @Published var resultadoPrediccion: String = ""
    
    // Función que analiza la imagen real con la IA
        func analizarImagen() {
            guard let imagen = imagenSeleccionada else { return }
            
            self.estaProcesando = true
            self.analisisCompletado = false
            
            // ¡CAMBIO CLAVE PARA iPHONE REAL!
            // Usamos cgImage que es mucho más estable y seguro para las fotos del celular
            guard let cgImage = imagen.cgImage else {
                print("Error: No se pudo leer la imagen del iPhone")
                self.estaProcesando = false
                return
            }
            
            guard let modelo = try? VNCoreMLModel(for: SkinModel(configuration: MLModelConfiguration()).model) else {
                print("Error al cargar SkinModel")
                self.estaProcesando = false
                return
            }
            
            let peticion = VNCoreMLRequest(model: modelo) { request, error in
                DispatchQueue.main.async {
                    self.estaProcesando = false
                    
                    if let resultados = request.results as? [VNClassificationObservation],
                       let mejorResultado = resultados.first {
                        
                        self.resultadoPrediccion = mejorResultado.identifier
                        self.analisisCompletado = true
                        print("Predicción: \(mejorResultado.identifier)")
                    }
                }
            }
            
            // Le pasamos el cgImage en lugar del ciImage
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            DispatchQueue.global(qos: .userInteractive).async {
                do {
                    try handler.perform([peticion])
                } catch {
                    print("Error de IA: \(error)")
                }
            }
        }
}
