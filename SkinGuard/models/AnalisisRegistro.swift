import Foundation

struct AnalisisRegistro: Identifiable, Codable {
    var id = UUID()
    let fecha: Date
    let ubicacion: String
    let nombreImagen: String
    let notas: String
    let resultado: String
    var confianza: Double? // NUEVO: Porcentaje de seguridad de la IA
    
    var fechaFormateada: String {
        fecha.formatted(date: .abbreviated, time: .omitted)
    }
}
