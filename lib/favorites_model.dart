import 'package:flutter/material.dart';


class FavoritesModel extends ChangeNotifier {
  final List<String> _favoriteBuildings = [];
  final List<String> _favoriteRooms = [];

  List<String> get favoriteBuildings => List.unmodifiable(_favoriteBuildings);
  List<String> get favoriteRooms => List.unmodifiable(_favoriteRooms);


  void addBuilding(String building) {
    if (!_favoriteBuildings.contains(building)) {
      _favoriteBuildings.add(building);
      notifyListeners(); 
    }
  }

  void removeBuilding(String building) {
    if (_favoriteBuildings.remove(building)) {
      notifyListeners(); 
    }
  }

  void addRoom(String room) {
    if (!_favoriteRooms.contains(room)) {
      _favoriteRooms.add(room);
      notifyListeners(); 
    }
  }

  void removeRoom(String room) {
    if (_favoriteRooms.remove(room)) {
      notifyListeners(); 
    }
  }

}