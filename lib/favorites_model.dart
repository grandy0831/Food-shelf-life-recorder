import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'study_space.dart'; // 导入 Room 类

class FavoritesModel extends ChangeNotifier {
  final List<String> _favoriteBuildings = [];
  final List<String> _favoriteRooms = [];
  Map<String, List<Room>> _roomData = {}; // 新添加的 roomData 属性

  FavoritesModel() {
    _loadFavorites();
  }

  List<String> get favoriteBuildings => List.unmodifiable(_favoriteBuildings);
  List<String> get favoriteRooms => _favoriteRooms;
  Map<String, List<Room>> get roomData => _roomData; // 新添加的 roomData 属性的 getter

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

  void toggleRoomFavorite(String roomId) {
    if (_favoriteRooms.contains(roomId)) {
      _favoriteRooms.remove(roomId);
    } else {
      _favoriteRooms.add(roomId);
    }
    notifyListeners();
  }

  void removeRoom(String roomId) {
    _favoriteRooms.remove(roomId);
    notifyListeners();
  }

  void clearFavorites() {
    _favoriteBuildings.clear();
    _favoriteRooms.clear();
    _roomData.clear(); // 在清除收藏时也清除房间数据
    notifyListeners();
  }

  Future<void> _loadFavorites() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _favoriteBuildings.clear();
    _favoriteRooms.clear();
    _favoriteBuildings.addAll(prefs.getStringList('favoriteBuildings') ?? []);
    _favoriteRooms.addAll(prefs.getStringList('favoriteRooms') ?? []);
    notifyListeners();
  }

  Future<void> _saveFavorites(String key, List<String> data) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(key, data);
  }
}
