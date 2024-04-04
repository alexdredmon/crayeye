// FILENAME: favorites_drawer.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

import 'config.dart';

class FavoritesDrawer extends StatelessWidget {
  final List<FavoriteItem> favorites;
  final Function(FavoriteItem) onFavoriteItemTapped;
  final Function(FavoriteItem) onFavoriteItemDeleted;

  const FavoritesDrawer({
    Key? key,
    required this.favorites,
    required this.onFavoriteItemTapped,
    required this.onFavoriteItemDeleted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Scaffold(
        backgroundColor: Colors.grey.shade900,
        appBar: AppBar(
          title: Text(
            '❤️ Faves',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.black,
        ),
        body: ListView.builder(
          itemCount: favorites.length,
          itemBuilder: (context, index) {
            FavoriteItem favorite = favorites[index];
            return Dismissible(
              key: Key(favorite.uuid),
              direction: DismissDirection.endToStart,
              onDismissed: (direction) {
                onFavoriteItemDeleted(favorite);
              },
              confirmDismiss: (direction) async {
                return await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(
                        "Delete Fave",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      content: Text(
                        "Are you sure you want to delete this fave?",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      actions: [
                        TextButton(
                          child: Text(
                            "Cancel",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                        ),
                        TextButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                          ),
                          child: Text(
                            "Delete",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              background: Container(
                alignment: Alignment.centerRight,
                padding: EdgeInsets.only(right: 20.0),
                color: Colors.red,
                child: Icon(Icons.delete, color: Colors.white),
              ),
              child: ListTile(
                leading: Image.file(
                  favorite.imageFile,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
                title: Text(
                  favorite.promptTitle,
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () => onFavoriteItemTapped(favorite),
              ),
            );
          },
        ),
      ),
    );
  }
}

class FavoriteItemDialog extends StatelessWidget {
  final FavoriteItem favoriteItem;

  const FavoriteItemDialog({
    Key? key,
    required this.favoriteItem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.file(favoriteItem.imageFile),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      favoriteItem.promptTitle,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 8),
                    MarkdownBody(
                      data: favoriteItem.response,
                      styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                        p: TextStyle(color: Colors.white),
                      ),
                      onTapLink: (String text, String? href, String title) async {
                        if (href != null) {
                          if (await canLaunch(href)) {
                            await launch(href);
                          }
                        }
                      },
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Prompt:',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      favoriteItem.prompt,
                      style: TextStyle(
                        color: Colors.grey.shade100,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// eof
