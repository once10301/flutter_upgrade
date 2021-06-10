package com.once10301.flutter_upgrade;

import android.content.ActivityNotFoundException;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Build;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.core.content.FileProvider;

import java.io.File;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/** FlutterUpgradePlugin */
public class FlutterUpgradePlugin implements FlutterPlugin, MethodCallHandler {
  private Context context;
  private MethodChannel channel;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
    context = binding.getApplicationContext();
    channel = new MethodChannel(binding.getBinaryMessenger(), "flutter_upgrade");
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (call.method.equals("getApkDownloadPath")) {
      result.success(context.getExternalFilesDir("").getAbsolutePath());
    } else if (call.method.equals("install")) {
      String path = call.arguments.toString();
      File file = new File(path);
      if (!file.exists()) {
        return;
      }
      Intent intent = new Intent(Intent.ACTION_VIEW);
      intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
        Uri uri = FileProvider.getUriForFile(context, context.getPackageName() + ".fileprovider", file);
        intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
        intent.setDataAndType(uri, "application/vnd.android.package-archive");
      } else {
        intent.setDataAndType(Uri.fromFile(file), "application/vnd.android.package-archive");
      }
      context.startActivity(intent);
    } else if (call.method.equals("getInstallMarket")) {
      List<String> packages = (List<String>) call.arguments;
      List<String> packageList = new ArrayList<>();
      for (String name : packages) {
        if (isPackageExist(name)) {
          packageList.add(name);
        }
      }
      result.success(packageList);
    } else if (call.method.equals("toMarket")) {
      Map<String, String> map = (Map<String, String>) call.arguments;
      String marketPackageName = map.get("marketPackageName");
      String marketClassName = map.get("marketClassName");
      try {
        PackageInfo packageInfo = context.getPackageManager().getPackageInfo(context.getPackageName(), 0);
        Uri uri = Uri.parse("market://details?id=" + packageInfo.packageName);
        boolean nameEmpty = marketPackageName == null || marketPackageName.isEmpty();
        boolean classEmpty = marketClassName == null || marketClassName.isEmpty();
        Intent intent = new Intent(Intent.ACTION_VIEW, uri);
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        if (!nameEmpty && !classEmpty) {
          intent.setClassName(marketPackageName, marketClassName);
        }
        context.startActivity(intent);
      } catch (PackageManager.NameNotFoundException e) {
        Toast.makeText(context, "包名未找到！", Toast.LENGTH_SHORT).show();
      } catch (ActivityNotFoundException e) {
        Toast.makeText(context, "您的手机没有安装应用商店(" + marketPackageName + ")", Toast.LENGTH_SHORT).show();
      }
    } else {
      result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }

  private boolean isPackageExist(String name) {
    if (name == null || name.isEmpty())
      return false;
    try {
      context.getPackageManager().getApplicationInfo(name, PackageManager.GET_UNINSTALLED_PACKAGES);
      return true;
    } catch (PackageManager.NameNotFoundException e) {
      return false;
    }
  }
}
