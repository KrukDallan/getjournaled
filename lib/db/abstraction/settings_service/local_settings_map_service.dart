import 'package:flutter/material.dart';
import 'package:getjournaled/db/abstraction/settings_service/settings_map_service.dart';
import 'package:getjournaled/hive/hive_unique_id.dart';
import 'package:getjournaled/hive/settings/hive_settings.dart';
import 'package:getjournaled/main.dart';
import 'package:getjournaled/settings/settings_object.dart';
import 'package:hive_flutter/hive_flutter.dart';

class LocalSettingsMapService extends SettingsService{

  Map<int, SettingsObject> _cacheMap = {};
  late Box _boxSettings;
  int _uniqueId = 0;


   @override
  Future<SettingsObject?> get(int id) async {
      return _cacheMap[id];
  }

  @override
  bool getTheme(){
    return _cacheMap.entries.first.value.getDarkMode();
  }

  @override
  int getUniqueId() {
    return _uniqueId;
  }

  @override
  Future<void> open() async {
    Hive.registerAdapter(HiveSettingsAdapter());
    _boxSettings = await Hive.openBox<HiveSettings>('HiveSettings001');
    loadBoxSettings();
    loadCacheMap();
  }

  @override
  Future<bool> remove(int id) async {
    if(_cacheMap.keys.contains(id)){
      _cacheMap.remove(id);
      _boxSettings.delete(id);
      streamSettingsController.add(_cacheMap);
      return true;
    } else{
      return false;
    }
  }


  @override
  Future<bool> update(SettingsObject settingsObject) async {
    // check presence
    if (_cacheMap.keys.contains(settingsObject.getId())) {
      _cacheMap.addAll({settingsObject.getId(): settingsObject});
      streamSettingsController.add(_cacheMap);
      // update in hive box
      HiveSettings hs = HiveSettings(
        id: settingsObject.getId(),
        autosave: settingsObject.getAutoSave(),
        darkmode: settingsObject.getDarkMode(),
      );
      _boxSettings.put(settingsObject.getId(), hs);
      return true;
    } 
    return false;
  }

  //
  // utility functions
  //        |
  //        ∨
  void loadBoxSettings(){
    if(_boxSettings.isEmpty){
      HiveSettings hiveSettings = HiveSettings(
        id: 0, 
        autosave: false,
        darkmode: true,
        );
        _boxSettings.add(hiveSettings);
    }
  }

  void loadCacheMap(){
    if(_boxSettings.isNotEmpty){
      for(var k in _boxSettings.keys) {
        HiveSettings hs = _boxSettings.get(k);
        SettingsObject settingsObject = SettingsObject(
          id: hs.id, 
          autoSave: hs.autosave,
          darkMode: hs.darkmode,
          
          );
          _cacheMap.addAll({hs.id : settingsObject});
      }
      
    }
  }

}