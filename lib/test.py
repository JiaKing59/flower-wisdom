import sys
import os
import numpy as np
import cv2
import torch
from torchvision.transforms import transforms
from PyQt5 import QtCore, QtGui, QtWidgets


# Define class names
class_names = ['Chysanthermun flower','Lily flower','Lotus flower','Rafflesia flower','Rose flower','Tulip flower']

class MainWindow(QtWidgets.QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Image Classifier")
        self.setWindowIcon(QtGui.QIcon("icon.png"))
        self.setGeometry(100, 100, 600, 700)  # Change the width and height

        # Create widgets
        self.image_label = QtWidgets.QLabel(self)
        self.image_label.setGeometry(QtCore.QRect(50, 50, 500, 500))
        self.image_label.setStyleSheet("background-color: black; border: 1px solid black;")
        self.select_button = QtWidgets.QPushButton("Select Image", self)
        self.select_button.setGeometry(QtCore.QRect(200, 580, 200, 50))  # Increase the size of the button
        self.select_button.setStyleSheet("background-color: #5cb85c; color: white; font-size: 20px; font-weight: bold;")
        self.select_button.clicked.connect(self.select_image)

        # Create label for prediction result
        self.prediction_label = QtWidgets.QLabel(self)
        self.prediction_label.setGeometry(QtCore.QRect(50, 650, 500, 50))  # Center the label
        self.prediction_label.setAlignment(QtCore.Qt.AlignCenter)
        self.prediction_label.setStyleSheet("font-size: 28px; font-weight: bold;")

        # Load model
        self.model = torch.load("flower_pytorch_C1.pt")
        self.model.eval()

        # Set application style sheet
        self.setStyleSheet("QMainWindow {background-color: white; font-family: Arial, sans-serif;}")



    def select_image(self):
        # Open file dialog to select image
        file_dialog = QtWidgets.QFileDialog()
        file_dialog.setNameFilters(["Images (*.png *.xpm *.jpg *.bmp)"])
        file_dialog.selectNameFilter("Images (*.png *.xpm *.jpg *.bmp)")
        file_path = ""
        if file_dialog.exec_():
            file_path = file_dialog.selectedFiles()[0]

        if file_path:
            # Load and preprocess image
            image = cv2.imread(file_path)
            image = cv2.resize(image, (224, 224))
            image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
            image = image.astype(np.float32) / 255.0

            # Apply transforms
            transform = transforms.Compose([
                transforms.ToTensor(),
                transforms.Normalize(mean=[0.485, 0.456, 0.406],
                         std=[0.229, 0.224, 0.225])
                ])
            image = transform(image)
            image = image.unsqueeze(0)


            # Make prediction
            with torch.no_grad():
                prediction = self.model(image)
            prediction = prediction.argmax().item()
            prediction_name = class_names[prediction]

            # Display image and prediction result
            pixmap = QtGui.QPixmap(file_path)
            self.image_label.setPixmap(pixmap.scaled(650, 650, QtCore.Qt.KeepAspectRatio))
            self.prediction_label.setText(f"Prediction: {prediction_name}")


if __name__ == "__main__":
    # Create application and window
    app = QtWidgets.QApplication(sys.argv)

    # Set application style sheet
    app.setStyleSheet("QMainWindow {background-color: white;}")

    # Create window
    window = MainWindow()
    window.show()

    # Run application
    sys.exit(app.exec_())