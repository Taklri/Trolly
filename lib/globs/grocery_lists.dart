class GroceryListData {
  static List<Map<String, dynamic>> lists = [];
  static int nextId = 1;

  static void reset() {
    lists = [];
    nextId = 1;
  }
}
