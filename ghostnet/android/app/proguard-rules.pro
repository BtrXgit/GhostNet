# Flutter rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Flutter V2Ray Core rules
-keep class com.github.flutter_v2ray.** { *; }
-keep class com.v2ray.core.** { *; }
-keep class go.Seq** { *; }
-keepclassmembers class * {
    native <methods>;
}

-keepclassmembers class * implements java.io.Serializable {
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

-dontwarn go.Seq
-dontwarn com.v2ray.core.**
-dontwarn com.google.android.play.core.**
