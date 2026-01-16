# Настройка Codemagic для сборки iOS приложения без Mac

## Что такое Codemagic?

Codemagic - это облачный CI/CD сервис специально для мобильных приложений (iOS, Android, Flutter). Он предоставляет виртуальные Mac машины для сборки iOS приложений.

## Преимущества

✅ Не нужен Mac для сборки
✅ Бесплатный план (500 минут сборки в месяц)
✅ Автоматическая сборка при push в Git
✅ Интеграция с App Store Connect
✅ Поддержка TestFlight

## Пошаговая инструкция

### Шаг 1: Регистрация в Codemagic

1. Перейдите на [codemagic.io](https://codemagic.io/)
2. Нажмите **Sign up for free**
3. Войдите через GitHub, GitLab или Bitbucket

### Шаг 2: Загрузка проекта в Git

```bash
# Инициализируйте Git репозиторий
cd WeatherApp
git init

# Добавьте все файлы
git add .

# Создайте первый коммит
git commit -m "Initial commit: Weather App"

# Создайте репозиторий на GitHub/GitLab/Bitbucket
# Затем подключите удаленный репозиторий
git remote add origin https://github.com/ваш-username/weather-app.git
git branch -M main
git push -u origin main
```

### Шаг 3: Добавление приложения в Codemagic

1. В Codemagic нажмите **Add application**
2. Выберите ваш Git провайдер (GitHub/GitLab/Bitbucket)
3. Выберите репозиторий **weather-app**
4. Выберите **iOS App**
5. Нажмите **Finish**

### Шаг 4: Настройка API ключа OpenWeather

В Codemagic вам нужно добавить ваш OpenWeather API ключ как переменную окружения:

1. Откройте ваше приложение в Codemagic
2. Перейдите в **Settings** → **Environment variables**
3. Добавьте переменную:
   - **Key**: `OPENWEATHER_API_KEY`
   - **Value**: ваш API ключ
   - **Secure**: ✅ (отметьте для безопасности)

4. Обновите код в `WeatherService.swift`:

```swift
// Измените эту строку:
private let apiKey = "YOUR_API_KEY_HERE"

// На эту:
private let apiKey = ProcessInfo.processInfo.environment["OPENWEATHER_API_KEY"] ?? ""
```

### Шаг 5A: Сборка без Apple Developer Account (Debug Build)

Если у вас **НЕТ** Apple Developer Account ($99):

1. В Codemagic перейдите в **Workflow editor**
2. Выберите workflow **ios-debug-build**
3. В разделе **Build** проверьте настройки:
   - **Xcode version**: Latest stable
   - **CocoaPods**: Default
4. Нажмите **Start new build**

Это создаст Debug версию приложения для симулятора.

**Что вы получите:**
- ✅ Сборка для iOS симулятора
- ✅ Проверка на ошибки компиляции
- ✅ Можно скачать .app файл
- ❌ Нельзя установить на реальное устройство
- ❌ Нельзя опубликовать в App Store

### Шаг 5B: Сборка для TestFlight/App Store (Release Build)

Если у вас **ЕСТЬ** Apple Developer Account:

#### 5B.1 Настройка Apple Developer Portal

1. Перейдите на [developer.apple.com](https://developer.apple.com/)
2. Создайте **App ID**:
   - Identifiers → App IDs → +
   - Bundle ID: `com.weatherapp.WeatherApp`
   - Capabilities: Location (When In Use)

3. Создайте приложение в [App Store Connect](https://appstoreconnect.apple.com/):
   - My Apps → + → New App
   - Platform: iOS
   - Name: Weather App
   - Bundle ID: выберите созданный ранее
   - SKU: WEATHERAPP001

#### 5B.2 Интеграция с Codemagic

1. В Codemagic: **Teams** → **Integrations**
2. Нажмите **Connect** напротив **App Store Connect**
3. Выберите способ подключения:

**Вариант 1: App Store Connect API (рекомендуется)**
- Перейдите в App Store Connect → Users and Access → Keys
- Создайте новый API ключ
- Скачайте `.p8` файл
- В Codemagic введите:
  - Issuer ID
  - Key ID
  - Загрузите .p8 файл

**Вариант 2: Apple ID с двухфакторной аутентификацией**
- Введите Apple ID и пароль
- Сгенерируйте App-specific password

#### 5B.3 Настройка Code Signing

1. В Codemagic: **App settings** → **Code signing identities**
2. Выберите **iOS Code signing**
3. Два способа:

**Автоматический (проще):**
- Выберите **Automatic**
- Codemagic автоматически создаст сертификаты

**Ручной (больше контроля):**
- Создайте сертификаты и provisioning profiles вручную
- Загрузите их в Codemagic

#### 5B.4 Обновление codemagic.yaml

В файле `codemagic.yaml` обновите:

```yaml
workflows:
  ios-weather-app:
    name: Weather App iOS Build
    environment:
      ios_signing:
        distribution_type: app_store
        bundle_identifier: com.weatherapp.WeatherApp
      vars:
        APP_STORE_APPLE_ID: 123456789  # Замените на ваш App ID
      xcode: 15.0
```

#### 5B.5 Запуск сборки

1. В Codemagic выберите workflow **ios-weather-app**
2. Нажмите **Start new build**
3. Дождитесь завершения сборки

**Что происходит:**
1. Codemagic клонирует репозиторий
2. Устанавливает зависимости
3. Настраивает code signing
4. Собирает .ipa файл
5. Загружает в TestFlight
6. Отправляет email с результатом

### Шаг 6: Автоматическая сборка

Чтобы настроить автоматическую сборку при push:

1. В `codemagic.yaml` раскомментируйте:

```yaml
triggering:
  events:
    - push
  branch_patterns:
    - pattern: 'main'
      include: true
      source: true
```

2. Теперь каждый push в ветку `main` будет запускать сборку

### Шаг 7: Мониторинг сборки

1. В Codemagic перейдите в **Builds**
2. Выберите вашу сборку
3. Смотрите логи в реальном времени
4. Скачайте артефакты (IPA, dSYM)

## Бесплатный план Codemagic

**Что включено:**
- 500 минут сборки в месяц
- Неограниченное количество приложений
- Неограниченные пользователи
- macOS M1 машины

**Ограничения:**
- 500 минут/месяц (примерно 10-15 сборок)
- Один параллельный билд

## Альтернативы Codemagic

Если 500 минут не хватает:

### GitHub Actions (бесплатно для публичных репозиториев)

```yaml
# .github/workflows/ios.yml
name: iOS Build
on:
  push:
    branches: [ main ]

jobs:
  build:
    runs-on: macos-13
    steps:
      - uses: actions/checkout@v3

      - name: Select Xcode
        run: sudo xcode-select -s /Applications/Xcode_15.0.app

      - name: Build
        run: |
          cd WeatherApp
          xcodebuild -project WeatherApp.xcodeproj \
            -scheme WeatherApp \
            -sdk iphonesimulator \
            -configuration Debug \
            build
```

**Лимиты:** 2000 минут/месяц для приватных репозиториев

### Bitrise (бесплатно)

- 200 минут/месяц бесплатно
- Простой UI для настройки
- [bitrise.io](https://www.bitrise.io/)

### CircleCI

- 6000 минут/месяц бесплатно
- Требует больше настройки
- [circleci.com](https://circleci.com/)

## Troubleshooting

### Ошибка: "Code signing failed"

**Решение:**
1. Проверьте Bundle ID совпадает везде
2. Убедитесь что интеграция с App Store Connect работает
3. Попробуйте пересоздать provisioning profile

### Ошибка: "Cannot find scheme"

**Решение:**
В `codemagic.yaml` проверьте:
```yaml
XCODE_SCHEME: "WeatherApp"  # Должно совпадать с именем схемы
```

### Ошибка: "Build took too long"

**Решение:**
1. Используйте `mac_mini_m1` instance (быстрее)
2. Кешируйте зависимости
3. Уменьшите количество операций

### API ключ не работает

**Решение:**
1. Проверьте что переменная `OPENWEATHER_API_KEY` добавлена
2. Убедитесь что она отмечена как Secure
3. Пересоберите проект

## Полезные ссылки

- [Документация Codemagic](https://docs.codemagic.io/)
- [Codemagic YAML reference](https://docs.codemagic.io/yaml/yaml-getting-started/)
- [iOS Code Signing](https://docs.codemagic.io/code-signing-yaml/signing-ios/)
- [OpenWeather API](https://openweathermap.org/api)

## Поддержка

Если у вас возникли проблемы:
1. Проверьте логи сборки в Codemagic
2. Посмотрите документацию
3. Спросите в [Codemagic Slack](https://codemagic-slack-invite.herokuapp.com/)
