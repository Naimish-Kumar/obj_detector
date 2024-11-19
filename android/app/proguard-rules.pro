
-keep class com.google.android.gms.auth.api.credentials.* { *; }
-keep class com.google.android.gms.* { *; }
-dontwarn com.google.android.gms.**
-keep class com.google.mlkit.vision.text.** { *; }
-keep class com.google.mlkit.common.** { *; }
-keep class com.google.mlkit.vision.text.chinese.** { *; }
-keep class com.google.mlkit.vision.text.devanagari.** { *; }
-keep class com.google.mlkit.vision.text.japanese.** { *; }
-keep class com.google.mlkit.vision.text.korean.** { *; }
-keep class com.google.mlkit.vision.text.chinese.ChineseTextRecognizerOptions { *; }
-keep class com.google.mlkit.vision.text.devanagari.DevanagariTextRecognizerOptions { *; }
-keep class com.google.mlkit.vision.text.chinese.ChineseTextRecognizerOptions$Builder { *; }
-keep class com.google.mlkit.vision.text.devanagari.DevanagariTextRecognizerOptions$Builder { *; }
-keep class com.google.mlkit.vision.text.japanese.** { *; }
-keep class com.google.mlkit.vision.text.korean.** { *; }
-keep class com.google.mlkit.vision.text.japanese.JapaneseTextRecognizerOptions { *; }
-keep class com.google.mlkit.vision.text.korean.KoreanTextRecognizerOptions { *; }
-keep class com.google.mlkit.** { *; }
-keep class com.google.firebase.ml.** { *; }
-keep class com.google.android.gms.** { *; }

# Prevent obfuscation of ML Kit text recognition models
-keep class com.google.mlkit.vision.text.** { *; }

# Keep native ML Kit text recognizers
-keep class com.google.mlkit.vision.text.chinese.** { *; }
-keep class com.google.mlkit.vision.text.devanagari.** { *; }
-keep class com.google.mlkit.vision.text.japanese.** { *; }
-keep class com.google.mlkit.vision.text.korean.** { *; }


