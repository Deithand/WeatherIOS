import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = WeatherViewModel()
    @State private var showingSearch = false

    var body: some View {
        NavigationView {
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

                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.white)
                } else if let error = viewModel.errorMessage {
                    ErrorView(message: error) {
                        viewModel.requestLocation()
                    }
                } else if let weather = viewModel.currentWeather {
                    ScrollView {
                        VStack(spacing: 20) {
                            CurrentWeatherView(weather: weather)

                            if !viewModel.getDailyForecast().isEmpty {
                                ForecastListView(forecasts: viewModel.getDailyForecast())
                            }
                        }
                        .padding()
                    }
                } else {
                    WelcomeView {
                        viewModel.requestLocation()
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("Погода")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 15) {
                        Button(action: {
                            viewModel.requestLocation()
                        }) {
                            Image(systemName: "location.fill")
                                .foregroundColor(.white)
                        }

                        Button(action: {
                            showingSearch = true
                        }) {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            .sheet(isPresented: $showingSearch) {
                SearchView(viewModel: viewModel)
            }
        }
    }
}

// MARK: - Welcome View
struct WelcomeView: View {
    let onLocationRequest: () -> Void

    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "cloud.sun.fill")
                .font(.system(size: 100))
                .foregroundColor(.white)
                .shadow(radius: 10)

            VStack(spacing: 15) {
                Text("Добро пожаловать!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text("Узнайте погоду в вашем городе")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }

            Button(action: onLocationRequest) {
                HStack {
                    Image(systemName: "location.fill")
                    Text("Определить местоположение")
                }
                .font(.headline)
                .foregroundColor(.blue)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .cornerRadius(15)
                .shadow(radius: 5)
            }
            .padding(.horizontal, 40)
        }
    }
}

// MARK: - Error View
struct ErrorView: View {
    let message: String
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(.white)

            Text("Ошибка")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text(message)
                .font(.body)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button(action: onRetry) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Повторить")
                }
                .font(.headline)
                .foregroundColor(.blue)
                .padding()
                .background(Color.white)
                .cornerRadius(15)
            }
        }
    }
}

// MARK: - Current Weather View
struct CurrentWeatherView: View {
    let weather: WeatherResponse

    var body: some View {
        VStack(spacing: 15) {
            Text(weather.name)
                .font(.system(size: 40, weight: .medium))
                .foregroundColor(.white)

            Text(weather.sys.country)
                .font(.title3)
                .foregroundColor(.white.opacity(0.8))

            Text(weather.weather.first?.weatherIcon ?? "🌤️")
                .font(.system(size: 100))

            Text(weather.main.tempCelsius)
                .font(.system(size: 70, weight: .bold))
                .foregroundColor(.white)

            Text(weather.weather.first?.description.capitalized ?? "")
                .font(.title2)
                .foregroundColor(.white.opacity(0.9))

            // Детальная информация
            VStack(spacing: 20) {
                HStack(spacing: 40) {
                    WeatherInfoItem(
                        icon: "thermometer",
                        title: "Ощущается",
                        value: weather.main.feelsLikeCelsius
                    )

                    WeatherInfoItem(
                        icon: "humidity.fill",
                        title: "Влажность",
                        value: "\(weather.main.humidity)%"
                    )
                }

                HStack(spacing: 40) {
                    WeatherInfoItem(
                        icon: "wind",
                        title: "Ветер",
                        value: weather.wind.speedKmh
                    )

                    WeatherInfoItem(
                        icon: "gauge.medium",
                        title: "Давление",
                        value: "\(weather.main.pressure) hPa"
                    )
                }

                HStack(spacing: 40) {
                    WeatherInfoItem(
                        icon: "sunrise.fill",
                        title: "Восход",
                        value: weather.sys.sunrise.timeString
                    )

                    WeatherInfoItem(
                        icon: "sunset.fill",
                        title: "Закат",
                        value: weather.sys.sunset.timeString
                    )
                }
            }
            .padding()
            .background(Color.white.opacity(0.2))
            .cornerRadius(20)
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(25)
    }
}

// MARK: - Weather Info Item
struct WeatherInfoItem: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)

            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))

            Text(value)
                .font(.headline)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Forecast List View
struct ForecastListView: View {
    let forecasts: [DailyForecast]

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Прогноз на 5 дней")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.horizontal)

            VStack(spacing: 10) {
                ForEach(forecasts.prefix(5)) { forecast in
                    NavigationLink(destination: WeatherDetailView(forecast: forecast)) {
                        ForecastRow(forecast: forecast)
                    }
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(25)
    }
}

// MARK: - Forecast Row
struct ForecastRow: View {
    let forecast: DailyForecast

    var body: some View {
        HStack {
            Text(forecast.dayName)
                .font(.headline)
                .foregroundColor(.white)
                .frame(width: 100, alignment: .leading)

            Spacer()

            Text(forecast.weather?.weatherIcon ?? "🌤️")
                .font(.title2)

            Spacer()

            HStack(spacing: 15) {
                Text(forecast.minTempCelsius)
                    .foregroundColor(.white.opacity(0.7))

                Text(forecast.maxTempCelsius)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
            .font(.headline)
        }
        .padding()
        .background(Color.white.opacity(0.2))
        .cornerRadius(15)
    }
}

// MARK: - Search View
struct SearchView: View {
    @ObservedObject var viewModel: WeatherViewModel
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.3, green: 0.6, blue: 1.0),
                        Color(red: 0.5, green: 0.8, blue: 1.0)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 20) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.white.opacity(0.7))

                        TextField("Введите город", text: $searchText)
                            .foregroundColor(.white)
                            .accentColor(.white)
                            .autocapitalization(.words)
                            .onSubmit {
                                performSearch()
                            }

                        if !searchText.isEmpty {
                            Button(action: {
                                searchText = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(15)
                    .padding()

                    Text("Популярные города")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)

                    ScrollView {
                        VStack(spacing: 10) {
                            ForEach(popularCities, id: \.self) { city in
                                Button(action: {
                                    searchText = city
                                    performSearch()
                                }) {
                                    HStack {
                                        Image(systemName: "mappin.and.ellipse")
                                        Text(city)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                    }
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.white.opacity(0.2))
                                    .cornerRadius(15)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }

                    Spacer()
                }
            }
            .navigationTitle("Поиск города")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Закрыть") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }

    private func performSearch() {
        Task {
            await viewModel.loadWeather(for: searchText)
            dismiss()
        }
    }

    private let popularCities = [
        "Москва", "Санкт-Петербург", "Новосибирск",
        "Екатеринбург", "Казань", "Нижний Новгород",
        "Челябинск", "Самара", "Омск", "Ростов-на-Дону"
    ]
}

#Preview {
    ContentView()
}
