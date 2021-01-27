///Buat image nya kelempar ke tab Everyone!

import 'dart:io';
import 'dart:typed_data';

import 'package:clipstream/Pages/streamalert.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:video_player/video_player.dart';

class Gallery extends StatefulWidget {
  @override
  _GalleryState createState() => _GalleryState();
  final Function pressedAppBar;
  final Function imageThrow;
  final int currentSelectedImage;

  final Map<String, bool> isSelectedArray;
  const Gallery ({Key key, this.pressedAppBar, this.imageThrow, this.currentSelectedImage, this.isSelectedArray}) : super (key:key);
}

class _GalleryState extends State<Gallery> {
  // This will hold all the assets we fetched
  List<AssetEntity> assets = [];
  List<AssetEntity> imageArr = [];
  Map<String, int> indexedAssets = {
    "a": -1,
  };
  int currentSelectedImage;

  @override
  void initState() {
    super.initState();
    _fetchAssets();
    currentSelectedImage = widget.currentSelectedImage;
  }

  _fetchAssets() async {
    // Set onlyAll to true, to fetch only the 'Recent' album
    // which contains all the photos/videos in the storage
    final albums = await PhotoManager.getAssetPathList(onlyAll: true);
    final recentAlbum = albums.first;

    // Now that we got the album, fetch all the assets it contains
    final recentAssets = await recentAlbum.getAssetListRange(
      start: 0, // start at index 0
      end: 1000000, // end at a very big index (to get all the assets)
    );

    // Update the state and notify UI
    for (var i = 0; i < recentAssets.length; i++) {
      indexedAssets[recentAssets[i].id] = i;
    }
    setState(() => {
      assets = recentAssets
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: [
          Positioned(
            child: SingleChildScrollView(
              child: Container(
                height: 480,
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    // A grid view with 3 items per
                    crossAxisCount: 2,
                  ),
                  itemCount: assets.length,
                  itemBuilder: (_, index) {
                    print(assets[index].id + " " + widget.isSelectedArray[assets[index].id].toString());
                    return AssetThumbnail(
                        asset: assets[index],
                        isSelected: widget.isSelectedArray[assets[index].id] == null ? false : widget.isSelectedArray[assets[index].id],
                        id: assets[index].id,
                        onPressedIcon: () {
                          // Future.delayed(const Duration(milliseconds: 2000), () => showDialog(
                          //   context: context,
                          //   builder: (context) => StreamIt(),
                          // ));
                          var isSelectedArrayCopy = widget.isSelectedArray;
                          if (isSelectedArrayCopy[assets[index].id] == null){
                            isSelectedArrayCopy[assets[index].id] = false;
                          }
                          isSelectedArrayCopy[assets[index].id] = !isSelectedArrayCopy[assets[index].id];
                          widget.pressedAppBar(
                              assets[index].id, isSelectedArrayCopy[assets[index].id]
                          );
                          setState(() => {
                            currentSelectedImage = isSelectedArrayCopy[assets[index].id] ? currentSelectedImage + 1 : currentSelectedImage - 1,
                          });
                        }
                    );
                  },
                ),
              ),
            ),
          ),
          Visibility(
            visible: widget.currentSelectedImage > 0,
            child: Positioned(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  margin: EdgeInsets.only(top: 415),
                  child: ButtonTheme(
                    minWidth: MediaQuery.of(context).size.width,
                    height: 64,
                    child: RaisedButton.icon(
                      icon: Icon(Icons.stacked_line_chart, color: Colors.white),
                      onPressed: () => {
                        imageArr.clear(),
                        widget.isSelectedArray.forEach((k,v) => {
                        if (v == true) {
                          imageArr.add(assets[indexedAssets[k]])
                        }}),
                        print(imageArr.toString()),
                        widget.imageThrow(imageArr),
                      },
                      color: Color(0xFF3CB371),
                      textColor: Colors.white,
                      label: Text('Stream it!',
                          style: GoogleFonts.sunflower(fontSize: 25)),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AssetThumbnail extends StatelessWidget {
  const AssetThumbnail({
    Key key,
    @required this.asset,
    this.isSelected,
    this.hideSelectedBox,
    @required this.onPressedIcon,
    @required this.id,
  }) : super(key: key);

  final AssetEntity asset;
  final bool isSelected;
  final bool hideSelectedBox;
  final String id;
  final Function onPressedIcon;

  @override
  Widget build(BuildContext context) {
    // We're using a FutureBuilder since thumbData is a future
    return FutureBuilder<Uint8List>(
      future: asset.thumbData,
      builder: (_, snapshot) {
        final bytes = snapshot.data;
        // If we have no data, display a spinner
        if (bytes == null) return CircularProgressIndicator();
        // If there's data, display it as an image
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) {
                  if (asset.type == AssetType.image) {
                    // If this is an image, navigate to ImageScreen
                    return ImageScreen(imageFile: asset.file);
                  } else {
                    // if it's not, navigate to VideoScreen
                    return VideoScreen(videoFile: asset.file);
                  }
                },
              ),
            );
          },
          child: Stack(
            children: [
              // Wrap the image in a Positioned.fill to fill the space
              Positioned.fill(
                child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(width: 3.0, color: Colors.transparent)
                    ),
                    child: Image.memory(bytes, fit: BoxFit.cover)
                ),
              ),
              // Display a Play icon if the asset is a video
              if (asset.type == AssetType.video)
                Center(
                  child: Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/play.png'),
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: hideSelectedBox == null || !hideSelectedBox,
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: Container(
                        height: 50,
                        width: 50,
                        child: IconButton(
                          icon: new Icon(
                            !isSelected ? MdiIcons.checkboxBlankOutline : MdiIcons.checkboxMarked,
                            color: !isSelected ? Colors.white : Color(0xFF3CB371),
                            size: 30,
                          ),
                          onPressed: () {onPressedIcon();},
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class ImageScreen extends StatelessWidget {
  const ImageScreen({
    Key key,
    @required this.imageFile,
  }) : super(key: key);

  final Future<File> imageFile;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      alignment: Alignment.center,
      child: FutureBuilder<File>(
        future: imageFile,
        builder: (_, snapshot) {
          final file = snapshot.data;
          if (file == null) return Container();
          return Image.file(file);
        },
      ),
    );
  }
}

class VideoScreen extends StatefulWidget {
  const VideoScreen({
    Key key,
    @required this.videoFile,
  }) : super(key: key);

  final Future<File> videoFile;

  @override
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  VideoPlayerController _controller;
  bool initialized = false;

  @override
  void initState() {
    _initVideo();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  _initVideo() async {
    final video = await widget.videoFile;
    _controller = VideoPlayerController.file(video)
      // Play the video again when it ends
      ..setLooping(true)
      // initialize the controller and notify UI when done
      ..initialize().then((_) => setState(() => initialized = true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: initialized
          // If the video is initialized, display it
          ? Scaffold(
              body: Center(
                child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  // Use the VideoPlayer widget to display the video.
                  child: VideoPlayer(_controller),
                ),
              ),
              floatingActionButton: Container(
                margin: EdgeInsets.only(
                    bottom: (MediaQuery.of(context).size.height / 2) - 50,
                    right: (MediaQuery.of(context).size.width / 2) - 50),
                // height: MediaQuery.of(context).size.height / 2,
                // width: MediaQuery.of(context).size.width / 2,
                child: FloatingActionButton(
                  backgroundColor: Colors.transparent,
                  onPressed: () {
                    // Wrap the play or pause in a call to `setState`. This ensures the
                    // correct icon is shown.
                    setState(() {
                      // If the video is playing, pause it.
                      if (_controller.value.isPlaying) {
                        _controller.pause();
                      } else {
                        // If the video is paused, play it.
                        _controller.play();
                      }
                    });
                  },
                  // Display the correct icon depending on the state of the player.
                  child: Icon(
                    _controller.value.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
              ),
              // floatingActionButtonLocation: FloatingActionButtonLocation.center,
            )
          // If the video is not yet initialized, display a spinner
          : Center(child: CircularProgressIndicator()),
    );
  }
}

// class ImagePickerScreen extends StatefulWidget {
//   @override
//   _ImagePickerScreenState createState() => _ImagePickerScreenState();
// }

// class _ImagePickerScreenState extends State<ImagePickerScreen> {
//   File _image;
//   final picker = ImagePicker();
//
//   Future getImage() async {
//     final pickedFile = await picker.getImage(source: ImageSource.camera);
//
//     setState(() {
//       if (pickedFile != null) {
//         _image = File(pickedFile.path);
//       } else {
//         print('No image selected.');
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Image Picker Example'),
//       ),
//       body: Center(
//         child: _image == null
//             ? Text('No image selected.')
//             : Image.file(_image),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: getImage,
//         tooltip: 'Pick Image',
//         child: Icon(Icons.add_a_photo),
//       ),
//     );
//   }
// }


// import 'dart:async';
// import 'dart:io';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/src/widgets/basic.dart';
// import 'package:flutter/src/widgets/container.dart';
// import 'package:flutter/src/widgets/text.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:video_player/video_player.dart';
//
// class ImagePickerScreen extends StatefulWidget {
//   ImagePickerScreen({Key key, this.title}) : super(key: key);
//
//   final String title;
//
//   @override
//   _ImagePickerScreenState createState() => _ImagePickerScreenState();
// }
//
// class _ImagePickerScreenState extends State<ImagePickerScreen> {
//   PickedFile _imageFile;
//   dynamic _pickImageError;
//   bool isVideo = false;
//   VideoPlayerController _controller;
//   VideoPlayerController _toBeDisposed;
//   String _retrieveDataError;
//
//   final ImagePicker _picker = ImagePicker();
//   final TextEditingController maxWidthController = TextEditingController();
//   final TextEditingController maxHeightController = TextEditingController();
//   final TextEditingController qualityController = TextEditingController();
//
//   Future<void> _playVideo(PickedFile file) async {
//     if (file != null && mounted) {
//       await _disposeVideoController();
//       if (kIsWeb) {
//         _controller = VideoPlayerController.network(file.path);
//         // In web, most browsers won't honor a programmatic call to .play
//         // if the video has a sound track (and is not muted).
//         // Mute the video so it auto-plays in web!
//         // This is not needed if the call to .play is the result of user
//         // interaction (clicking on a "play" button, for example).
//         await _controller.setVolume(0.0);
//       } else {
//         _controller = VideoPlayerController.file(File(file.path));
//         await _controller.setVolume(1.0);
//       }
//       await _controller.initialize();
//       await _controller.setLooping(true);
//       await _controller.play();
//       setState(() {});
//     }
//   }
//
//   void _onImageButtonPressed(ImageSource source, {BuildContext context}) async {
//     if (_controller != null) {
//       await _controller.setVolume(0.0);
//     }
//     if (isVideo) {
//       final PickedFile file = await _picker.getVideo(
//           source: source, maxDuration: const Duration(seconds: 10));
//       await _playVideo(file);
//     } else {
//       await _displayPickImageDialog(context,
//               (double maxWidth, double maxHeight, int quality) async {
//             try {
//               final pickedFile = await _picker.getImage(
//                 source: source,
//                 maxWidth: maxWidth,
//                 maxHeight: maxHeight,
//                 imageQuality: quality,
//               );
//               setState(() {
//                 _imageFile = pickedFile;
//               });
//             } catch (e) {
//               setState(() {
//                 _pickImageError = e;
//               });
//             }
//           });
//     }
//   }
//
//   @override
//   void deactivate() {
//     if (_controller != null) {
//       _controller.setVolume(0.0);
//       _controller.pause();
//     }
//     super.deactivate();
//   }
//
//   @override
//   void dispose() {
//     _disposeVideoController();
//     maxWidthController.dispose();
//     maxHeightController.dispose();
//     qualityController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _disposeVideoController() async {
//     if (_toBeDisposed != null) {
//       await _toBeDisposed.dispose();
//     }
//     _toBeDisposed = _controller;
//     _controller = null;
//   }
//
//   Widget _previewVideo() {
//     final Text retrieveError = _getRetrieveErrorWidget();
//     if (retrieveError != null) {
//       return retrieveError;
//     }
//     if (_controller == null) {
//       return const Text(
//         'You have not yet picked a video',
//         textAlign: TextAlign.center,
//       );
//     }
//     return Padding(
//       padding: const EdgeInsets.all(10.0),
//       child: AspectRatioVideo(_controller),
//     );
//   }
//
//   Widget _previewImage() {
//     final Text retrieveError = _getRetrieveErrorWidget();
//     if (retrieveError != null) {
//       return retrieveError;
//     }
//     if (_imageFile != null) {
//       if (kIsWeb) {
//         // Why network?
//         // See https://pub.dev/packages/image_picker#getting-ready-for-the-web-platform
//         return Image.network(_imageFile.path);
//       } else {
//         return Image.file(File(_imageFile.path));
//       }
//     } else if (_pickImageError != null) {
//       return Text(
//         'Pick image error: $_pickImageError',
//         textAlign: TextAlign.center,
//       );
//     } else {
//       return const Text(
//         'You have not yet picked an image.',
//         textAlign: TextAlign.center,
//       );
//     }
//   }
//
//   Future<void> retrieveLostData() async {
//     final LostData response = await _picker.getLostData();
//     if (response.isEmpty) {
//       return;
//     }
//     if (response.file != null) {
//       if (response.type == RetrieveType.video) {
//         isVideo = true;
//         await _playVideo(response.file);
//       } else {
//         isVideo = false;
//         setState(() {
//           _imageFile = response.file;
//         });
//       }
//     } else {
//       _retrieveDataError = response.exception.code;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.title),
//       ),
//       body: Center(
//         child: !kIsWeb && defaultTargetPlatform == TargetPlatform.android
//             ? FutureBuilder<void>(
//           future: retrieveLostData(),
//           builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
//             switch (snapshot.connectionState) {
//               case ConnectionState.none:
//               case ConnectionState.waiting:
//                 return const Text(
//                   'You have not yet picked an image.',
//                   textAlign: TextAlign.center,
//                 );
//               case ConnectionState.done:
//                 return isVideo ? _previewVideo() : _previewImage();
//               default:
//                 if (snapshot.hasError) {
//                   return Text(
//                     'Pick image/video error: ${snapshot.error}}',
//                     textAlign: TextAlign.center,
//                   );
//                 } else {
//                   return const Text(
//                     'You have not yet picked an image.',
//                     textAlign: TextAlign.center,
//                   );
//                 }
//             }
//           },
//         )
//             : (isVideo ? _previewVideo() : _previewImage()),
//       ),
//       floatingActionButton: Column(
//         mainAxisAlignment: MainAxisAlignment.end,
//         children: <Widget>[
//           FloatingActionButton(
//             onPressed: () {
//               isVideo = false;
//               _onImageButtonPressed(ImageSource.gallery, context: context);
//             },
//             heroTag: 'image0',
//             tooltip: 'Pick Image from gallery',
//             child: const Icon(Icons.photo_library),
//           ),
//           Padding(
//             padding: const EdgeInsets.only(top: 16.0),
//             child: FloatingActionButton(
//               onPressed: () {
//                 isVideo = false;
//                 _onImageButtonPressed(ImageSource.camera, context: context);
//               },
//               heroTag: 'image1',
//               tooltip: 'Take a Photo',
//               child: const Icon(Icons.camera_alt),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.only(top: 16.0),
//             child: FloatingActionButton(
//               backgroundColor: Colors.red,
//               onPressed: () {
//                 isVideo = true;
//                 _onImageButtonPressed(ImageSource.gallery);
//               },
//               heroTag: 'video0',
//               tooltip: 'Pick Video from gallery',
//               child: const Icon(Icons.video_library),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.only(top: 16.0),
//             child: FloatingActionButton(
//               backgroundColor: Colors.red,
//               onPressed: () {
//                 isVideo = true;
//                 _onImageButtonPressed(ImageSource.camera);
//               },
//               heroTag: 'video1',
//               tooltip: 'Take a Video',
//               child: const Icon(Icons.videocam),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Text _getRetrieveErrorWidget() {
//     if (_retrieveDataError != null) {
//       final Text result = Text(_retrieveDataError);
//       _retrieveDataError = null;
//       return result;
//     }
//     return null;
//   }
//
//   Future<void> _displayPickImageDialog(
//       BuildContext context, OnPickImageCallback onPick) async {
//     return showDialog(
//         context: context,
//         builder: (context) {
//           return AlertDialog(
//             title: Text('Add optional parameters'),
//             content: Column(
//               children: <Widget>[
//                 TextField(
//                   controller: maxWidthController,
//                   keyboardType: TextInputType.numberWithOptions(decimal: true),
//                   decoration:
//                   InputDecoration(hintText: "Enter maxWidth if desired"),
//                 ),
//                 TextField(
//                   controller: maxHeightController,
//                   keyboardType: TextInputType.numberWithOptions(decimal: true),
//                   decoration:
//                   InputDecoration(hintText: "Enter maxHeight if desired"),
//                 ),
//                 TextField(
//                   controller: qualityController,
//                   keyboardType: TextInputType.number,
//                   decoration:
//                   InputDecoration(hintText: "Enter quality if desired"),
//                 ),
//               ],
//             ),
//             actions: <Widget>[
//               FlatButton(
//                 child: const Text('CANCEL'),
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//               ),
//               FlatButton(
//                   child: const Text('PICK'),
//                   onPressed: () {
//                     double width = maxWidthController.text.isNotEmpty
//                         ? double.parse(maxWidthController.text)
//                         : null;
//                     double height = maxHeightController.text.isNotEmpty
//                         ? double.parse(maxHeightController.text)
//                         : null;
//                     int quality = qualityController.text.isNotEmpty
//                         ? int.parse(qualityController.text)
//                         : null;
//                     onPick(width, height, quality);
//                     Navigator.of(context).pop();
//                   }),
//             ],
//           );
//         });
//   }
// }
//
// typedef void OnPickImageCallback(
//     double maxWidth, double maxHeight, int quality);
//
// class AspectRatioVideo extends StatefulWidget {
//   AspectRatioVideo(this.controller);
//
//   final VideoPlayerController controller;
//
//   @override
//   AspectRatioVideoState createState() => AspectRatioVideoState();
// }
//
// class AspectRatioVideoState extends State<AspectRatioVideo> {
//   VideoPlayerController get controller => widget.controller;
//   bool initialized = false;
//
//   void _onVideoControllerUpdate() {
//     if (!mounted) {
//       return;
//     }
//     if (initialized != controller.value.initialized) {
//       initialized = controller.value.initialized;
//       setState(() {});
//     }
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     controller.addListener(_onVideoControllerUpdate);
//   }
//
//   @override
//   void dispose() {
//     controller.removeListener(_onVideoControllerUpdate);
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (initialized) {
//       return Center(
//         child: AspectRatio(
//           aspectRatio: controller.value?.aspectRatio,
//           child: VideoPlayer(controller),
//         ),
//       );
//     } else {
//       return Container();
//     }
//   }
// }