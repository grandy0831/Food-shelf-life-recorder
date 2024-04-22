import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'study_space.dart'; 

class FavoritesModel extends ChangeNotifier {
  final List<String> _favoriteBuildings = [];
  final List<String> _favoriteRooms = [];
  Map<String, List<Room>> _roomData = {}; 

  FavoritesModel() {
    _loadFavorites();
  }

  List<String> get favoriteBuildings => List.unmodifiable(_favoriteBuildings);
  List<String> get favoriteRooms => _favoriteRooms;
  Map<String, List<Room>> get roomData => _roomData; 

  bool isRoomFavorite(String roomId) {
    return _favoriteRooms.contains(roomId);
  }

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

  void toggleRoomFavorite(String roomId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favoriteRooms = prefs.getStringList('favoriteRooms') ?? [];
    if (favoriteRooms.contains(roomId)) {
      favoriteRooms.remove(roomId);
    } else {
      favoriteRooms.add(roomId);
    }
    prefs.setStringList('favoriteRooms', favoriteRooms);
    _loadFavorites(); 
  }

  void removeRoom(String roomId) async {
    _favoriteRooms.remove(roomId);
    notifyListeners();
    _updateRoomData();
    await _saveFavorites('favoriteRooms', _favoriteRooms); 
  }


  void clearFavorites() async {
    _favoriteBuildings.clear();
    _favoriteRooms.clear();
    _roomData.clear(); 
    notifyListeners();
  }

  Future<void> _loadFavorites() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _favoriteBuildings.clear();
    _favoriteRooms.clear();
    _favoriteBuildings.addAll(prefs.getStringList('favoriteBuildings') ?? []);
    _favoriteRooms.addAll(prefs.getStringList('favoriteRooms') ?? []);
    _updateRoomData(); // Move the update call here
    notifyListeners();
  }

  Future<void> _saveFavorites(String key, List<String> data) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(key, data);
  }

  void _updateRoomData() {
    _roomData.clear();
    for (var building in _favoriteBuildings) {
      if (_roomData.containsKey(building)) {
        _roomData[building] = _roomData[building]!
            .where((room) => _favoriteRooms.contains(room.roomId))
            .toList();
      }
    }
    notifyListeners();
  }

  void updateFavorites() {
    _loadFavorites(); 
  }
}
