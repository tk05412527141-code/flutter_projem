# Kombin Üretici

Offline çalışan bir kıyafet dolabı ve akıllı kombin üretme uygulaması. Kullanıcılar kıyafetlerini ekleyebilir, dolaplarını yönetebilir ve mevsim/renk uyumu ile skorlanan kombin önerileri alabilir.

## Özellikler

- **Dolap yönetimi**: Kıyafet ekleme, listeleme ve detay görüntüleme.
- **Akıllı kombin üretme**: Mevsim ve renk uyumuna göre skorlanan kombin önerisi.
- **Kombin geçmişi**: Üretilen kombinleri kaydetme ve görüntüleme.
- **Offline kullanım**: Yerel SQLite veritabanı.

## Ekran Görüntüsü

> 📸 Buraya uygulama ekran görüntüsü ekleyin.

## Kurulum

```bash
flutter pub get
flutter run
```

## Mimari

Proje, feature-first yapısıyla düzenlendi:

```
lib/
  core/                # ortak theme, utils, result/failure
  shared/              # ortak widgetlar
  features/
    wardrobe/
      data/
      domain/
      presentation/
    outfit/
      data/
      domain/
      presentation/
    auth/
      data/
      presentation/
```

- **Data layer**: SQLite erişimi ve repository implementasyonları.
- **Domain layer**: Use-case ve iş kuralları (kombin üretimi gibi).
- **Presentation layer**: Sayfalar, controller/provider’lar.

## Testler

```bash
flutter test
```

## CI

GitHub Actions ile aşağıdaki kontroller çalışır:

- `flutter pub get`
- `flutter analyze`
- `flutter test`

## Known Issues / Roadmap

- Kombin üretme algoritmasının aksesuar ve dış giyim kategorilerini desteklemesi.
- Kombin önerilerinde hava durumu entegrasyonu (offline veri ile).
- Detaylı filtreleme ve arama.
