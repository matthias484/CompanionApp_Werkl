import SwiftUI

// Struktur für Wetterdaten, angepasst an das API-Format
struct WeatherData: Codable {
    struct Current: Codable {
        let temp_c: Double
        let condition: Condition
    }
    struct Condition: Codable {
        let text: String
    }
    let current: Current
}

struct WetterView: View {
    @State private var city: String = ""
    @State private var temperature: String = "--"
    @State private var description: String = "--"
    @State private var isLoading: Bool = false

    let apiKey = Secrets.weatherAPIKey


     
    var body: some View {
        VStack(spacing: 20) {
            Text("Wetter")
                .font(.largeTitle)
                .padding()

            // Eingabefeld für Stadt
            TextField("Stadt eingeben", text: $city)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            // Wetter abrufen
            Button(action: fetchWeather) {
                Text("Wetter abrufen")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()

            if isLoading {
                ProgressView()
            } else {
                // Anzeige der Wetterdaten
                Text("Temperatur: \(temperature)°C")
                    .font(.title2)
                Text("Beschreibung: \(description)")
                    .font(.title3)
                    .foregroundColor(.gray)
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Wetter")
    }

    private func fetchWeather() {
        guard !city.isEmpty else { return }
        isLoading = true
        temperature = "--"
        description = "--"

        // API-URL zusammenstellen
        let cityQuery = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://api.weatherapi.com/v1/current.json?key=\(apiKey)&q=\(cityQuery)&lang=de"

        guard let url = URL(string: urlString) else {
            isLoading = false
            print("Ungültige URL")
            return
        }

        // API-Anfrage
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
            }

            // Fehlerbehandlung
            guard let data = data, error == nil else {
                print("Netzwerkfehler: \(error?.localizedDescription ?? "Unbekannter Fehler")")
                return
            }

            // Antwort debuggen
            print(String(data: data, encoding: .utf8) ?? "Keine Daten")

            // Wetterdaten dekodieren
            do {
                let weatherData = try JSONDecoder().decode(WeatherData.self, from: data)
                DispatchQueue.main.async {
                    self.temperature = String(format: "%.1f", weatherData.current.temp_c)
                    self.description = weatherData.current.condition.text.capitalized
                }
            } catch {
                print("Fehler beim Dekodieren: \(error.localizedDescription)")
            }
        }.resume()
    }
}
