package dk.parkingson.parkingson

import android.content.Context
import android.media.AudioAttributes
import android.media.AudioManager
import android.speech.tts.TextToSpeech
import java.util.Locale

/**
 * Speaks the alarm voice reminder on the ALARM audio stream (at full alarm
 * volume) so it is as loud as the alarm sound — unlike flutter_tts, which
 * plays on the media stream.
 */
object Speaker {
    private var tts: TextToSpeech? = null
    private var ready = false
    private var queued: Pair<String, String>? = null

    fun speak(context: Context, text: String, langTag: String) {
        val appContext = context.applicationContext

        // Make sure the alarm stream is at full volume for a loud voice.
        val am = appContext.getSystemService(AudioManager::class.java)
        am?.setStreamVolume(
            AudioManager.STREAM_ALARM,
            am.getStreamMaxVolume(AudioManager.STREAM_ALARM),
            0
        )

        val engine = tts
        if (engine != null && ready) {
            doSpeak(engine, text, langTag)
            return
        }

        queued = text to langTag
        if (engine == null) {
            tts = TextToSpeech(appContext) { status ->
                ready = status == TextToSpeech.SUCCESS
                if (ready) {
                    tts?.setAudioAttributes(
                        AudioAttributes.Builder()
                            .setUsage(AudioAttributes.USAGE_ALARM)
                            .setContentType(AudioAttributes.CONTENT_TYPE_SPEECH)
                            .build()
                    )
                    queued?.let { doSpeak(tts!!, it.first, it.second) }
                    queued = null
                }
            }
        }
    }

    private fun doSpeak(engine: TextToSpeech, text: String, langTag: String) {
        try {
            engine.language = Locale.forLanguageTag(langTag)
        } catch (_: Exception) {
        }
        engine.setSpeechRate(1.0f)
        engine.speak(text, TextToSpeech.QUEUE_FLUSH, null, "parkingson-voice")
    }
}
