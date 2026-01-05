import os
import torch
import torch.nn as nn
from torchvision import models, transforms
from PIL import Image
import numpy as np
import cv2
import base64
from pytorch_grad_cam import GradCAM
from pytorch_grad_cam.utils.model_targets import ClassifierOutputTarget
from pytorch_grad_cam.utils.image import show_cam_on_image
from io import BytesIO

# Configuration
WEIGHTS_PATH = os.path.join("ml_resources", "weights", "mediscan_resnet50.pt")
DEVICE = torch.device("cpu") # Force CPU for local dev

class MLService:
    def __init__(self):
        self.model = None
        self.cam = None
        self._load_model()

    def _load_model(self):
        print("Loading MediScan Model...")
        try:
            self.model = models.resnet50(pretrained=False) # No need to download ImageNet weights again
            num_ftrs = self.model.fc.in_features
            
            # Reconstruct the head
            self.model.fc = nn.Sequential(
                nn.Linear(num_ftrs, 512),
                nn.ReLU(),
                nn.Dropout(0.3),
                nn.Linear(512, 2)
            )
            # Load weights
            self.model.load_state_dict(torch.load(WEIGHTS_PATH, map_location=DEVICE))
            self.model.eval() # Set to evaluation mode
            
            # Setup Grad-CAM
            target_layers = [self.model.layer4[-1]]
            self.cam = GradCAM(model=self.model, target_layers=target_layers)
            
            print("✅ Model Loaded Successfully!")
        except Exception as e:
            print(f"❌ Error loading model: {e}")
            raise e

    def preprocess_image(self, image_bytes):
        """Convert raw bytes to Tensor"""
        # Load image from bytes
        img = Image.open(BytesIO(image_bytes)).convert('RGB')
        
        # Define the exact transforms used in validation
        preprocess = transforms.Compose([
            transforms.Resize((224, 224)),
            transforms.ToTensor(),
            transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225])
        ])
        
        input_tensor = preprocess(img).unsqueeze(0) # Add batch dimension
        return input_tensor, np.array(img.resize((224, 224))) / 255.0

    def predict(self, image_bytes):
        """
        Returns:
        - probability (float)
        - prediction (str)
        - heatmap_base64 (str)
        """
        input_tensor, original_img_np = self.preprocess_image(image_bytes)
        
        # 1. Inference
        with torch.no_grad():
            outputs = self.model(input_tensor)
            probabilities = torch.nn.functional.softmax(outputs, dim=1)
            # Assuming Class 0 = NORMAL, Class 1 = PNEUMONIA
            pneumonia_prob = probabilities[0][1].item()
        
        predicted_class = "PNEUMONIA" if pneumonia_prob > 0.5 else "NORMAL"

        # 2. Generate Heatmap (Explainability)
        # We target the 'Pneumonia' class (1) to see what looks like pneumonia
        targets = [ClassifierOutputTarget(1)]
        
        # Generate raw grayscale cam
        grayscale_cam = self.cam(input_tensor=input_tensor, targets=targets)
        grayscale_cam = grayscale_cam[0, :]
        
        # Overlay heatmap on original image
        visualization = show_cam_on_image(original_img_np, grayscale_cam, use_rgb=True)
        
        # 3. Convert Heatmap to Base64 string for frontend
        viz_img = Image.fromarray(visualization)
        buffered = BytesIO()
        viz_img.save(buffered, format="JPEG")
        heatmap_b64 = base64.b64encode(buffered.getvalue()).decode('utf-8')

        return {
            "prediction": predicted_class,
            "confidence": float(pneumonia_prob),
            "heatmap_base64": heatmap_b64
        }

# Create a singleton instance
ml_service = MLService()