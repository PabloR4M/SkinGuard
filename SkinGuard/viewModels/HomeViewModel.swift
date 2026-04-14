import SwiftUI
import Combine
import UIKit
import CoreML
import Vision
import CoreImage

class HomeViewModel: ObservableObject {
    @Published var imagenSeleccionada: UIImage?
    @Published var estaProcesando = false
    @Published var analisisCompletado = false
    @Published var resultadoPrediccion: String = ""
    @Published var nivelConfianza: Double = 0.0 // NUEVO: Guarda el % de la IA
    
    func analizarImagen() {
        guard let imagen = imagenSeleccionada else { return }
        
        self.estaProcesando = true
        self.analisisCompletado = false
        
        guard let cgImage = imagen.cgImage else {
            print("Error: No se pudo leer la imagen")
            self.estaProcesando = false
            return
        }
        
        let configuracion = MLModelConfiguration()
        configuracion.computeUnits = .cpuOnly // A prueba de simulador
        
        guard let modelo = try? VNCoreMLModel(for: SkinModel(configuration: configuracion).model) else {
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
                    // NUEVO: Guardamos la confianza (viene de 0.0 a 1.0, lo usaremos como %)
                    self.nivelConfianza = Double(mejorResultado.confidence)
                    self.analisisCompletado = true
                }
            }
        }
        
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
