import Foundation

// MARK: - Weather Response Models
struct WeatherResponse: Codable {
    let coord: Coordinates
    let weather: [Weather]
    let base: String
    let main: MainWeather
    let visibility: Int
    let wind: Wind
    let clouds: Clouds
    let dt: Int
    let sys: Sys
    let timezone: Int
    let id: Int
    let name: String
    let cod: Int
}

struct Coordinates: Codable {
    let lon: Double
    let lat: Double
}

struct Weather: Codable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}

struct MainWeather: Codable {
    let temp: Double
    let feelsLike: Double
    let tempMin: Double
    let tempMax: Double
    let pressure: Int
    let humidity: Int
    let seaLevel: Int?
    let grndLevel: Int?

    enum CodingKeys: String, CodingKey {
        case temp
        case feelsLike = "feels_like"
        case tempMin = "temp_min"
        case tempMax = "temp_max"
        case pressure
        case humidity
        case seaLevel = "sea_level"
        case grndLevel = "grnd_level"
    }
}

struct Wind: Codable {
    let speed: Double
    let deg: Int
    let gust: Double?
}

struct Clouds: Codable {
    let all: Int
}

struct Sys: Codable {
    let type: Int?
    let id: Int?
    let country: String
    let sunrise: Int
    let sunset: Int
}

// MARK: - Forecast Response Models
struct ForecastResponse: Codable {
    let cod: String
    let message: Int
    let cnt: Int
    let list: [ForecastItem]
    let city: City
}

struct ForecastItem: Codable {
    let dt: Int
    let main: MainWeather
    let weather: [Weather]
    let clouds: Clouds
    let wind: Wind
    let visibility: Int
    let pop: Double
    let sys: ForecastSys
    let dtTxt: String

    enum CodingKeys: String, CodingKey {
        case dt, main, weather, clouds, wind, visibility, pop, sys
        case dtTxt = "dt_txt"
    }
}

struct ForecastSys: Codable {
    let pod: String
}

struct City: Codable {
    let id: Int
    let name: String
    let coord: Coordinates
    let country: String
    let population: Int?
    let timezone: Int
    let sunrise: Int
    let sunset: Int
}

// MARK: - Helper Extensions
extension Weather {
    var weatherIcon: String {
        switch main.lowercased() {
        case "clear":
            return "☀️"
        case "clouds":
            return "☁️"
        case "rain":
            return "🌧️"
        case "drizzle":
            return "🌦️"
        case "thunderstorm":
            return "⛈️"
        case "snow":
            return "❄️"
        case "mist", "fog", "haze":
            return "🌫️"
        default:
            return "🌤️"
        }
    }
}

extension MainWeather {
    var tempCelsius: String {
        return String(format: "%.0f°C", temp - 273.15)
    }

    var feelsLikeCelsius: String {
        return String(format: "%.0f°C", feelsLike - 273.15)
    }
}

extension Wind {
    var speedKmh: String {
        return String(format: "%.1f km/h", speed * 3.6)
    }

    var direction: String {
        let directions = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
        let index = Int((Double(deg) + 22.5) / 45.0) % 8
        return directions[index]
    }
}

extension Int {
    var dateFromTimestamp: Date {
        return Date(timeIntervalSince1970: TimeInterval(self))
    }

    var timeString: String {
        let date = dateFromTimestamp
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
