import SwiftUI
import Combine
import UIKit
import CoreML
import Vision
import CoreImage

class AppState: ObservableObject {
    // UserDefaults guarda la sesión para que no tengan que loguearse cada vez que abren la app
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    @AppStorage("isDoctor") var isDoctor: Bool = false
    
    func cerrarSesion() {
        isLoggedIn = false
        isDoctor = false
    }
}
