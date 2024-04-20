import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesModel extends ChangeNotifier {
  final List<String> _favoriteBuildings = [];
  final List<String> _favoriteRooms = [];

  FavoritesModel() {
    _loadFavorites();
  }

  List<String> get favoriteBuildings => List.unmodifiable(_favoriteBuildings);
  List<String> get favoriteRooms => List.unmodifiable(_favoriteRooms);

  void addBuilding(String building) {
    if (!_favoriteBuildings.contains(building)) {
      _favoriteBuildings.add(building);
      notifyListeners();
      _saveFavorites('favoriteBuildings', _favoriteBuildings);
    }
  }

  void removeBuilding(String building) {
    if (_favoriteBuildings.remove(building)) {
      notifyListeners();
      _saveFavorites('favoriteBuildings', _favoriteBuildings);
    }
  }

  void addRoom(String room) {
    if (!_favoriteRooms.contains(room)) {
      _favoriteRooms.add(room);
      notifyListeners();
      _saveFavorites('favoriteRooms', _favoriteRooms);
    }
  }

  void removeRoom(String room) {
    if (_favoriteRooms.remove(room)) {
      notifyListeners();
      _saveFavorites('favoriteRooms', _favoriteRooms);
    }
  }

  Future<void> _loadFavorites() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _favoriteBuildings.addAll(prefs.getStringList('favoriteBuildings') ?? []);
    _favoriteRooms.addAll(prefs.getStringList('favoriteRooms') ?? []);
    notifyListeners();
  }

  Future<void> _saveFavorites(String key, List<String> data) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(key, data);
  }
}
