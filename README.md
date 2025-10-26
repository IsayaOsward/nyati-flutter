# 🐃 Nyati

[![pub package](https://img.shields.io/pub/v/nyati.svg)](https://pub.dev/packages/nyati)
[![Dart CLI](https://img.shields.io/badge/Dart-CLI-blue.svg)](https://dart.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

**Nyati** is a command-line interface (CLI) tool that helps you **generate Flutter projects** with a **custom folder structure and boilerplate**.
It is built to save time and enforce consistency across Flutter apps.

---

## 🚀 Features

* Creates a new Flutter project automatically using `flutter create`
* Adds a clean, maintainable folder structure (`core/`, `features/`, `widgets/`)
* Includes starter files (`main.dart`, `app.dart`, `router.dart`, `theme.dart`)
* Automatically installs common dependencies (`go_router`, `provider`, etc.)
* Initializes a Git repository
* Supports future expansions (e.g., `nyati add feature auth`)

---

## ⚙️ Installation

Install globally from pub.dev:

```bash
dart pub global activate nyati
```

> After this, the CLI command `nyati` will be available globally.

---

## ⚙️ Usage

Create a new Flutter project:

```bash
nyati my_app
```

Optional subcommands (if implemented):

```bash
nyati init my_app
```

> This will generate a Flutter project with your custom folder structure and starter files.

---

## 📂 Project Structure

Generated project structure:

```
my_app/
 ┣ lib/
 ┃ ┣ core/
 ┃ ┃ ┣ constants/
 ┃ ┃ ┣ routes/app_router.dart
 ┃ ┃ ┣ themes/app_theme.dart
 ┃ ┣ features/
 ┃ ┃ ┣ auth/
 ┃ ┃ ┃ ┣ data/
 ┃ ┃ ┃ ┣ domain/
 ┃ ┃ ┃ ┗ presentation/
 ┃ ┃ ┣ home/
 ┃ ┃ ┃ ┗ presentation/home_page.dart
 ┃ ┣ widgets/
 ┃ ┣ app.dart
 ┃ ┗ main.dart
 ┣ pubspec.yaml
 ┣ README.md
 ┗ .git/
```

---

## ▶️ Run the Project

```bash
cd my_app
flutter run
```

---

## 🧩 Updating Nyati

To update to the latest version:

```bash
dart pub global activate nyati
```

---

## 🧰 Local Development / Contributing

If you want to contribute or test changes locally:

```bash
# Clone repository
git clone https://github.com/yourusername/nyati.git
cd nyati

# Activate locally
dart pub global activate --source path .

# Test CLI
nyati demo_app
```

---

## 💡 Planned Features

* `nyati add feature <name>` → auto-generate a new feature module
* Colored terminal output using `ansicolor`
* Configurable templates via `nyati_config.yaml`
* Custom dependency injection setup

---

## 🖼️ Example Output

```
🚀 Creating Flutter project "my_app"...
🧱 Applying clean architecture structure...
📦 Adding dependencies: provider, go_router
🪄 Initializing git repository...
✅ Project "my_app" created successfully!
👉 cd my_app
👉 flutter run
```

---

## ❤️ Why “Nyati”?

In Swahili, **Nyati** means *Buffalo* — strong, determined, and unstoppable.
This CLI aims to embody that spirit: **powerful, fast, and dependable** for Flutter developers.

---

## 🤝 Contributing

Contributions, issues, and feature requests are welcome!
Feel free to open an issue or pull request on [GitHub](https://github.com/yourusername/nyati).

---

## 📜 License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

---

## 🌍 Links

* **Pub.dev:** [https://pub.dev/packages/nyati](https://pub.dev/packages/nyati)
* **Repository:** [https://github.com/isayaosward/nyati](https://github.com/yourusername/nyati)
* **Author:** Isaya Osward
