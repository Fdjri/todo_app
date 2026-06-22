# Flutter Local Notifications rules
-keep class com.dexterous.** { *; }

# Gson specific rules to prevent "Missing type parameter"
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes *Annotation*

-dontwarn sun.misc.**
-keep class * extends com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# Retain generic signatures for TypeToken
-keep class com.google.gson.reflect.TypeToken { *; }
-keep class * extends com.google.gson.reflect.TypeToken
