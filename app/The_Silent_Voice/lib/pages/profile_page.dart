import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:the_silent_voice/main.dart';
import 'package:the_silent_voice/utils.dart';

/// # NoSelectionControls
/// Custom `TextSelectionControls` to remove any selection handles, toolbar,
/// or indicator under the cursor. Useful for a clean minimal TextField UI.
class NoSelectionControls extends TextSelectionControls {
  @override
  Widget buildHandle(
    BuildContext context,
    TextSelectionHandleType type,
    double textLineHeight, [
    VoidCallback? onTap,
  ]) {
    return const SizedBox.shrink();
  }

  @override
  Size getHandleSize(double textLineHeight) {
    return Size.zero;
  }

  @override
  Offset getHandleAnchor(TextSelectionHandleType type, double textLineHeight) {
    return Offset.zero;
  }

  @override
  Widget buildToolbar(
    BuildContext context,
    Rect globalEditableRegion,
    double toolbarHeight,
    Offset anchorAbove,
    List<TextSelectionPoint> endpoints,
    TextSelectionDelegate delegate,
    ValueListenable<ClipboardStatus>? clipboardStatus,
    Offset? lastSecondaryTapDownPosition,
  ) {
    return const SizedBox.shrink();
  }
}

/// # Profile Page
/// `Profilepage` allows the user to view and edit their profile information,
/// including name and email. It also provides appearance settings (Dark/Light mode),
/// preferences, privacy/security, and app information.
/// - Editable text fields use `NoSelectionControls` to remove cursor underline and handles.
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

/// ## _ProfilepageState
/// State class for `Profilepage`. Handles editing of user info, image picking (camera/gallery), theme switching,and taps on settings/preferences.
 
class _ProfilePageState extends State<ProfilePage> {
  /// ### User Profile Image
  /// Stores the selected profile image as bytes (Uint8List)
  Uint8List? _image;

  /// ### selectImage
  /// Opens the image picker to select an image from the given source
  /// - source: `ImageSource.camera` or `ImageSource.gallery`
  /// - sets `_image` if a file is selected
  void selectImage(ImageSource source) async {
    Uint8List? image = await pickImage(source);
    if (image == null) return;
    setState(() {
      _image = image;
    });
  }

  /// ### showImageOptions
  /// Displays a bottom sheet allowing the user to pick image from Camera or Gallery
  void showImageOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              /// ### Camera Option
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Camera"),
                onTap: () {
                  Navigator.pop(context);
                  selectImage(ImageSource.camera);
                },
              ),
              /// ### Gallery Option
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Gallery"),
                onTap: () {
                  Navigator.pop(context);
                  selectImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }
  /// ### Profile Editing Controls
  bool editProfileData = false;
  late final TextEditingController userName;
  late final TextEditingController userEmail;
  /// ### Default Profile Info
  String name = "User Name";
  String email = "user@email.com";
  @override
  void initState() {
    super.initState();
    userName = TextEditingController(text: name);
    userEmail = TextEditingController(text: email);
  }

  @override
  void dispose() {
    userName.dispose();
    userEmail.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// ### Check Theme Mode
    final switched = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      /// ### Body ListView
      /// Scrollable page containing profile sections
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          /// ### AppBar Section
          /// Displays "Profile" title at top with colored background
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).colorScheme.outline,
                  width: 1,
                ),
              ),
            ),
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text("Profile", style: Theme.of(context).textTheme.titleLarge),
                SizedBox(height: 15),
              ],
            ),
          ),

          /// ### Profile Avatar & Data Section
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.tertiaryContainer,
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).colorScheme.outline,
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 20),

                /// #### Profile Picture with Camera Button
                Stack(
                  children: [
                    _image != null
                        ? CircleAvatar(
                            radius: 65,
                            backgroundImage: MemoryImage(_image!),
                          )
                        : CircleAvatar(
                            radius: 65,
                            backgroundImage:
                                AssetImage("assets/icons/profile.avif")
                                    as ImageProvider,
                          ),
                    Positioned(
                      bottom: -10,
                      left: 80,
                      child: IconButton(
                        onPressed: showImageOptions, // opens camera/gallery options
                        icon: Icon(Icons.add_a_photo_rounded),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                /// #### User Name TextField / Display
                editProfileData
                    ? Padding(
                        padding: const EdgeInsets.only(right: 30, left: 30),
                        child: TextField(
                          controller: userName,
                          textAlign: TextAlign.center,
                          cursorColor: Colors.black,
                          selectionControls: NoSelectionControls(),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.outline,
                                width: 1,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.tertiary,
                          ),
                        ),
                      )
                    : Text(
                        name,
                        style: Theme.of(context).textTheme.displaySmall,
                      ),

                const SizedBox(height: 8),

                /// #### User Email TextField / Display
                editProfileData
                    ? Padding(
                        padding: const EdgeInsets.only(right: 30, left: 30),
                        child: TextField(
                          controller: userEmail,
                          textAlign: TextAlign.center,
                          cursorColor: Colors.black,
                          selectionControls: NoSelectionControls(),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.outline,
                                width: 1,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.tertiary,
                          ),
                        ),
                      )
                    : Text(email, style: Theme.of(context).textTheme.bodySmall),

                const SizedBox(height: 5),

                /// #### Edit / Save Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.tertiary,
                    overlayColor: Colors.lightBlueAccent,
                  ),
                  onPressed: () async {
                    /// Save edits if editing
                    if (editProfileData) {
                      setState(() {
                        name = userName.text;
                        email = userEmail.text;
                      });
                    }
                    /// Toggle edit mode
                    setState(() {
                      editProfileData = !editProfileData;
                    });
                  },
                  child: Text(
                    editProfileData ? "Save" : "Edit",
                    style: TextStyle(color: Colors.blue),
                  ),
                ),

                const SizedBox(height: 10),
              ],
            ),
          ),
          const SizedBox(height: 10),

          /// ### Appearance Section (Dark / Light Mode)
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 10, 0, 4),
                  child: Text(
                    'Appearance',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                Divider(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 4),
                  child: InkWell(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    onTap: () {
                      TheSilentVoice.of(context).toggleTheme(!switched);
                    },
                    child: Row(
                      children: [
                        Icon(
                          switched
                              ? Icons.dark_mode_outlined
                              : Icons.light_mode_outlined,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            switched ? 'Dark Mode' : 'Light Mode',
                            style: Theme.of(context).textTheme.displaySmall,
                          ),
                        ),
                        Switch(
                          value: switched,
                          onChanged: (value) {
                            TheSilentVoice.of(context).toggleTheme(value);
                          },
                          inactiveThumbColor: Colors.white,
                          inactiveTrackColor: Colors.grey[400],
                          activeTrackColor: Colors.blue,
                          activeThumbColor: Colors.white,
                          trackOutlineColor: WidgetStateProperty.all(
                            Colors.transparent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// ### Preferences Section
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 10, 0, 4),
                  child: Text(
                    'Preferences',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                Divider(),

                /// #### Notifications Row
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 5),
                  child: InkWell(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    onTap: () {},
                    child: Row(
                      children: [
                        Icon(Icons.notifications_none),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Notifications',
                            style: Theme.of(context).textTheme.displaySmall,
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios, color: Colors.grey[400]),
                      ],
                    ),
                  ),
                ),
                Divider(),

                /// #### Language Row
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
                  child: InkWell(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    onTap: () {},
                    child: Row(
                      children: [
                        Icon(Icons.language_outlined),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Language',
                            style: Theme.of(context).textTheme.displaySmall,
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios, color: Colors.grey[400]),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// ### Privacy & Security Section
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 10, 0, 4),
                  child: Text(
                    'Privacy & Security',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                Divider(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
                  child: InkWell(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    onTap: () {},
                    child: Row(
                      children: [
                        Icon(Icons.privacy_tip_outlined),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Privacy Security',
                            style: Theme.of(context).textTheme.displaySmall,
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios, color: Colors.grey[400]),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// ### About Section
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 10, 0, 4),
                  child: Text(
                    'About',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                Divider(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
                  child: InkWell(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    onTap: () {},
                    child: Row(
                      children: [
                        Icon(Icons.info_outline_rounded),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'App Information',
                            style: Theme.of(context).textTheme.displaySmall,
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios, color: Colors.grey[400]),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
