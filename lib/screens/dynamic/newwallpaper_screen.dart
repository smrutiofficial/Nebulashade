import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nebulashade/constants/colours.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

class NewWallpaper extends StatefulWidget {
  @override
  _NewWallpaperState createState() => _NewWallpaperState();
}

class _NewWallpaperState extends State<NewWallpaper> {
  TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> _imageUrls = [];
  bool _isLoading = false;
  int currentPage = 1;
  String currentQuery = '';

// Method to show the dialog
  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor:
              AppColors.cardBackground, // Background color of the dialog
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(16), // Border radius for the dialog
          ),
          title: Text(
            title,
            style: TextStyle(
              color: Colors.white, // Title text color
            ),
          ),
          content: Text(
            message,
            style: TextStyle(
              color: Colors.white70, // Message text color
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'OK',
                style: TextStyle(
                  color:
                      AppColors.accent, // Custom text color for the 'OK' button
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    searchImages("mountain"); // Default query
  }

  Future<void> searchImages(String query, {int page = 1}) async {
    setState(() {
      _isLoading = true;
      currentQuery = query;
      currentPage = page;
    });

    const accessKey =
        'CxbibAr1QsmC7KbJ3PbyLOAMMYb1VNyBI070kgUbsaA'; // Add your Unsplash Access Key here
    final url =
        'https://api.unsplash.com/search/photos?page=$page&per_page=30&query=$query&orientation=landscape&client_id=$accessKey';

    try {
      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);
      final List results = data['results'];

      final urls = results.map<Map<String, String>>((item) {
        return {
          'regular': item['urls']['regular'],
          'raw': item['urls']['raw'],
        };
      }).toList();

      setState(() {
        _imageUrls = urls;
      });
    } catch (e) {
      print('Error fetching images: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
Future<void> setAsWallpaper(String path) async {
  final uri = 'file://${Uri.encodeFull(path)}'; // Ensure proper URI format

  try {
    final result1 = await Process.run('gsettings', [
      'set',
      'org.gnome.desktop.background',
      'picture-uri',
      uri,
    ]);

    final result2 = await Process.run('gsettings', [
      'set',
      'org.gnome.desktop.background',
      'picture-uri-dark',
      uri,
    ]);

    if (result1.exitCode == 0 && result2.exitCode == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wallpaper set successfully!')),
      );
    } else {
      throw Exception("gsettings failed");
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to set wallpaper: $e')),
    );
  }
}
     
  void _showImageOptions(Map<String, String> imageData) {
    // final imageUrl = imageData['regular']!;
    final downloadUrl = imageData['raw']!;

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      backgroundColor: AppColors.cardBackground,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.photo_album, color: AppColors.accent),
                title:
                    Text("Add to album", style: TextStyle(color: Colors.white)),
                onTap: () async {
                  Navigator.pop(context);
                  final directory = Directory(
                      '${Platform.environment['HOME']}/nexwallpapers');

                  if (!(await directory.exists())) {
                    await directory.create(recursive: true);
                  }

                  final rawName = downloadUrl.split('/').last.split('?').first;
                  final fileName = '$rawName.jpg';
                  final filePath = p.join(directory.path, fileName);

                  try {
                    final response = await http.get(Uri.parse(downloadUrl));
                    final file = File(filePath);
                    await file.writeAsBytes(response.bodyBytes);

                    // After saving the wallpaper, show a dialog
                    if (mounted) {
                      _showDialog(
                          'Added to Album successfully', 'Saved to $filePath');
                    }
                  } catch (e) {
                    // If saving fails, show an error dialog
                    if (mounted) {
                      _showDialog('Failed to save wallpaper', 'Error: $e');
                    }
                  }
                },
              ),

              // =------------set as background --------------------------
              ListTile(
  leading: Icon(Icons.wallpaper, color: AppColors.accent),
  title: Text("Set as wallpaper", style: TextStyle(color: Colors.white)),
  onTap: () async {
    Navigator.pop(context);
    
    final imageUrl = imageData['regular']!;
    final downloadUrl = imageData['raw']!;
    
    final directory = Directory('${Platform.environment['HOME']}/nexwallpapers');
    if (!(await directory.exists())) {
      await directory.create(recursive: true);
    }

    final rawName = downloadUrl.split('/').last.split('?').first;
    final fileName = '$rawName.jpg';
    final filePath = p.join(directory.path, fileName);

    try {
      final response = await http.get(Uri.parse(downloadUrl));
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      // Set the image as wallpaper using gsettings
      await setAsWallpaper(filePath);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Wallpaper set successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to set wallpaper: $e")),
      );
    }
  },
),

       ],
          ),
        );
      },
    );
  }

  Widget buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
      child: TextField(
        controller: _searchController,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search wallpapers...',
          hintStyle: TextStyle(color: Colors.grey),
          prefixIcon: Icon(Icons.search, color: AppColors.accent),
          filled: true,
          fillColor: AppColors.cardBackground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide.none,
          ),
        ),
        onSubmitted: (query) {
          if (query.trim().isNotEmpty) {
            searchImages(query.trim(), page: 1);
          }
        },
      ),
    );
  }

  Widget buildPageNavigator() {
    return Padding(
      padding: const EdgeInsets.only(left: 50, right: 50, bottom: 20),
      child: Row(
        children: [
          Container(
            height: 40,
            padding: EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                "Photo Provided by Unplash, Pixabay & Pexels",
                style: TextStyle(color: AppColors.buttonText),
              ),
            ),
          ),
          Spacer(),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: currentPage > 1
                  ? AppColors.cardBackground
                  : AppColors.cardBackground.withAlpha(205),
              fixedSize: Size(40, 40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              foregroundColor: Colors.white,
              disabledForegroundColor: Colors.white.withAlpha(75),
              disabledBackgroundColor: AppColors.cardBackground.withAlpha(205),
            ),
            onPressed: currentPage > 1
                ? () => searchImages(currentQuery, page: currentPage - 1)
                : null,
            child: Text(
              "<",
              style: TextStyle(
                color:
                    currentPage > 1 ? Colors.white : Colors.white.withAlpha(75),
                fontSize: 20,
              ),
            ),
          ),
          SizedBox(width: 8),
          Container(
            width: 100,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                'Page $currentPage',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
          SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.cardBackground,
              fixedSize: Size(40, 40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => searchImages(currentQuery, page: currentPage + 1),
            child: Text(
              ">",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildImageGrid() {
    if (_isLoading) {
      return Expanded(
        child: Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
      );
    }

    if (_imageUrls.isEmpty) {
      return Expanded(
        child: Center(
          child: Text('No results', style: TextStyle(color: Colors.white54)),
        ),
      );
    }

    return Expanded(
      child: GridView.builder(
        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
        itemCount: _imageUrls.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 16 / 9,
        ),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => _showImageOptions(_imageUrls[index]),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                _imageUrls[index]['regular']!,
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.accent,
        elevation: 0,
      ),
      body: Column(
        children: [
          buildSearchBar(),
          if (_imageUrls.isNotEmpty) buildPageNavigator(),
          buildImageGrid(),
        ],
      ),
    );
  }
}
