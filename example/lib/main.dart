
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter_upgrade/flutter_upgrade.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('App 升级测试'),
        ),
        body: Stack(
          children: <Widget>[
            Center(
              child: Column(
                children: <Widget>[
                  Home(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String _installMarkets = '';

  @override
  void initState() {
    _checkAppUpgrade();
    _getInstallMarket();
    super.initState();
  }

  _checkAppUpgrade() {
    FlutterUpgrade.appUpgrade(
      context,
      _checkAppInfo(),
      iosAppId: 'id88888888',
    );
  }

  Future<AppUpgradeInfo> _checkAppInfo() async {
    //这里一般访问网络接口，将返回的数据解析成如下格式
    return Future.delayed(Duration(seconds: 1), () {
      return AppUpgradeInfo(
        title: '新版本V1.1.1',
        content: '1、支持立体声蓝牙耳机，同时改善配对性能\n2、提供屏幕虚拟键盘\n3、更简洁更流畅，使用起来更快\n4、修复一些软件在使用时自动退出bug\n5、新增加了分类查看功能',
        force: false,
      );
    });
  }

  _getInstallMarket() async {
    List<String> marketList = await FlutterUpgrade.getInstallMarket();
    marketList.forEach((f) {
      _installMarkets += '$f,';
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text('安装的应用商店:$_installMarkets'),
      ],
    );
  }
}
