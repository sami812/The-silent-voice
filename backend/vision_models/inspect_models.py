import tensorflow as tf
import os

def check_tflite_model(file_name):
    print(f"\n--- Checking TFLite Model: {file_name} ---")
    if not os.path.exists(file_name):
        print(f"Error: {file_name} not found!")
        return

    interpreter = tf.lite.Interpreter(model_path=file_name)
    interpreter.allocate_tensors()
    
    inputs = interpreter.get_input_details()
    outputs = interpreter.get_output_details()
    
    print(f"Input Shape: {inputs[0]['shape']}")
    print(f"Output Shape: {outputs[0]['shape']}")

if __name__ == "__main__":
    check_tflite_model('1_vision_models/SignLanguage.tflite')