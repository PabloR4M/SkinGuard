import SwiftUI
import Combine
import UIKit
import CoreML
import Vision
import CoreImage

class SeguimientoViewModel: ObservableObject {
    @Published var registros: [AnalisisRegistro] = []
    
    init() {
        cargarRegistros()
    }
    
    // MARK: - GUARDAR NUEVO REGISTRO
        func guardarRegistro(imagen: UIImage, ubicacion: String, notas: String, resultado: String, confianza: Double) {
            let nombreArchivo = UUID().uuidString + ".jpg"
            
            if let data = imagen.jpegData(compressionQuality: 0.8) {
                let url = getDocumentsDirectory().appendingPathComponent(nombreArchivo)
                try? data.write(to: url)
            }
            
            // Pasamos la confianza al registro
            let nuevoRegistro = AnalisisRegistro(fecha: Date(), ubicacion: ubicacion, nombreImagen: nombreArchivo, notas: notas, resultado: resultado, confianza: confianza)
            
            registros.insert(nuevoRegistro, at: 0)
            guardarEnUserDefaults()
        }
    
    // MARK: - ELIMINAR REGISTRO
    func eliminarRegistro(_ registro: AnalisisRegistro) {
        // 1. Borrar la foto del teléfono
        let url = getDocumentsDirectory().appendingPathComponent(registro.nombreImagen)
        try? FileManager.default.removeItem(at: url)
        
        // 2. Quitarlo de la lista
        registros.removeAll { $0.id == registro.id }
        guardarEnUserDefaults()
    }
    
    // MARK: - FUNCIONES INTERNAS (UserDefaults y FileManager)
    private func guardarEnUserDefaults() {
        if let encoded = try? JSONEncoder().encode(registros) {
            UserDefaults.standard.set(encoded, forKey: "HistorialAnalisis")
        }
    }
    
    private func cargarRegistros() {
        if let data = UserDefaults.standard.data(forKey: "HistorialAnalisis"),
           let decoded = try? JSONDecoder().decode([AnalisisRegistro].self, from: data) {
            self.registros = decoded
        }
    }
    
    // Obtiene la ruta segura de la carpeta de la app en el iPhone
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    // Función para leer la imagen guardada
    func cargarImagenLocal(nombre: String) -> UIImage? {
        let url = getDocumentsDirectory().appendingPathComponent(nombre)
        if let data = try? Data(contentsOf: url) {
            return UIImage(data: data)
        }
        return nil
    }
}
