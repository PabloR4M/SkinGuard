import Foundation

struct AnalisisRegistro: Identifiable, Codable {
    var id = UUID()
    let fecha: Date
    let ubicacion: String
    let nombreImagen: String // Referencia al archivo en el iPhone
    let notas: String
    let resultado: String // "Regulares" o "Irregulares"
    
    var fechaFormateada: String {
        fecha.formatted(date: .abbreviated, time: .omitted)
    }
}
