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
                onTap: () {
                  Navigator.pushNamed(context, '/');
                },
                child: const ListTile(
                    leading: Text("Select Bible Translation(s)",
                        style: defaultText))),
            const Divider(color: AppColor.stroke),
            GestureDetector(
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return const FontSetting();
                      });
                },
                child: const ListTile(
                    leading: Text("Font size", style: defaultText))),
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
    final width = MediaQuery.of(context).size.width;
    return AlertDialog(
        title: const Text("Setting Font Size",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: IntrinsicHeight(
            child: Container(
              width: width * (300 / 393),
              padding: const EdgeInsets.only(top: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Change font size",
                      style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: Column(
                      children: [
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                              overlayShape: SliderComponentShape.noOverlay),
                          child: Slider(
                              value: tempSize,
                              onChanged: (value) {
                                tempSize = value;
                                settings.setFontSize(tempSize);
                              },
                              min: 10,
                              max: 30),
                        ),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Small', style: TextStyle(fontSize: 14)),
                            Text('Normal', style: TextStyle(fontSize: 14)),
                            Text('Large', style: TextStyle(fontSize: 14))
                          ],
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                      "For God so loved the world that he gave his one and only Son, that whoever believes in him shall not perish but have eternal life.(John 3:16)",
                      style: defaultText.copyWith(fontSize: tempSize))
                ],
              ),
            ),
          ),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: width * (110 / 393),
                height: 40,
                child: ElevatedButton(
                    onPressed: () {
                      settings.setFontSize(tempSize);
                      Navigator.of(context).pop();
                    },
                    child: const Text("Save", style: TextStyle(fontSize: 16))),
              ),
              SizedBox(
                width: width * (110 / 393),
                height: 40,
                child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child:
                        const Text("Cancel", style: TextStyle(fontSize: 16))),
              )
            ],
          )
        ]);
  }
}
