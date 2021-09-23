
enum ItemType {
  food,
  drink
}

class ItemModel {
  String nama;
  int harga;
  ItemType type;

  bool get isfood => type == ItemType.food;
  bool get isdrink => type == ItemType.drink;

  ItemModel(
    {
      this.nama,
      this.harga = 0,
      this.type
    }
  );
}

List<ItemModel> mylistitems = [
  ItemModel(
    nama: 'Pizza',
    harga: 120000,
    type: ItemType.food
  ),
  ItemModel(
    nama: 'Pancake',
    harga: 100000,
    type: ItemType.food
  ),
  ItemModel(
    nama: 'Sosis',
    harga: 10000,
    type: ItemType.food
  ),
  ItemModel(
    nama: 'Dagin Ayam',
    harga: 200000,
    type: ItemType.food
  ),
  ItemModel(
    nama: 'SausTiram',
    harga: 100200,
    type: ItemType.food
  ),
  ItemModel(
    nama: 'Cambakut',
    harga: 120000,
    type: ItemType.food
  ),
  ItemModel(
    nama: 'Burger',
    harga: 100000,
    type: ItemType.food
  ),
  ItemModel(
    nama: 'Sandwich',
    harga: 180000,
    type: ItemType.food
  ),
  ItemModel(
    nama: 'Ayam Goreng',
    harga: 200000,
    type: ItemType.food
  ),
  ItemModel(
    nama: 'Lalapan',
    harga: 8000,
    type: ItemType.food
  ),
  ItemModel(
    nama: 'Es Teh',
    harga: 1000,
    type: ItemType.drink
  ),
  ItemModel(
    nama: 'Es Jeruk',
    harga: 2000,
    type: ItemType.drink
  ),
  ItemModel(
    nama: 'Cocacola',
    harga: 10000,
    type: ItemType.drink
  ),
  ItemModel(
    nama: 'Es Kelapa',
    harga: 10000,
    type: ItemType.drink
  ),
];