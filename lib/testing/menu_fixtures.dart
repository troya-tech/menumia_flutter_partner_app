import 'package:menumia_flutter_partner_app/features/menu/domain/entities/menu.dart';
import 'package:menumia_flutter_partner_app/features/menu/infrastructure/dtos/menu_dto.dart';

class MenuFixtures {
  /// Returns the Forknife menu fixture.
  static Menu get forknife => _fromRaw('menuKey_forknife');

  /// Returns the NFC17 menu fixture.
  static Menu get nfc17 => _fromRaw('menuKey_nfc17');

  /// Returns the Millet Bahcesi Lapseki menu fixture.
  static Menu get milletBahcesi => _fromRaw('key_millet-bahcesi-lapseki-sosyal-tesisleri');

  /// Returns the Tesis 3 menu fixture.
  static Menu get tesis3 => _fromRaw('key_tesis3');

  /// Helper to create a Menu entity from the raw data.
  static Menu _fromRaw(String key) {
    final data = rawMenuData[key];
    if (data == null) throw Exception('Menu fixture for key "$key" not found');
    return MenuDto.fromJson(Map<String, dynamic>.from(data), key).toDomain();
  }

  /// Raw data based on the provided JSON for testing purposes.
  static final Map<String, dynamic> rawMenuData = {
    "key_millet-bahcesi-lapseki-sosyal-tesisleri": {
      "categories": {
        "category001": {
          "displayOrder": 2,
          "id": 1,
          "isActive": true,
          "menuItem": {
            "B3eGuuBbutZ8HSPVhVYgbRr6W7D3": {
              "description": "Ezine Peyniri, Kaşar Peyniri, Yeşil Zeytin, Siyah Zeytin, Bal, Tereyağı, Reçel, Yumurta, Domates, Salatalık",
              "displayOrder": 2,
              "id": 1,
              "imageUrl": "",
              "name": "Mini Kahvaltı",
              "price": 320
            },
            "C4eHvvCcutY9ISPWiWZhcSs7Y8E4": {
              "description": "Menemen, Beyaz Peynir, Zeytin, Salça, Bal, Tereyağı",
              "displayOrder": 3,
              "id": 2,
              "imageUrl": "",
              "name": "Menemen Tabağı",
              "price": 290
            },
            "D5fIwwDdutZ0JTPXjXaidTt8Z9F5": {
              "description": "Börek, Baget Ekmeği, Peynir, Salça, Zeytin, Kaynamış Yumurta, Bal, Kaymak",
              "displayOrder": 1,
              "id": 3,
              "imageUrl": "",
              "name": "Börek Tabağı",
              "price": 270
            },
            "E6gJxxEeutA1KUPYkYbieUu9A0G6": {
              "description": "Ezine Peyniri, Kaşar Peyniri, Çeçil Peyniri, Salça, Zeytin Yağı, Yeşil Zeytin, Siyah Zeytin, Bal, Kaymak, Tereyağı, Reçel, Tahin & Pekmez, Domates, Salatalık, Yeşillik, Çikolata, Kruvasan, Baget Ekmeği, Simit, Yumurta, Pankek, Sosis, Sigara Böreği, Nugget, Patates Kızartması, Meyve Tabağı, Acuka, Peynir Topları, Kapya Lor Kızartma, Meyve Tabağı, Kuy mak, Sınırsız Çay, Türk Kahvesi İkramı",
              "displayOrder": 4,
              "id": 4,
              "imageUrl": "",
              "name": "Serpme Kahvaltı",
              "price": 950
            },
            "F7hKyyFfvtB2LVQZlZcjfVv0B1H7": {"description": "Sahanda servis edilir", "displayOrder": 5, "id": 5, "imageUrl": "", "name": "Mıhlama", "price": 170},
            "G8iLzzGgwuC3MWRAmAfgwWw1C2I8": {"description": "Sahanda servis edilir", "displayOrder": 6, "id": 6, "imageUrl": "", "name": "Sahanda Sucuk", "price": 170},
            "H9jMaaHhxuD4NXSBnBghxXx2D3J9": {"description": "Sahanda servis edilir", "displayOrder": 7, "id": 7, "imageUrl": "", "name": "Sahanda Yumurta", "price": 200},
            "I0kNbbIiyvE5OYTCoChiyYy3E4K0": {"description": "Sahanda servis edilir", "displayOrder": 8, "id": 8, "imageUrl": "", "name": "Sahanda Sucuklu Yumurta", "price": 200},
            "J1lOccJjzwF6PZUDpDijzZz4F5L1": {"description": "Sahanda servis edilir", "displayOrder": 9, "id": 9, "imageUrl": "", "name": "Menemen", "price": 200},
            "K2mPddKkaxG7QAVEqEkkaAa5G6M2": {"description": "Sahanda servis edilir", "displayOrder": 10, "id": 10, "imageUrl": "", "name": "Kaşarlı Menemen", "price": 230},
            "L3nQeeLlayH8RBWFqFllbBb6H7N3": {"description": "Sahanda servis edilir", "displayOrder": 11, "id": 11, "imageUrl": "", "name": "Karışık Menemen", "price": 220},
            "M4oRffMmbyI9SCXGrGmmcCc7I8O4": {"description": "Sahanda servis edilir", "displayOrder": 12, "id": 12, "imageUrl": "", "name": "Omlet", "price": 170},
            "N5pSggNnczJ0TDYHsHnndDd8J9P5": {"description": "Sahanda servis edilir", "displayOrder": 13, "id": 13, "imageUrl": "", "name": "Kaşarlı Omlet", "price": 200},
            "O6qThhOodA1UEEZItIoodEe9K0Q6": {"description": "Sahanda servis edilir", "displayOrder": 14, "id": 14, "imageUrl": "", "name": "Karışık Omlet", "price": 220}
          },
          "name": "Kahvaltılar"
        },
        "category002": {
          "displayOrder": 1,
          "id": 2,
          "isActive": true,
          "menuItem": {
            "P7rUiiPpeyJ1VFVJtJppeFf0L1R7": {"description": "Sour Cream Sos ve Patates Kızartması ile servis edilir", "displayOrder": 2, "id": 1, "imageUrl": "", "name": "Karışık Tost", "price": 190},
            "Q8sVjjQqfzK2WGWKuKqqgGg1M2S8": {"description": "Sour Cream Sos ve Patates Kızartması ile servis edilir", "displayOrder": 3, "id": 2, "imageUrl": "", "name": "Kaşarlı Tost", "price": 190},
            "R9tWkkRrgaL3XHXLvLrrhHh2N3T9": {"description": "Sour Cream Sos ve Patates Kızartması ile servis edilir", "displayOrder": 1, "id": 3, "imageUrl": "", "name": "Üç Peynirli Tost", "price": 220},
            "S0uXllSshbM4YIYMwMssiIi3O4U0": {"description": "Sour Cream Sos ve Patates Kızartması ile servis edilir", "displayOrder": 4, "id": 4, "imageUrl": "", "name": "Beyaz Peynirli Tost", "price": 190},
            "T1vYmmTticN5ZJZNxNttjJj4P5V1": {"description": "Sour Cream Sos ve Patates Kızartması ile servis edilir", "displayOrder": 5, "id": 5, "imageUrl": "", "name": "Forknife Special Tost", "price": 240},
            "product_1769730878141": {"description": "", "displayOrder": 6, "imageUrl": "", "name": "yeni", "price": 1}
          },
          "name": "Tostlarr_tesis"
        }
      }
    },
    "key_tesis3": {
      "categories": {
        "category001": {
          "displayOrder": 2,
          "id": 1,
          "isActive": true,
          "menuItem": {
            "B3eGuuBbutZ8HSPVhVYgbRr6W7D3": {
              "description": "Ezine Peyniri, Kaşar Peyniri, Yeşil Zeytin, Siyah Zeytin, Bal, Tereyağı, Reçel, Yumurta, Domates, Salatalık",
              "displayOrder": 2,
              "id": 1,
              "imageUrl": "",
              "name": "Mini Kahvaltı",
              "price": 320
            },
            "C4eHvvCcutY9ISPWiWZhcSs7Y8E4": {
              "description": "Menemen, Beyaz Peynir, Zeytin, Salça, Bal, Tereyağı",
              "displayOrder": 3,
              "id": 2,
              "imageUrl": "",
              "name": "Menemen Tabağı",
              "price": 290
            },
            "D5fIwwDdutZ0JTPXjXaidTt8Z9F5": {
              "description": "Börek, Baget Ekmeği, Peynir, Salça, Zeytin, Kaynamış Yumurta, Bal, Kaymak",
              "displayOrder": 1,
              "id": 3,
              "imageUrl": "",
              "name": "Börek Tabağı",
              "price": 270
            },
            "E6gJxxEeutA1KUPYkYbieUu9A0G6": {
              "description": "Ezine Peyniri, Kaşar Peyniri, Çeçil Peyniri, Salça, Zeytin Yağı, Yeşil Zeytin, Siyah Zeytin, Bal, Kaymak, Tereyağı, Reçel, Tahin & Pekmez, Domates, Salatalık, Yeşillik, Çikolata, Kruvasan, Baget Ekmeği, Simit, Yumurta, Pankek, Sosis, Sigara Böreği, Nugget, Patates Kızartması, Meyve Tabağı, Acuka, Peynir Topları, Kapya Lor Kızartma, Meyve Tabağı, Kuy mak, Sınırsız Çay, Türk Kahvesi İkramı",
              "displayOrder": 4,
              "id": 4,
              "imageUrl": "",
              "name": "Serpme Kahvaltı",
              "price": 950
            },
            "F7hKyyFfvtB2LVQZlZcjfVv0B1H7": {"description": "Sahanda servis edilir", "displayOrder": 5, "id": 5, "imageUrl": "", "name": "Mıhlama", "price": 170},
            "G8iLzzGgwuC3MWRAmAfgwWw1C2I8": {"description": "Sahanda servis edilir", "displayOrder": 6, "id": 6, "imageUrl": "", "name": "Sahanda Sucuk", "price": 170},
            "H9jMaaHhxuD4NXSBnBghxXx2D3J9": {"description": "Sahanda servis edilir", "displayOrder": 7, "id": 7, "imageUrl": "", "name": "Sahanda Yumurta", "price": 200},
            "I0kNbbIiyvE5OYTCoChiyYy3E4K0": {"description": "Sahanda servis edilir", "displayOrder": 8, "id": 8, "imageUrl": "", "name": "Sahanda Sucuklu Yumurta", "price": 200},
            "J1lOccJjzwF6PZUDpDijzZz4F5L1": {"description": "Sahanda servis edilir", "displayOrder": 9, "id": 9, "imageUrl": "", "name": "Menemen", "price": 200},
            "K2mPddKkaxG7QAVEqEkkaAa5G6M2": {"description": "Sahanda servis edilir", "displayOrder": 10, "id": 10, "imageUrl": "", "name": "Kaşarlı Menemen", "price": 230},
            "L3nQeeLlayH8RBWFqFllbBb6H7N3": {"description": "Sahanda servis edilir", "displayOrder": 11, "id": 11, "imageUrl": "", "name": "Karışık Menemen", "price": 220},
            "M4oRffMmbyI9SCXGrGmmcCc7I8O4": {"description": "Sahanda servis edilir", "displayOrder": 12, "id": 12, "imageUrl": "", "name": "Omlet", "price": 170},
            "N5pSggNnczJ0TDYHsHnndDd8J9P5": {"description": "Sahanda servis edilir", "displayOrder": 13, "id": 13, "imageUrl": "", "name": "Kaşarlı Omlet", "price": 200},
            "O6qThhOodA1UEEZItIoodEe9K0Q6": {"description": "Sahanda servis edilir", "displayOrder": 14, "id": 14, "imageUrl": "", "name": "Karışık Omlet", "price": 220}
          },
          "name": "Kahvaltılar"
        },
        "category002": {
          "displayOrder": 1,
          "id": 2,
          "isActive": true,
          "menuItem": {
            "P7rUiiPpeyJ1VFVJtJppeFf0L1R7": {"description": "Sour Cream Sos ve Patates Kızartması ile servis edilir", "displayOrder": 2, "id": 1, "imageUrl": "", "name": "Karışık Tost", "price": 190},
            "Q8sVjjQqfzK2WGWKuKqqgGg1M2S8": {"description": "Sour Cream Sos ve Patates Kızartması ile servis edilir", "displayOrder": 3, "id": 2, "imageUrl": "", "name": "Kaşarlı Tost", "price": 190},
            "R9tWkkRrgaL3XHXLvLrrhHh2N3T9": {"description": "Sour Cream Sos ve Patates Kızartması ile servis edilir", "displayOrder": 1, "id": 3, "imageUrl": "", "name": "Üç Peynirli Tost", "price": 220},
            "S0uXllSshbM4YIYMwMssiIi3O4U0": {"description": "Sour Cream Sos ve Patates Kızartması ile servis edilir", "displayOrder": 4, "id": 4, "imageUrl": "", "name": "Beyaz Peynirli Tost", "price": 190},
            "T1vYmmTticN5ZJZNxNttjJj4P5V1": {"description": "Sour Cream Sos ve Patates Kızartması ile servis edilir", "displayOrder": 5, "id": 5, "imageUrl": "", "name": "Forknife Special Tost", "price": 240},
            "product_1769730878141": {"description": "", "displayOrder": 6, "imageUrl": "", "name": "yeni", "price": 1}
          },
          "name": "Tostlarr"
        }
      }
    },
    "menuKey_forknife": {
      "categories": {
        "category001": {
          "displayOrder": 2,
          "id": 1,
          "isActive": true,
          "menuItem": {
            "B3eGuuBbutZ8HSPVhVYgbRr6W7D3": {
              "description": "Ezine Peyniri, Kaşar Peyniri, Yeşil Zeytin, Siyah Zeytin, Bal, Tereyağı, Reçel, Yumurta, Domates, Salatalık",
              "displayOrder": 2,
              "id": 1,
              "imageUrl": "",
              "name": "Mini Kahvaltı",
              "price": 320
            },
            "C4eHvvCcutY9ISPWiWZhcSs7Y8E4": {
              "description": "Menemen, Beyaz Peynir, Zeytin, Salça, Bal, Tereyağı",
              "displayOrder": 3,
              "id": 2,
              "imageUrl": "",
              "name": "Menemen Tabağı",
              "price": 290
            },
            "D5fIwwDdutZ0JTPXjXaidTt8Z9F5": {
              "description": "Börek, Baget Ekmeği, Peynir, Salça, Zeytin, Kaynamış Yumurta, Bal, Kaymak",
              "displayOrder": 1,
              "id": 3,
              "imageUrl": "",
              "name": "Börek Tabağı",
              "price": 270
            },
            "E6gJxxEeutA1KUPYkYbieUu9A0G6": {
              "description": "Ezine Peyniri, Kaşar Peyniri, Çeçil Peyniri, Salça, Zeytin Yağı, Yeşil Zeytin, Siyah Zeytin, Bal, Kaymak, Tereyağı, Reçel, Tahin & Pekmez, Domates, Salatalık, Yeşillik, Çikolata, Kruvasan, Baget Ekmeği, Simit, Yumurta, Pankek, Sosis, Sigara Böreği, Nugget, Patates Kızartması, Meyve Tabağı, Acuka, Peynir Topları, Kapya Lor Kızartma, Meyve Tabağı, Kuy mak, Sınırsız Çay, Türk Kahvesi İkramı",
              "displayOrder": 4,
              "id": 4,
              "imageUrl": "",
              "name": "Serpme Kahvaltı",
              "price": 950
            },
            "F7hKyyFfvtB2LVQZlZcjfVv0B1H7": {"description": "Sahanda servis edilir", "displayOrder": 5, "id": 5, "imageUrl": "", "name": "Mıhlama", "price": 170},
            "G8iLzzGgwuC3MWRAmAfgwWw1C2I8": {"description": "Sahanda servis edilir", "displayOrder": 6, "id": 6, "imageUrl": "", "name": "Sahanda Sucuk", "price": 170},
            "H9jMaaHhxuD4NXSBnBghxXx2D3J9": {"description": "Sahanda servis edilir", "displayOrder": 7, "id": 7, "imageUrl": "", "name": "Sahanda Yumurta", "price": 200},
            "I0kNbbIiyvE5OYTCoChiyYy3E4K0": {"description": "Sahanda servis edilir", "displayOrder": 8, "id": 8, "imageUrl": "", "name": "Sahanda Sucuklu Yumurta", "price": 200},
            "J1lOccJjzwF6PZUDpDijzZz4F5L1": {"description": "Sahanda servis edilir", "displayOrder": 9, "id": 9, "imageUrl": "", "name": "Menemen", "price": 200},
            "K2mPddKkaxG7QAVEqEkkaAa5G6M2": {"description": "Sahanda servis edilir", "displayOrder": 10, "id": 10, "imageUrl": "", "name": "Kaşarlı Menemen", "price": 230},
            "L3nQeeLlayH8RBWFqFllbBb6H7N3": {"description": "Sahanda servis edilir", "displayOrder": 11, "id": 11, "imageUrl": "", "name": "Karışık Menemen", "price": 220},
            "M4oRffMmbyI9SCXGrGmmcCc7I8O4": {"description": "Sahanda servis edilir", "displayOrder": 12, "id": 12, "imageUrl": "", "name": "Omlet", "price": 170},
            "N5pSggNnczJ0TDYHsHnndDd8J9P5": {"description": "Sahanda servis edilir", "displayOrder": 13, "id": 13, "imageUrl": "", "name": "Kaşarlı Omlet", "price": 200},
            "O6qThhOodA1UEEZItIoodEe9K0Q6": {"description": "Sahanda servis edilir", "displayOrder": 14, "id": 14, "imageUrl": "", "name": "Karışık Omlet", "price": 220}
          },
          "name": "Kahvaltılar"
        },
        "category002": {
          "displayOrder": 1,
          "id": 2,
          "isActive": true,
          "menuItem": {
            "P7rUiiPpeyJ1VFVJtJppeFf0L1R7": {"description": "Sour Cream Sos ve Patates Kızartması ile servis edilirrr", "displayOrder": 1, "id": 1, "imageUrl": "", "name": "Karışık Tostt", "price": 190},
            "Q8sVjjQqfzK2WGWKuKqqgGg1M2S8": {"description": "Sour Cream Sos ve Patates Kızartması ile servis edilir", "displayOrder": 3, "id": 2, "imageUrl": "", "name": "Kaşarlı Tost", "price": 190},
            "R9tWkkRrgaL3XHXLvLrrhHh2N3T9": {"description": "Sour Cream Sos ve Patates Kızartması ile servis edilir", "displayOrder": 2, "id": 3, "imageUrl": "", "name": "Üç Peynirli Tost", "price": 222.01},
            "S0uXllSshbM4YIYMwMssiIi3O4U0": {"description": "Sour Cream Sos ve Patates Kızartması ile servis edilir", "displayOrder": 4, "id": 4, "imageUrl": "", "name": "Beyaz Peynirli Tost", "price": 190},
            "T1vYmmTticN5ZJZNxNttjJj4P5V1": {"description": "Sour Cream Sos ve Patates Kızartması ile servis edilir", "displayOrder": 5, "id": 5, "imageUrl": "", "name": "Forknife Special Tost", "price": 240},
            "product_1769730878141": {"description": "", "displayOrder": 6, "imageUrl": "", "name": "yeni", "price": 1}
          },
          "name": "Tostlarr_aforkk_uat"
        },
        "category003": {
          "displayOrder": 3,
          "id": 3,
          "menuItem": {
            "U2xNaaAajdA2BAFXhHnnaEe1O1X2": {"description": "Bonfile Tavuk, Mantar, Rosto, Sarımsak, Pesto Sos, Krema ve Parmesan ile servis edilir", "id": 1, "imageUrl": "", "name": "Fettucine Alfredo", "positionInList": 1, "price": 250},
            "V3yObbBbkfB3CBGYiIoodFf2P2Y3": {"description": "Bonfile Dana Eti, Mantar, Rosto Sarımsak, Pesto Sos, Krema, ve Parmesan ile servis edilir", "id": 2, "imageUrl": "", "name": "Beef Alfredo", "positionInList": 2, "price": 280},
            "W4zPccCclgC4DCHZjJppeGg3Q3Z4": {"description": "Acılı Arabiata Sos, Zeytin, Pesto Sos and Parmesan ile servis edilir", "id": 3, "imageUrl": "", "name": "Penne Arabiata", "positionInList": 3, "price": 200},
            "X5aQddDdmhD5EDIAkKqqhHh4R4A5": {"description": "Bolognese Sos, Domates Sos and Parmesan ile servis edilir", "id": 4, "imageUrl": "", "name": "Spaghetti Bolognese", "positionInList": 4, "price": 230}
          },
          "name": "MAKARNALAR"
        },
        "category004": {
          "displayOrder": 4,
          "id": 4,
          "menuItem": {
            "A8dTggGgpbG8HGLDnNttkKk7U7D8": {"description": "", "id": 2, "imageUrl": "", "name": "Patatesli Gözleme", "positionInList": 2, "price": 240},
            "B9eUhhHhqcH9IHMEoOuulLl8V8E9": {"description": "", "id": 3, "imageUrl": "", "name": "Kaşarlı Sucuklu Gözleme", "positionInList": 3, "price": 240},
            "Z7cSffFfoaF7GFKCmMssjJj6T6C7": {"description": "", "id": 1, "imageUrl": "", "name": "Kaşarlı Peynirli Gözleme", "positionInList": 1, "price": 240}
          },
          "name": "GÖZLEMELER"
        },
        "category005": {
          "displayOrder": 5,
          "id": 5,
          "menuItem": {
            "C1fViiIiodI1JKGEnNvvjJj9W9F1": {"description": "6 Adet Sigara Böreği ve Patates Kızartması ile servis edilir", "displayOrder": 4, "id": 1, "imageUrl": "", "name": "Sigara Böreği", "positionInList": 1, "price": 180},
            "D2gWjjJjpeJ2KLHFoOwwkKk0X0G2": {"description": "", "displayOrder": 3, "id": 2, "imageUrl": "", "name": "Patates Kızartması", "positionInList": 2, "price": 160},
            "E3hXkkKkqfK3LMIGpPxxlLl1Y1H3": {"description": "6 Adet El Yapımı Çıtır Tavuk ve Patates Kızartması ile servis edilir", "displayOrder": 5, "id": 3, "imageUrl": "", "name": "Çıtır Tavuk", "positionInList": 3, "price": 240},
            "F4iYllLlrhL4MNJHqQyymMm2Z2I4": {"description": "2 Adet Çıtır Tavuk, 2 Adet Sosis, 2 Adet Sigara Böreği, 2 Adet Nugget and Patates Kızartmasıyla servis edilir", "displayOrder": 2, "id": 4, "imageUrl": "", "name": "Aperatif Tabağı", "positionInList": 4, "price": 270},
            "G5jZmmMmsiM5NOKIrRzznNn3A3J5": {"description": "6 Adet Sosis ve Patates Kızartması ile servis edilir", "displayOrder": 1, "id": 5, "imageUrl": "", "name": "Sosis Tabağı", "positionInList": 5, "price": 170}
          },
          "name": "aperatifler"
        },
        "category006": {
          "displayOrder": 6,
          "id": 6,
          "menuItem": {
            "-OiyGPptMIDHGDTxDBAd": {"description": "El açması hamur üzerinde domates sos, mozeralla peyniri,Dana sucuk,cemensiz pastırma,dana füme et,mantar ve permesan peyniri ile servis edilir", "imageUrl": "", "name": "Süpermixxo pizza", "positionInList": 1, "price": 390},
            "H1kAaaAamqA1OPLJtTpppPp4A4K1": {"description": "El Açması Hamur, Üzerinde Özel Domates Sos, Mozarella Peyniri, Bonfile Dana Parçaları, Tütsülenmiş Dana Kaburga Parçaları, Kurutulmuş Domates ve Parmesan ile servis edilir", "id": 1, "imageUrl": "", "name": "Bisteca Pizza", "positionInList": 2, "price": 340},
            "I2lBbbBbnrB2PQMKuUqqqQq5B5L2": {"description": "El Açması Hamur, Üzerinde Özel Domates Sos, Mozarella Peyniri, Dana Sucuk, Kırmızı Biber, Yeşil Biber, Mantar, Mısır, Dilim Zeytin and Parmesan ile servis edilir", "id": 2, "imageUrl": "", "name": "Mixxo Pizza", "positionInList": 3, "price": 330},
            "J3mCccCcosC3QRNLvVrrrRr6C6M3": {"description": "El Açması Hamur, Üzerinde Özel Domates Sos, Mozarella Peyniri and Parmesan ile servis edilir", "id": 3, "imageUrl": "", "name": "Margaritta Pizza", "positionInList": 4, "price": 250},
            "K4nDddDdpqD4RSOMwWsssSs7D7N4": {"description": "El Açması Hamur, Üzerinde Özel Domates Sos, Mozarella Peyniri, Dana Sucuk and Parmesan ile servis edilir", "id": 4, "imageUrl": "", "name": "Pepperoni Pizza", "positionInList": 5, "price": 330},
            "L5oEeeEerqE5STPNxXtttTt8E8O5": {"description": "El Açması Hamur, Üzerinde Özel Domates Sos, Mozarella Peyniri, Bonfile Tavuk Parçaları, Karamelize Soğan, Köz Kırmızı Biber, BBQ and Parmesan ile servis edilir", "id": 5, "imageUrl": "", "name": "Chicken BBQ Pizza", "positionInList": 6, "price": 300},
            "M6pFffFfstF6TQUOyYuuuUu9F9P6": {"description": "El Açması Hamur, Üzerinde Özel Domates Sos, Mozarella Peyniri, Kabak, Patlıcan, Köz Kırmızı Biber, Ricotta Peyniri, Pesto Sos and Parmesan ile servis edilir", "id": 6, "imageUrl": "", "name": "Sebzeli Pizza", "positionInList": 7, "price": 230}
          },
          "name": "pizzalar"
        },
        "category007": {
          "displayOrder": 7,
          "id": 7,
          "menuItem": {
            "A10bBurger010": {"description": "El Yapımı Brioche Ekmeği, Panelenmiş Bütün Tavuk, El Yapımı Binada Sos, Marul, Domates, Turşu ve Patates Kızartması ile servis edilir", "id": 10, "imageUrl": "", "name": "Öğrenci Tavuk Burger", "positionInList": 10, "price": 220},
            "A11bBurger011": {"description": "El Yapımı Brioche Ekmeği, Köfte, El Yapımı Binada Sos, Marul, Domates, Turşu, Sour Cream Sos ve Patates Kızartması ile servis edilir", "id": 1, "imageUrl": "", "name": "Klasik Burger", "positionInList": 1, "price": 275},
            "A12bBurger012": {"description": "El Yapımı Brioche Ekmeği, Köfte, El Yapımı Binada Sos, Cheddar Peyniri, Marul, Domates, Turşu, Sour Cream Sos ve Patates Kızartması ile servis edilir", "id": 2, "imageUrl": "", "name": "Cheese Burger", "positionInList": 2, "price": 285},
            "A13bBurger013": {"description": "El Yapımı Brioche Ekmeği, Köfte, El Yapımı Binada Sos, Cheddar Peyniri, Ağır Ateşte Pişmiş Tiftik Dana Kaburga, Marul, Domates, Turşu, Sour Cream Sos ve Patates Kızartması ile servis edilir", "id": 3, "imageUrl": "", "name": "Tiftik Burger", "positionInList": 3, "price": 390},
            "A1bBurger001": {"description": "El Yapımı Brioche Ekmeği, Köfte, El Yapımı Binada Sos, Cheddar Peyniri, Karamelize Soğan, Marul, Domates, Turşu, Sour Cream Sos ve Patates Kızartması ile servis edilir", "id": 4, "imageUrl": "", "name": "Karamelize Burger", "positionInList": 4, "price": 310},
            "A2bBurger002": {"description": "El Yapımı Brioche Ekmeği, Köfte, El Yapımı Binada Sos, Cheddar Peyniri, Karamelize Soğan, Tütsülenmiş Kaburga Eti Parçaları, Marul, Domates, Turşu, Sour Cream Sos ve Patates Kızartması ile servis edilir", "id": 5, "imageUrl": "", "name": "Smoke Burger", "positionInList": 5, "price": 350},
            "A3bBurger003": {"description": "El Yapımı Brioche Ekmeği, Köfte, El Yapımı Binada Sos, Cheddar Peyniri, Karamelize Soğan, Tütsülenmiş Kaburga Eti Parçaları, Köz Biber, Marul, Domates, Turşu, Sour Cream Sos ve Patates Kızartması ile servis edilir", "id": 6, "imageUrl": "", "name": "Forknife Special Burger", "positionInList": 6, "price": 350},
            "A4bBurger004": {"description": "El Yapımı Brioche Ekmeği, Double Köfte, El Yapımı Binada Sos, Cheddar Peyniri, Marul, Domates, Turşu, Sour Cream Sos ve Patates Kızartması ile servis edilir", "id": 7, "imageUrl": "", "name": "Double Burger", "positionInList": 7, "price": 390},
            "A5bBurger005": {"description": "El Yapımı Brioche Ekmeği, Çıtır Tavuk Parçaları, El Yapımı Binada Sos, Marul, Domates, Turşu, Sour Cream Sos ve Patates ile servis edilir", "id": 8, "imageUrl": "", "name": "Chicken Burger", "positionInList": 8, "price": 250},
            "A6bBurger006": {"description": "El Yapımı Brioche Ekmeği, Köfte, El Yapımı Binada Sos, Mantar Sos, Marul, Domates, Turşu, Sour Cream Sos ve Patates Kızartması ile servis edilir", "id": 9, "imageUrl": "", "name": "Mantar Soslu Burger", "positionInList": 9, "price": 300},
            "A7bBurger007": {"description": "120 gram sana burger, kibrit patates, cheddar peyniri, kaşar peyniri, marul, domates, yoğurt sos ve patates ile servis edilir", "id": 13, "imageUrl": "", "name": "Talaş Burger", "positionInList": 13, "price": 290}
          },
          "name": "BURGERLER"
        },
        "category011": {
          "displayOrder": 11,
          "id": 11,
          "menuItem": {
            "T1aTako001": {"description": "Tavuk, soslar ve sebzelerle hazırlanmış lezzetli taco, özel baharat karışımıyla servis edilir", "id": 1, "imageUrl": "", "name": "Tavuklu Tako", "positionInList": 1, "price": 280},
            "T2aTako002": {"description": "Ağır ateşte pişmiş tiftik dana etiyle hazırlanmış taco, özel sos and taze sebzelerle servis edilir", "id": 2, "imageUrl": "", "name": "Tiftik Et Tako", "positionInList": 2, "price": 320}
          },
          "name": "TAKOLAR"
        }
      }
    },
    "menuKey_nfc17": {
      "categories": {
        "-Oe3suHw4Urze2odYhvW": {
          "createdAt": "2025-11-15T00:21:43.022Z",
          "description": "",
          "displayOrder": 1,
          "isActive": true,
          "menuId": "menuKey_nfc17",
          "menuItem": {
            "-Oe3tuyYOqJlliFmJsll": {
              "available": true,
              "createdAt": "2025-11-15T00:26:07.956Z",
              "description": "NFC tavuk burger, el yapımı ranch sos, turşu, cheddar peynir, patates kızartması, seçilen 2 sos ile",
              "displayOrder": 1,
              "id": 1923019790,
              "imageUrl": "",
              "isActive": true,
              "name": "Golden Rancher Burger Menü",
              "price": 201,
              "updatedAt": "2025-12-02T17:24:13.116Z"
            }
          },
          "name": "NFChicken Burger Menüler",
          "updatedAt": "2025-12-01T21:52:44.496Z"
        }
      }
    }
  };
}
