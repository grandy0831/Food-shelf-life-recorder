import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
        backgroundColor: Colors.blue,
      ),
      body: ListView(
        children: ListTile.divideTiles(
          context: context,
          tiles: [
            ListTile(
              title: Text("账户"),
              leading: Icon(Icons.person),
              onTap: () {
                // 导航到账户设置页面
              },
            ),
            SwitchListTile(
              title: Text("推送通知"),
              value: true,
              onChanged: (bool value) {
                // 更新推送通知设置
              },
              secondary: Icon(Icons.notifications_active),
            ),
            ListTile(
              title: Text("清除缓存"),
              leading: Icon(Icons.delete_outline),
              onTap: () {
                // 清除缓存
              },
            ),
            ListTile(
              title: Text("帮助与反馈"),
              leading: Icon(Icons.help_outline),
              onTap: () {
                // 导航到帮助与反馈页面
              },
            ),
          ],
        ).toList(),
      ),
    );
  }
}