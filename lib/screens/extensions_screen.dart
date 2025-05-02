import 'dart:io';
import 'package:flutter/material.dart';
import 'package:nebulashade/constants/colours.dart';

class GnomeExtension {
  final String uuid;
  final String displayName;
  final String version;
  bool enabled;

  GnomeExtension({
    required this.uuid,
    required this.displayName,
    required this.version,
    required this.enabled,
  });
}

class ExtensionsScreen extends StatefulWidget {
  @override
  State<ExtensionsScreen> createState() => _ExtensionsScreenState();
}

class _ExtensionsScreenState extends State<ExtensionsScreen> {
  List<GnomeExtension> _extensions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchExtensions();
  }

  Future<void> _fetchExtensions() async {
    setState(() => _loading = true);

    final enabledResult =
        await Process.run('gnome-extensions', ['list', '--enabled']);
    final disabledResult =
        await Process.run('gnome-extensions', ['list', '--disabled']);

    final enabled = (enabledResult.stdout as String)
        .split('\n')
        .where((e) => e.isNotEmpty)
        .toList();
    final disabled = (disabledResult.stdout as String)
        .split('\n')
        .where((e) => e.isNotEmpty)
        .toList();

    final all = [
      ...enabled.map((e) => {'uuid': e, 'enabled': true}),
      ...disabled.map((e) => {'uuid': e, 'enabled': false}),
    ];

    List<GnomeExtension> extensions = [];

    for (final item in all) {
      final uuid = item['uuid'] as String;
      final enabled = item['enabled'] as bool;

      final info = await Process.run('gnome-extensions', ['info', uuid]);
      final infoStr = info.stdout.toString();

      final nameMatch = RegExp(r'Name:\s*(.+)').firstMatch(infoStr);
      final versionMatch = RegExp(r'Version:\s*(.+)').firstMatch(infoStr);

      final displayName = nameMatch?.group(1)?.trim() ?? uuid;
      final version = versionMatch?.group(1)?.trim() ?? "unknown";

      extensions.add(GnomeExtension(
        uuid: uuid,
        displayName: displayName,
        version: version,
        enabled: enabled,
      ));
    }

    setState(() {
      _extensions = extensions;
      _loading = false;
    });
  }

  Future<void> _toggleExtension(GnomeExtension ext) async {
    final command = ext.enabled ? 'disable' : 'enable';
    await Process.run('gnome-extensions', [command, ext.uuid]);

    setState(() {
      ext.enabled = !ext.enabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: Colors.white,
                ),
                SizedBox(height: 20),
                Text(
                  "Loading Extensions ...",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ],
            ),
          )
        : Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // --------------------------------------------------------------------------
                    Column(
                      crossAxisAlignment: CrossAxisAlignment
                          .start, // Aligns text to the start (left)
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 12),
                          child: Text(
                            "Installed Extensions",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: 18),
                          child: Text(
                            "Right click to show more option",
                            style: TextStyle(
                              fontSize: 10,
                              color:  AppColors.adjustColor(AppColors.background,
                    saturationDelta: 24, valueDelta: 80),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Spacer(),

                    // padding: EdgeInsets.only(top: 12),
                    Container(
                      margin: EdgeInsets.only(bottom: 15),
                      child: ElevatedButton(
                        onPressed: () {
                          // Do something here
                          print("Button Pressed");
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.lighten(
                              AppColors.background,
                              0.0), // Set your desired background color
                          foregroundColor: AppColors.buttonText, // Text color
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(6), // Rounded corners
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 12),
                          elevation:
                              0, // optional: remove elevation if you want a flat style
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 8),
                          child: Icon(
                            Icons.shopping_cart,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),

                    // ---------------------------------------------------------------------------
                  ],
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _extensions.length,
                    itemBuilder: (context, index) {
                      final ext = _extensions[index];
                      final isFirst = index == 0;
                      final isLast = index == _extensions.length - 1;

                      return Padding(
                        padding: EdgeInsets.only(
                          top: isFirst
                              ? 0
                              : 1, // small gap above except first item
                          bottom: isLast
                              ? 0
                              : 1, // small gap below except last item
                        ),
                        child: Container(
                          height: 64,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.vertical(
                              top: isFirst
                                  ? const Radius.circular(10)
                                  : Radius.zero,
                              bottom: isLast
                                  ? const Radius.circular(10)
                                  : Radius.zero,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Info column
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          ext.displayName,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.white70,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: AppColors.lighten(
                                                AppColors.background, 0.06),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            'V ${ext.version}',
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: AppColors.buttonText,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      ext.uuid,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              // Switch
                              Transform.scale(
                                scale: 0.9,
                                child: Switch(
                                  value: ext.enabled,
                                  onChanged: (_) => _toggleExtension(ext),
                                  activeColor: AppColors.adjustColor(
                                      AppColors.background,
                                      saturationDelta: 24,
                                      valueDelta: 49),
                                  activeTrackColor: AppColors.adjustColor(
                                      AppColors.background,
                                      saturationDelta: 70,
                                      valueDelta: 18),
                                  inactiveThumbColor: AppColors.adjustColor(
                                      AppColors.background,
                                      saturationDelta: 70,
                                      valueDelta: 18),
                                  inactiveTrackColor: AppColors.adjustColor(
                                      AppColors.background,
                                      saturationDelta: 24,
                                      valueDelta: 49),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          );
  }
}
