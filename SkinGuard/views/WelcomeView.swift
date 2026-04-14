//
//  WelcomeView.swift
//  SkinGuard
//
//  Created by MaciOSLabAir29 on 14/04/26.
//


import SwiftUI

// MARK: - 1. PANTALLA DE BIENVENIDA (LANDING)
struct WelcomeView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Spacer()
                
                Image(systemName: "shield.checkerboard")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                VStack(spacing: 10) {
                    Text("SkinGuard")
                        .font(.largeTitle)
                        .bold()
                    Text("Prevención y seguimiento inteligente.")
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(spacing: 15) {
                    // BOTÓN 1: INICIAR SESIÓN (Va a otra pantalla)
                    NavigationLink(destination: SignInView()) {
                        Text("Iniciar Sesión")
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(15)
                    }
                    
                    // BOTÓN 2: REGISTRARSE (Va a otra pantalla)
                    NavigationLink(destination: SignUpView()) {
                        Text("Crear Cuenta")
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(15)
                    }
                    
                    // BOTÓN 3: INVITADO (Entra directo sin guardar datos)
                    Button(action: {
                        appState.isDoctor = false
                        appState.isLoggedIn = true
                    }) {
                        Text("Ingresar como Invitado")
                            .font(.callout)
                            .bold()
                            .foregroundColor(.secondary)
                            .padding(.top, 10)
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 50)
            }
        }
    }
}

// MARK: - 2. PANTALLA DE LOGIN ESTÁTICO
struct SignInView: View {
    @EnvironmentObject var appState: AppState
    @State private var usuario = ""
    @State private var password = ""
    @State private var mostrarError = false
    
    var body: some View {
        Form {
            Section(header: Text("Credenciales"), footer: Text("Para el prototipo usa usuario: medico / contraseña: 123")) {
                TextField("Usuario", text: $usuario)
                    .autocapitalization(.none)
                SecureField("Contraseña", text: $password)
            }
            
            if mostrarError {
                Text("Usuario o contraseña incorrectos")
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            Button(action: validarLogin) {
                Text("Entrar")
                    .bold()
                    .frame(maxWidth: .infinity)
                    .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
            }
        }
        .navigationTitle("Iniciar Sesión")
    }
    
    private func validarLogin() {
        // LOGIN ESTÁTICO PARA EL HACKATHON
        if usuario.lowercased() == "medico" && password == "123" {
            appState.isDoctor = true
            appState.isLoggedIn = true
        } else {
            mostrarError = true
        }
    }
}

// MARK: - 3. PANTALLA DE REGISTRO (Llena la cartilla)
struct SignUpView: View {
    @EnvironmentObject var appState: AppState
    
    // Variables para el formulario
    @State private var tipoUsuario = 0 // 0: Paciente, 1: Médico
    
    // Datos Paciente (Para la cartilla)
    @State private var edad = ""
    @State private var tipoPiel = "Intermedio"
    @State private var antPersonal = false
    @State private var antFamiliar = false
    
    // Datos Médico (Licencia)
    @State private var cedula = ""
    @State private var hospital = ""
    
    let opcionesPiel = ["Me quemo fácil", "Intermedio", "Me bronceo fácil"]
    
    var body: some View {
        Form {
            Section(header: Text("Tipo de Cuenta")) {
                Picker("Selecciona", selection: $tipoUsuario) {
                    Text("Paciente").tag(0)
                    Text("Médico").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.vertical, 5)
            }
            
            if tipoUsuario == 0 {
                // FORMULARIO PACIENTE (Alimenta la Cartilla)
                Section(header: Text("Datos para tu Cartilla Médica"), footer: Text("Estos datos ayudarán a llevar un mejor control de tu piel.")) {
                    TextField("Edad (Ej. 25)", text: $edad)
                        .keyboardType(.numberPad)
                    
                    Picker("Tipo de Piel", selection: $tipoPiel) {
                        ForEach(opcionesPiel, id: \.self) {
                            Text($0)
                        }
                    }
                    
                    Toggle("Antecedente Personal de Cáncer", isOn: $antPersonal)
                    Toggle("Antecedente Familiar de Cáncer", isOn: $antFamiliar)
                }
            } else {
                // FORMULARIO MÉDICO (Licencia)
                Section(header: Text("Datos de Licencia Profesional"), footer: Text("Tu cédula será validada en la plataforma.")) {
                    TextField("Cédula Profesional", text: $cedula)
                        .keyboardType(.numberPad)
                    TextField("Hospital o Clínica", text: $hospital)
                }
            }
            
            Section {
                Button(action: registrarUsuario) {
                    Text("Crear Cuenta y Entrar")
                        .bold()
                        .frame(maxWidth: .infinity)
                }
                // Desactiva el botón si faltan datos importantes
                .disabled(tipoUsuario == 0 ? edad.isEmpty : (cedula.isEmpty || hospital.isEmpty))
            }
        }
        .navigationTitle("Registro")
    }
    
    private func registrarUsuario() {
        if tipoUsuario == 0 {
            // 1. Guardamos los datos para que aparezcan en la Cartilla (CartaMedicaAIView)
            var nuevosDatos = DatosPaciente()
            nuevosDatos.edad = edad
            nuevosDatos.tipoPiel = tipoPiel
            nuevosDatos.antecedentePersonal = antPersonal
            nuevosDatos.antecedenteFamiliar = antFamiliar
            nuevosDatos.ubicacion = "No especificado" // Valores por defecto
            nuevosDatos.evolucion = "No especificado"
            nuevosDatos.guardar()
            
            // 2. Le damos acceso a la app de usuario
            appState.isDoctor = false
            appState.isLoggedIn = true
        } else {
            // Es Médico, entra directo al perfil de médico
            appState.isDoctor = true
            appState.isLoggedIn = true
        }
    }
}