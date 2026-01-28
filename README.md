# MediScan

![Flutter](https://img.shields.io/badge/Flutter-Mobile_App-02569B)
![Dart](https://img.shields.io/badge/Dart-Language-0175C2)
![Python](https://img.shields.io/badge/Python-3.10+-3776AB)
![FastAPI](https://img.shields.io/badge/FastAPI-Backend_API-009688)
![PyTorch](https://img.shields.io/badge/PyTorch-Deep_Learning-EE4C2C)
![OpenCV](https://img.shields.io/badge/OpenCV-Image_Processing-green)
![SQLite](https://img.shields.io/badge/SQLite-Database-003B57)

## Overview

MediScan is a medical AI diagnostic assistant designed to aid radiologists and general practitioners. The application bridges the gap in specialist availability by providing instant, explainable detection of Pneumonia in chest X-rays.

The system utilizes a hybrid architecture: a secure Python backend running a fine-tuned ResNet-50 model for heavy inference and Explainable AI (Grad-CAM), paired with a lightweight Flutter mobile application for point-of-care use.

## Project Demo

Click the image below to watch the full demonstration on YouTube:

[![MediScan Demo Video](https://img.youtube.com/vi/4WuUqCWwjPg/0.jpg)](https://www.youtube.com/watch?v=4WuUqCWwjPg)

> *Note: This video demonstrates the live inference pipeline, heatmap generation, and medical reporting workflow.*

## Key Features

*   **AI-Powered Diagnosis:** Utilizes a ResNet-50 Convolutional Neural Network trained on chest X-rays to detect Pneumonia with high confidence.
*   **Explainable AI (XAI):** Generates Visual Heatmaps (Grad-CAM) to overlay on X-rays, allowing doctors to verify which lung regions triggered the AI's prediction.
*   **Medical Reporting:** automatically generates professional PDF reports containing the original X-ray, AI heatmap, patient ID, and doctor's details.
*   **Patient History:** Implements a local SQLite database to track and manage recent patient diagnoses.
*   **Configurable Settings:** Allows customization of doctor profiles and hospital details for personalized reporting.

## Technology Stack

### Backend (The Intelligence Hub)
*   **Framework:** FastAPI (Python 3.10+)
*   **ML Core:** PyTorch, Torchvision
*   **Image Processing:** OpenCV, Numpy
*   **Database:** SQLite with SQLModel (ORM)
*   **Explainability:** pytorch-grad-cam

### Frontend (Mobile Application)
*   **Framework:** Flutter (Dart)
*   **State Management:** Provider
*   **Networking:** Dio (HTTP Client)
*   **Visualization:** fl_chart (Data visualization), photo_view (Zoomable images)
*   **Reporting:** pdf, printing packages

## Architecture

The project follows a clean client-server architecture:

1.  **Mobile App:** Captures the image and sends it via HTTP POST.
2.  **API Gateway:** FastAPI receives the image and preprocesses it (resize, normalize).
3.  **Inference Engine:** The ResNet-50 model predicts the class (Normal vs. Pneumonia) and generates a Grad-CAM heatmap.
4.  **Response:** The backend returns the probability score and a Base64-encoded heatmap image.
5.  **Presentation:** The mobile app decodes the response, displays the visual overlay, and saves the record locally.

## Installation & Setup

### Prerequisites
*   Flutter SDK
*   Python 3.9+
*   Git

### 1. Backend Setup
Navigate to the backend directory and set up the Python environment.

```bash
cd backend
python -m venv venv
source venv/bin/activate  # On Windows use: venv\Scripts\activate
pip install -r requirements.txt
python main.py
```
The server will start at `http://0.0.0.0:8000`
### 2. Frontend Setup
Navigate to the mobile app directory and install dependencies.
```bash
cd mobile_app
flutter pub get
flutter run
```
### 3. Networking (For Physical Devices)
If testing on a physical device, use Ngrok to tunnel the localhost server:
```Bash
ngrok http 8000
```
Update the `api_constants.dart` file in the Flutter project with the generated Ngrok URL.
