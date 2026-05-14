import 'package:image_picker/image_picker.dart';
/// ### pickImage
/// Opens the image picker for the given [source] (`camera` or `gallery`) 
/// and returns the selected image as `Uint8List`.  
/// Returns `null` if no image was selected.
pickImage(ImageSource source)async{
  // ### Create ImagePicker instance
  final ImagePicker imagePicker = ImagePicker();
  // ### Pick an image from the given source
  XFile? file = await imagePicker.pickImage(source: source,imageQuality: 30);
  // ### If an image was selected, read it as bytes and return
  if(file != null){
    return await file.readAsBytes();
  }
  // ### No image selected
  return null;
}