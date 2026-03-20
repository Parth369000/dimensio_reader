import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'constants.dart';

class GeminiService {
  late final GenerativeModel _model;

  GeminiService() {
    _model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: Apis.geminiKey);
  }

  Future<List<String>> extractDimensionsFromImage(String imagePath) async {
    try {
      final bytes = await File(imagePath).readAsBytes();

      final prompt = TextPart('''
Analyze this engineering/architectural drawing. 
Extract all visible dimensions such as lengths, breadths, heights, and radii. 
Return ONLY a comma-separated list of the raw dimension strings found. 
For example: 50'-0", 12", 30 cm, 15.5"
Do not include markdown blocks, explanation, headers, or any other text. Only the comma-separated dimensions.
''');

      final imagePart = DataPart(
        'image/jpeg',
        bytes,
      ); // Assumption for generic handling

      final response = await _model.generateContent([
        Content.multi([prompt, imagePart]),
      ]);

      final text = response.text ?? '';
      if (text.trim().isEmpty) return [];

      // Clean and split
      final parts = text.split(',');
      final List<String> result = [];
      for (var p in parts) {
        var clean = p.replaceAll('`', '').trim();
        if (clean.isNotEmpty) {
          result.add(clean);
        }
      }
      return result;
    } catch (e) {
      debugPrint('Gemini API Error: $e');
      return [];
    }
  }

  Future<String?> analyzeElevationDrawing(String imagePath) async {
    try {
      final bytes = await File(imagePath).readAsBytes();

      final prompt = TextPart('''
You are a professional architectural elevation analysis engine.

Analyze the uploaded 2D architectural elevation drawing carefully.

Your task is to extract ALL explicitly visible structural, dimensional, and visual information and return a complete structured JSON suitable for parametric 3D reconstruction and architectural inventory analysis.

CRITICAL RULES:
- Extract ONLY explicitly visible and labeled dimensions.
- DO NOT estimate or assume missing measurements.
- If a value is not clearly visible, return null.
- Count all visible structural elements.
- Separate left, center, and right elements if distinguishable.
- Identify repeated patterns.
- Return STRICT JSON only.
- No explanation.
- No markdown.
- No extra text.

Return JSON in the following format:

{
  "metadata": {
    "structure_type": string or null,
    "symmetrical": boolean or null,
    "units": string or null
  },

  "overall_dimensions": {
    "total_height": number or null,
    "total_width": number or null,
    "total_depth": number or null
  },

  "section_dimensions": {
    "base_height": number or null,
    "mid_section_height": number or null,
    "upper_section_height": number or null,
    "roof_height": number or null,
    "parapet_height": number or null
  },

  "inventory_counts": {
    "total_pillars": number or 0,
    "left_side_pillars": number or 0,
    "right_side_pillars": number or 0,
    "center_pillars": number or 0,
    "total_arches": number or 0,
    "total_openings": number or 0,
    "total_windows": number or 0,
    "total_doors": number or 0,
    "total_roofs": number or 0,
    "decorative_elements": number or 0
  },

  "elements": [
    {
      "type": "pillar | arch | opening | window | door | roof | wall | decorative_block | other",
      "subtype": string or null,
      "position": "left | center | right | multiple | unknown",
      "count": number or 1,
      "dimensions": {
        "width": number or null,
        "height": number or null,
        "depth": number or null
      },
      "shape": string or null,
      "notes": string or null
    }
  ],

  "roof_details": {
    "roof_type": string or null,
    "number_of_slopes": number or null,
    "has_parapet": boolean or null,
    "has_central_top_block": boolean or null
  },

  "symmetry_analysis": {
    "is_symmetrical": boolean or null,
    "axis": "vertical | horizontal | none | unknown"
  },

  "visual_features": {
    "has_central_gap": boolean or null,
    "has_arched_openings": boolean or null,
    "has_sloped_roof": boolean or null,
    "has_multiple_levels": boolean or null
  },

  "confidence_score": number between 0 and 1
}

If the output is not valid JSON, regenerate until it is valid JSON.
''');

      final imagePart = DataPart('image/jpeg', bytes);

      final response = await _model.generateContent([
        Content.multi([prompt, imagePart]),
      ]);

      String jsonText = response.text ?? '';

      // Clean potential markdown json wrapper
      if (jsonText.startsWith('```json')) {
        jsonText = jsonText.substring(7);
      } else if (jsonText.startsWith('```')) {
        jsonText = jsonText.substring(3);
      }
      if (jsonText.endsWith('```')) {
        jsonText = jsonText.substring(0, jsonText.length - 3);
      }

      return jsonText.trim();
    } catch (e) {
      debugPrint('Gemini Analyze API Error: $e');
      return null;
    }
  }

  Future<String?> generateMaterialUsageSuggestion(
    String imagePath,
    String blocksData,
    String? parsedJson,
    String? designDimensions,
  ) async {
    try {
      final bytes = await File(imagePath).readAsBytes();

      final prompt = TextPart('''
Act as a precise High-Accuracy Construction Estimator and Mathematical Analysis Engine.

CONTEXT:
1. DESIGN INPUT (Image): The uploaded image has specific architectural design sizes labeled on it (e.g., "Wall: 10ft", "Pillar: 2ft").
2. YOUR AVAILABLE MATERIAL (Blocks): The user is building a model using blocks with these dimensions: $blocksData

DESIGN METADATA (Landed from OCR/JSON):
- Design Dimensions Extracted from Image: ${designDimensions ?? 'No direct dimensions provided. Read them from the image.'}
- Structural JSON Breakdown: ${parsedJson ?? 'Read structural components from image.'}

YOUR TASK:
Calculate EXACTLY how many of the USER'S BLOCKS (from the provided list) are needed to construct the design shown in the drawing.

REQUIRED ANALYSIS & OUTPUT SECTIONS:
1. <h3>Design Measurement Mapping</h3>
   <p>List the key design dimensions detected in the image (e.g., Main Wall: 12ft, Column: 8ft).</p>
2. <h3>Mathematical Deduction</h3>
   <p>For each major component, show the math: <b>(Design Dimension / Block Dimension) = Count</b>.
   <i>Example: 144" Wall / 12" Block = 12 Blocks vertically.</i></p>
3. <h3>Component Inventory</h3>
   <ul>
     <li><b>[Part Name]</b>: [Block Name] x [Exact Quantity]</li>
   </ul>
4. <h3>Structural Summary</h3>
   <p><b>Total Blocks Required:</b> [Number]</p>
   <p><b>Recommended Layout:</b> [How to orient the blocks for maximum stability].</p>

STRICT FORMATTING RULES:
- RETURN THE ENTIRE RESPONSE AS PURE HTML.
- DO NOT use any Markdown (no **, no ##, no backticks).
- Use <h3> for headers.
- Use <b> and <i> for emphasis.
- Use <ul> and <li> for lists.
- Be precise. Accuracy is critical for a physical build.
''');

      final imagePart = DataPart('image/jpeg', bytes);

      final response = await _model.generateContent([
        Content.multi([prompt, imagePart]),
      ]);

      return response.text?.trim();
    } catch (e) {
      debugPrint('Gemini Suggestion API Error: $e');
      return null;
    }
  }

  Future<String?> calculateOccupiedArea(
    String imagePath,
    String blocksData,
    String? parsedJson,
  ) async {
    try {
      final bytes = await File(imagePath).readAsBytes();

      final prompt = TextPart('''
Act as a precise Architectural Area Calibration Engine.

The user has placed 3D blocks (virtual representation) onto an architectural plan.
Blocks dimensions provided by user: $blocksData

Structural Context: ${parsedJson ?? 'Analyze from image.'}

YOUR TASK:
Calculate the TOTAL OCCUPIED FOOTPRINT AREA and TOTAL SURFACE AREA that these blocks would occupy in the physical world if built at the scale shown in the drawing.

REQUIRED MATH:
1. **Footprint Area**: Calculate the Base Area (Length x Breadth) for each block and sum them up.
2. **Surface Area**: Calculate the total exterior surface area (2*(LB + BH + LH)) for each block.
3. **Volume**: Total displacement volume.
4. **Design Ratio**: Compare this occupied area to the total design area of the structure shown in the image.

FORMAT:
- RETURN THE ENTIRE RESPONSE IN CLEAN HTML FORMAT.
- Use <h3> for headers, <p> for text, <ul>/<li> for lists, and <b>/<i> for emphasis.
- DO NOT use markdown, ONLY HTML.

STRICT RULES:
- Use exact mathematical formulas.
- No markdown code blocks.
''');

      final imagePart = DataPart('image/jpeg', bytes);

      final response = await _model.generateContent([
        Content.multi([prompt, imagePart]),
      ]);

      return response.text?.trim();
    } catch (e) {
      debugPrint('Gemini Area API Error: $e');
      return null;
    }
  }
}
