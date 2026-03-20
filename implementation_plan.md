# Implementation Plan: High-Precision Physical Model Estimator

The goal is to provide a highly accurate prediction of how many physical blocks (of sizes provided by the user) are required to build a structure shown in an uploaded image (which contains its own design dimensions).

## 1. Data Collection Strategy
- **Image Design (Source)**: Extract dimensions from the uploaded drawing using Gemini Vision and OCR.
- **Physical Blocks (Units)**: User inputs the dimensions of the blocks/materials they actually have (Length, Breadth, Height).
- **Structural Analysis**: Run a preliminary JSON elevation analysis to identify discrete parts (Walls, Windows, Pillars).

## 2. Mathematical Prediction Engine
We will utilize Gemini with a "Systematic Construction Thinking" prompt:
- **Volumetric Computation**: If the user provides 3D block sizes, the AI will calculate the volume of structural elements (Walls, Columns) and divide by the block volume.
- **Surface Area Computation**: For sheets or cladding, it will use area division.
- **Gaps & Wastage**: The AI will be instructed to subtract "Voids" (Windows/Doors) and add a wastage buffer (5-10%).

## 3. UI/UX Refinements
- **Material Inventory Section**: Clear labeling in the UI to distinguish between "Extracted Dimensions" (from image) and "Your Blocks" (physical material).
- **Step-by-Step Flow**:
    1. Upload Image.
    2. Extract Design Sizes (AI automatically reads the numbers on the image).
    3. Input your Block Size.
    4. Click "Render & Predict" to see the inventory list.

## 4. Verification & Accuracy
- **Math Verification**: Prompt Gemini to show the "Step-by-step math" (e.g., `Total Area / Block Area`).
- **Unit Normalization**: Ensure all units (inches, cm) are normalized to one standard before calculation.

## 5. Technical Implementation Steps
1. **Gemini Service**: Refine `generateMaterialUsageSuggestion` to strictly require the Image Dimensions vs Block Dimensions comparison.
2. **App Controller**: Ensure the results from `analyzeElevation` are cached and passed as a context to the suggestion engine.
3. **Home Screen**: Add a "Prediction Status" indicator to show the user that the math is being calculated.
