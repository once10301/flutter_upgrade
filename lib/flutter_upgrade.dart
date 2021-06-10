
import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_market.dart';

class FlutterUpgrade {
  static const MethodChannel _channel = const MethodChannel('flutter_upgrade');

  /// 获取apk下载路径
  static Future<String> get apkDownloadPath async {
    return await _channel.invokeMethod('getApkDownloadPath');
  }

  /// Android 安装app
  static installAppForAndroid(String path) async {
    return await _channel.invokeMethod('install', path);
  }

  /// 跳转到ios app store
  static toAppStore(String? id) async {
    return await _channel.invokeMethod('toAppStore', id);
  }

  /// 获取android手机上安装的应用商店
  static getInstallMarket({List<String>? marketPackageNames}) async {
    List<String> packageNameList = AppMarket.buildInPackageNameList;
    if (marketPackageNames != null && marketPackageNames.length > 0) {
      packageNameList.addAll(marketPackageNames);
    }
    var result = await _channel.invokeMethod('getInstallMarket', packageNameList);
    List<String> resultList = (result as List).map((f) {
      return '$f';
    }).toList();
    return resultList;
  }

  /// 跳转到应用商店
  static toMarket({AppMarketInfo? appMarketInfo}) async {
    var map = {'marketPackageName': appMarketInfo != null ? appMarketInfo.packageName : '', 'marketClassName': appMarketInfo != null ? appMarketInfo.className : ''};
    return await _channel.invokeMethod('toMarket', map);
  }

  static appUpgrade(
      BuildContext context,
      Future<AppUpgradeInfo> future, {
        String? iosAppId,
        AppMarketInfo? appMarketInfo,
      }) {
    future.then((AppUpgradeInfo? appUpgradeInfo) {
      if (appUpgradeInfo != null) {
        _showUpgradeDialog(context, appUpgradeInfo.title, appUpgradeInfo.content, apkDownloadUrl: appUpgradeInfo.apkDownloadUrl, force: appUpgradeInfo.force, iosAppId: iosAppId, appMarketInfo: appMarketInfo);
      }
    }).catchError((onError) {
      print('$onError');
    });
  }

  static _showUpgradeDialog(
      BuildContext context,
      String title,
      String content, {
        String? apkDownloadUrl,
        bool force = false,
        String? iosAppId,
        AppMarketInfo? appMarketInfo,
      }) {
    double _downloadProgress = 0.0;
    StateSetter? setState;
    if (Platform.isIOS) {
      List<Widget> actions = [];
      if (!force) {
        actions.add(CupertinoDialogAction(
          child: Text('取消', style: TextStyle(color: Colors.black, fontSize: 14)),
          onPressed: () => Navigator.of(context).pop(),
        ));
      }
      actions.add(CupertinoDialogAction(
        child: Text('立即下载', style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 14)),
        onPressed: () => toAppStore(iosAppId),
      ));
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: title.isEmpty ? null : Text(title, style: TextStyle(color: Colors.black, fontSize: 18)),
          content: Text(content, style: TextStyle(color: Colors.black, fontSize: 14)),
          actions: actions,
        ),
      );
    } else {
      List<Widget> actions = [];
      if (!force) {
        actions.add(FlatButton(
          child: Text('取消', style: TextStyle(color: Colors.black, fontSize: 14)),
          onPressed: () => Navigator.of(context).pop(),
        ));
      }
      actions.add(FlatButton(
        child: Text('立即下载', style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 14)),
        onPressed: () async {
          if (apkDownloadUrl == null || apkDownloadUrl.isEmpty) {
            toMarket(appMarketInfo: appMarketInfo);
            return;
          }
          String path = await apkDownloadPath;
          path += '/temp.apk';
          await Dio().download(apkDownloadUrl, path, onReceiveProgress: (int count, int total) {
            if (total == -1) {
              _downloadProgress = 0.01;
            } else {
              _downloadProgress = count / total.toDouble();
            }
            setState!(() {});
            if (_downloadProgress == 1) {
              Navigator.pop(context);
              installAppForAndroid(path);
            }
          });
        },
      ));
      showDialog(
        context: context,
        builder: (context) => WillPopScope(
          onWillPop: () async => false,
          child: StatefulBuilder(
            builder: (context, state) {
              setState = state;
              return AlertDialog(
                title: title.isEmpty ? null : Text(_downloadProgress > 0 ? '正在更新' : title, style: TextStyle(color: Colors.black, fontSize: 18)),
                content: _downloadProgress > 0
                    ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${(_downloadProgress * 100).toStringAsFixed(0)}%', style: TextStyle(color: Colors.black, fontSize: 14)),
                    SizedBox(height: 7),
                    LinearProgressIndicator(value: _downloadProgress, backgroundColor: Color(0xFFF5F8FA)),
                  ],
                )
                    : Text(content, style: TextStyle(color: Colors.black, fontSize: 14)),
                actions: _downloadProgress > 0 ? [] : actions,
              );
            },
          ),
        ),
      );
    }
  }
}

class AppInfo {
  AppInfo({this.versionName = '', this.versionCode = '', this.packageName = ''});

  String versionName;
  String versionCode;
  String packageName;
}

class AppUpgradeInfo {
  AppUpgradeInfo({required this.title, required this.content, this.apkDownloadUrl = '', this.force = false});

  final String title;
  final String content;
  final String apkDownloadUrl;
  final bool force;
}
