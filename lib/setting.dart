import 'package:flutter/material.dart';
import 'utilities/color_scheme.dart';
import 'utilities/text_theme.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColor.primary,
        appBar: AppBar(
            backgroundColor: AppColor.primary,
            title: const Text("Settings", style: defaultText)),
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
                onTap: () {},
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
