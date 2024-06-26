import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:manime/data/models/manga_search/manga_search.dart';
import 'package:manime/data/repository/manga_search/manga_search_repository.dart';
import 'package:transparent_image/transparent_image.dart';

// ignore: must_be_immutable
class CustomAppBar extends StatefulWidget {
  FocusNode focusNode;
  CustomAppBar({required this.focusNode, super.key});

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  late final TextEditingController _controller;

  String fileName = "";
  String title = "";
  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TypeAheadField(
      decorationBuilder: (context, child) {
        return Material(
          color: const Color.fromARGB(255, 38, 37, 37),
          type: MaterialType.card,
          elevation: 4,
          borderRadius: BorderRadius.circular(8),
          child: child,
        );
      },
      offset: const Offset(0, 12),
      constraints: const BoxConstraints(maxHeight: 500),
      controller: _controller,
      itemBuilder: (context, value) {
        for (Relationships rel in value.relationships) {
          if (rel.type == 'cover_art') {
            fileName = rel.attributes?.fileName ?? 'No Image';
          }
        }
        if (value.attributes.title?.en == null) {
          for (AltTitles? alt in value.attributes.altTitles) {
            if (alt?.en != null) {
              title = alt?.en ?? 'No Title';
              break;
            }
          }
        } else {
          title = value.attributes.title?.en as String;
        }
        return Column(
          children: [
            SizedBox(
                height: MediaQuery.of(context).size.height * 0.2,
                child: Card(
                  color: const Color.fromARGB(255, 51, 50, 50),
                  child: Row(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.2,
                        width: MediaQuery.of(context).size.width * 0.2,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: FadeInImage.memoryNetwork(
                            image:
                                "https://uploads.mangadex.org/covers/${value.id}/$fileName",
                            placeholder: kTransparentImage,
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.4,
                              child: Text(
                                title,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                                overflow: TextOverflow.clip,
                                softWrap: true,
                                maxLines: 2,
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.4,
                              child: Text(
                                maxLines: 4,
                                value.attributes.description?.en ??
                                    "No Description",
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                )),
            const Divider(
              height: 20,
              thickness: 2,
            )
          ],
        );
      },
      onSelected: (value) {
        String filenamepu = "";
        String titlepu = "";
        if (value.attributes.title?.en == null) {
          for (AltTitles? alt in value.attributes.altTitles) {
            if (alt?.en != null) {
              titlepu = alt?.en ?? 'No Title';
              break;
            }
          }
        } else {
          titlepu = value.attributes.title?.en as String;
        }
        for (Relationships rel in value.relationships) {
          if (rel.type == 'cover_art') {
            filenamepu = rel.attributes?.fileName ?? 'No Image';
          }
        }
        Navigator.pushNamed(context, '/home/mangainfo', arguments: {
          'MangaId': value.id,
          'ImageUrl':
              "https://uploads.mangadex.org/covers/${value.id}/$filenamepu",
          'title': titlepu
        });
      },
      focusNode: widget.focusNode,
      builder: (context, controller, focusNode) {
        return TextField(
          focusNode: focusNode,
          controller: controller,
          style: const TextStyle(color: Colors.white, fontSize: 20),
          autofocus: false,
        );
      },
      suggestionsCallback: (search) async {
        Manga manga = await MangaSearchRepository().mangaSearch(search);

        return manga.data;
      },
    );
  }
}
