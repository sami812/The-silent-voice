import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:the_silent_voice/main.dart';

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
  Offset getHandleAnchor(
    TextSelectionHandleType type,
    double textLineHeight,
  ) {
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
class Profilepage extends StatefulWidget {
  const Profilepage({super.key});

  @override
  State<Profilepage> createState() => _ProfilepageState();
}

/// ## _ProfilepageState
/// State class for `Profilepage`. Handles editing of user info, theme switching,
/// and taps on settings/preferences.
class _ProfilepageState extends State<Profilepage> {
  bool EditProfileData = false;
  late final TextEditingController UserName;
  late final TextEditingController UserEmail;
  String Name = "User Name";
  String Email = "user@email.com";
  @override
  void initState() {
    super.initState();
    UserName = TextEditingController(text: Name);
    UserEmail = TextEditingController(text: Email);
  }

  @override
  void dispose() {
    UserName.dispose();
    UserEmail.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 18.5,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.blue[800],
                          child: Icon(
                            Icons.camera_alt,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                /// #### User Name TextField / Display
                EditProfileData
                    ? Padding(
                        padding: const EdgeInsets.only(right: 30, left: 30),
                        child: TextField(
                          controller: UserName,
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
                        Name,
                        style: Theme.of(context).textTheme.displaySmall,
                      ),

                const SizedBox(height: 8),
                /// #### User Email TextField / Display
                EditProfileData
                    ? Padding(
                        padding: const EdgeInsets.only(right: 30, left: 30),
                        child: TextField(
                          controller: UserEmail,
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
                    : Text(Email, style: Theme.of(context).textTheme.bodySmall),

                const SizedBox(height: 5),
                /// #### Edit / Save Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.tertiary,
                    overlayColor: Colors.lightBlueAccent,
                  ),
                  onPressed: () async {
                    if (EditProfileData) {
                      setState(() {
                        Name = UserName.text;
                        Email = UserEmail.text;
                      });
                    }

                    setState(() {
                      EditProfileData = !EditProfileData;
                    });
                  },
                  child: Text(
                    EditProfileData ? "Save" : "Edit",
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
                    onTap: (){},
                    child:Row(
                      children: [
                        Icon(Icons.notifications_none),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Notifications',
                            style: Theme.of(context).textTheme.displaySmall,
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.grey[400],
                        ),
                      ],
                    ),
                  )
                ),
                Divider(),
                /// #### Language Row
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
                  child:InkWell(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    onTap: (){},
                    child:Row(
                      children: [
                        Icon(Icons.language_outlined),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Language',
                            style: Theme.of(context).textTheme.displaySmall,
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.grey[400],
                        ),
                      ],
                    ),
                  ) 
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
                    onTap: (){},
                    child:Row(
                      children: [
                        Icon(Icons.privacy_tip_outlined),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Privacy Security',
                            style: Theme.of(context).textTheme.displaySmall,
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.grey[400],
                        ),
                      ],
                    ),
                  )
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
                    onTap: (){},
                    child:Row(
                      children: [
                        Icon(Icons.info_outline_rounded),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'App Information',
                            style: Theme.of(context).textTheme.displaySmall,
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.grey[400],
                        ),
                      ],
                    ),
                  )
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
