import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';
import 'utilities/color_scheme.dart';
import 'utilities/text_theme.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // backgroundColor: AppColor.primary,
        appBar: AppBar(
            // backgroundColor: AppColor.primary,
            title: Text("Settings",
                style: defaultText.copyWith(
                    fontSize: 18, fontWeight: FontWeight.bold))),
        body: Column(
          children: [
            const CustomDivider(),
            ListTile(
                leading: const Text("Dark Mode", style: defaultText),
                trailing: Switch(
                    value: true,
                    onChanged: (value) {},
                    activeColor: AppColor.stroke)),
            const Divider(color: AppColor.stroke),
            ListTile(
                leading: const Text("View", style: defaultText),
                trailing: Switch(
                    value: false,
                    onChanged: (value) {},
                    activeColor: AppColor.stroke)),
            const CustomDivider(),
            GestureDetector(
                onTap: () {},
                child: const ListTile(
                    leading: Text("성경 버전 선택", style: defaultText))),
            const Divider(color: AppColor.stroke),
            GestureDetector(
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return const FontSettingDialog();
                      });
                },
                child: const ListTile(
                    leading: Text("폰트 사이즈", style: defaultText))),
            const CustomDivider(),
          ],
        ));
  }
}

class CustomDivider extends StatelessWidget {
  const CustomDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Container(width: width, height: 28, color: AppColor.stroke);
  }
}

class FontSetting extends StatelessWidget {
  const FontSetting({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingProvider>(context);
    double tempSize = settings.fontSize;
    return Container(
        height: 354,
        // color: AppColor.secondary,
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text("FontSize",
                style: defaultText.copyWith(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 22),
            Container(
                padding: const EdgeInsets.only(top: 16, bottom: 16),
                // color: AppColor.primary,
                child: const Row(
                  children: [
                    SizedBox(width: 32),
                    Text("폰트 사이즈 조절", style: defaultText),
                  ],
                )),
            Container(
                // color: AppColor.primary,
                child: Row(children: [
              const SizedBox(width: 32),
              Column(children: [
                Slider(
                    value: settings.fontSize,
                    onChanged: (value) => settings.setFontSize(value),
                    min: 10,
                    max: 30),
                const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [Text('작게'), Text('보통'), Text('크게')])
              ])
            ]))
          ],
        ));
  }
}

class FontSettingDialog extends StatelessWidget {
  const FontSettingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingProvider>(context);
    double tempSize = settings.fontSize;

    return AlertDialog(
        title: const Text("Setting Font Size",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        content: Column(
          children: [
            const Text("폰트 사이즈 조절", style: TextStyle(fontSize: 16)),
            Slider(
                value: tempSize,
                onChanged: (value) {
                  tempSize = value;
                  settings.setFontSize(tempSize);
                },
                min: 10,
                max: 30),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('작게', style: TextStyle(fontSize: 14)),
                Text('보통', style: TextStyle(fontSize: 14)),
                Text('크게', style: TextStyle(fontSize: 14))
              ],
            )
          ],
        ),
        actions: [
          ElevatedButton(
              onPressed: () {
                settings.setFontSize(tempSize);
                Navigator.of(context).pop();
              },
              child: const Text("Save", style: TextStyle(fontSize: 16))),
          ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel", style: TextStyle(fontSize: 16)))
        ]);
  }
}
