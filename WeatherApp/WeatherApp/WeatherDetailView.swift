import SwiftUI

struct WeatherDetailView: View {
    let forecast: DailyForecast

    var body: some View {
        ZStack {
            // Градиентный фон
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.3, green: 0.6, blue: 1.0),
                    Color(red: 0.5, green: 0.8, blue: 1.0)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 25) {
                    // Заголовок
                    VStack(spacing: 10) {
                        Text(forecast.dayName)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                        Text(forecast.weather?.weatherIcon ?? "🌤️")
                            .font(.system(size: 80))

                        Text(forecast.weather?.description.capitalized ?? "")
                            .font(.title2)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .padding()

                    // Температурный диапазон
                    VStack(spacing: 15) {
                        Text("Температура")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        HStack(spacing: 50) {
                            VStack {
                                Text("Минимум")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.7))

                                Text(forecast.minTempCelsius)
                                    .font(.system(size: 40, weight: .bold))
                                    .foregroundColor(.white)
                            }

                            Divider()
                                .background(Color.white.opacity(0.5))
                                .frame(height: 60)

                            VStack {
                                Text("Максимум")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.7))

                                Text(forecast.maxTempCelsius)
                                    .font(.system(size: 40, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(20)
                    .padding(.horizontal)

                    // Почасовой прогноз
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Почасовой прогноз")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(forecast.items, id: \.dt) { item in
                                    HourlyForecastCard(item: item)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }

                    // Детальная информация
                    if let firstItem = forecast.items.first {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Детали")
                                .font(.headline)
                                .foregroundColor(.white)

                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 15) {
                                DetailCard(
                                    icon: "humidity.fill",
                                    title: "Влажность",
                                    value: "\(firstItem.main.humidity)%"
                                )

                                DetailCard(
                                    icon: "wind",
                                    title: "Скорость ветра",
                                    value: firstItem.wind.speedKmh
                                )

                                DetailCard(
                                    icon: "gauge.medium",
                                    title: "Давление",
                                    value: "\(firstItem.main.pressure) hPa"
                                )

                                DetailCard(
                                    icon: "eye.fill",
                                    title: "Видимость",
                                    value: "\(firstItem.visibility / 1000) км"
                                )

                                DetailCard(
                                    icon: "cloud.fill",
                                    title: "Облачность",
                                    value: "\(firstItem.clouds.all)%"
                                )

                                DetailCard(
                                    icon: "drop.fill",
                                    title: "Вероятность дождя",
                                    value: String(format: "%.0f%%", firstItem.pop * 100)
                                )
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(20)
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Hourly Forecast Card
struct HourlyForecastCard: View {
    let item: ForecastItem

    var body: some View {
        VStack(spacing: 10) {
            Text(timeString)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))

            Text(item.weather.first?.weatherIcon ?? "🌤️")
                .font(.title)

            Text(tempString)
                .font(.headline)
                .foregroundColor(.white)

            HStack(spacing: 4) {
                Image(systemName: "wind")
                    .font(.caption2)
                Text(windSpeed)
                    .font(.caption2)
            }
            .foregroundColor(.white.opacity(0.7))
        }
        .padding()
        .frame(width: 100)
        .background(Color.white.opacity(0.2))
        .cornerRadius(15)
    }

    private var timeString: String {
        let date = Date(timeIntervalSince1970: TimeInterval(item.dt))
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private var tempString: String {
        return String(format: "%.0f°", item.main.temp - 273.15)
    }

    private var windSpeed: String {
        return String(format: "%.1f", item.wind.speed * 3.6)
    }
}

// MARK: - Detail Card
struct DetailCard: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)

            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)

            Text(value)
                .font(.headline)
                .foregroundColor(.white)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white.opacity(0.15))
        .cornerRadius(15)
    }
}

#Preview {
    NavigationView {
        WeatherDetailView(
            forecast: DailyForecast(
                date: "2024-01-15",
                minTemp: 270,
                maxTemp: 280,
                weather: Weather(
                    id: 800,
                    main: "Clear",
                    description: "ясно",
                    icon: "01d"
                ),
                items: []
            )
        )
    }
}
