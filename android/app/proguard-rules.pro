# just_audio & ExoPlayer
-keep class com.ryanheise.just_audio.** { *; }
-keep class com.google.android.exoplayer2.** { *; }

-dontwarn com.ryanheise.just_audio.**
-dontwarn com.google.android.exoplayer2.**

# AndroidX Media3 (new ExoPlayer namespace)
-keep class androidx.media3.** { *; }
-dontwarn androidx.media3.**
