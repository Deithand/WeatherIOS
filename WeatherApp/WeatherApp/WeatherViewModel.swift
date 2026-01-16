import Foundation
import CoreLocation
import Combine

@MainActor
class WeatherViewModel: NSObject, ObservableObject {
    @Published var currentWeather: WeatherResponse?
    @Published var forecast: ForecastResponse?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText = ""

    private let weatherService = WeatherService.shared
    private let locationManager = CLLocationManager()
    private var cancellables = Set<AnyCancellable>()

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    // MARK: - Запрос разрешения на геолокацию
    func requestLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }

    // MARK: - Загрузка погоды по названию города
    func loadWeather(for city: String) async {
        isLoading = true
        errorMessage = nil

        do {
            async let weatherData = weatherService.fetchCurrentWeather(for: city)
            async let forecastData = weatherService.fetchForecast(for: city)

            currentWeather = try await weatherData
            forecast = try await forecastData
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    // MARK: - Загрузка погоды по координатам
    func loadWeather(latitude: Double, longitude: Double) async {
        isLoading = true
        errorMessage = nil

        do {
            currentWeather = try await weatherService.fetchCurrentWeather(
                latitude: latitude,
                longitude: longitude
            )
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    // MARK: - Получение прогноза по дням
    func getDailyForecast() -> [DailyForecast] {
        guard let forecast = forecast else { return [] }

        let grouped = Dictionary(grouping: forecast.list) { item -> String in
            let date = Date(timeIntervalSince1970: TimeInterval(item.dt))
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            return formatter.string(from: date)
        }

        return grouped.map { key, items in
            let temps = items.map { $0.main.temp }
            let minTemp = temps.min() ?? 0
            let maxTemp = temps.max() ?? 0

            let weather = items.first?.weather.first

            return DailyForecast(
                date: key,
                minTemp: minTemp,
                maxTemp: maxTemp,
                weather: weather,
                items: items
            )
        }.sorted { $0.date < $1.date }
    }
}

// MARK: - CLLocationManagerDelegate
extension WeatherViewModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }

        Task {
            await loadWeather(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude
            )
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        errorMessage = "Не удалось получить местоположение: \(error.localizedDescription)"
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        case .denied, .restricted:
            errorMessage = "Доступ к геолокации запрещен"
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        @unknown default:
            break
        }
    }
}

// MARK: - Daily Forecast Model
struct DailyForecast: Identifiable {
    let id = UUID()
    let date: String
    let minTemp: Double
    let maxTemp: Double
    let weather: Weather?
    let items: [ForecastItem]

    var dayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: date) else { return "" }

        formatter.dateFormat = "EEEE"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date).capitalized
    }

    var minTempCelsius: String {
        return String(format: "%.0f°", minTemp - 273.15)
    }

    var maxTempCelsius: String {
        return String(format: "%.0f°", maxTemp - 273.15)
    }
}
