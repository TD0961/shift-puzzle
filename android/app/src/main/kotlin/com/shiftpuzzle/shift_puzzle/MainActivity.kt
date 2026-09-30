package com.shiftpuzzle.shift_puzzle

import android.media.AudioAttributes
import android.media.AudioFormat
import android.media.AudioTrack
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executors
import kotlin.math.PI
import kotlin.math.asin
import kotlin.math.exp
import kotlin.math.sin

class MainActivity : FlutterActivity() {
    private val channelName = "com.shiftpuzzle.game/audio"
    private val audioExecutor = Executors.newFixedThreadPool(2)

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName).setMethodCallHandler { call, result ->
            when (call.method) {
                "playTone" -> {
                    val freq = call.argument<Double>("frequency") ?: 440.0
                    val durationMs = call.argument<Double>("durationMs") ?: 100.0
                    val gain = call.argument<Double>("gain") ?: 0.15
                    val type = call.argument<String>("type") ?: "sine"
                    audioExecutor.execute {
                        playPcmTone(freq, durationMs, gain, type)
                    }
                    result.success(true)
                }
                "playChord" -> {
                    val freqs = call.argument<List<Double>>("frequencies") ?: listOf(440.0)
                    val durationMs = call.argument<Double>("durationMs") ?: 400.0
                    val gain = call.argument<Double>("gain") ?: 0.15
                    audioExecutor.execute {
                        playPcmChord(freqs, durationMs, gain)
                    }
                    result.success(true)
                }
                "playApplause" -> {
                    val clapCount = call.argument<Int>("clapCount") ?: 14
                    val durationMs = call.argument<Double>("durationMs") ?: 1300.0
                    audioExecutor.execute {
                        playPcmApplause(clapCount, durationMs)
                    }
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun playPcmTone(frequency: Double, durationMs: Double, gain: Double, type: String) {
        try {
            val sampleRate = 44100
            val totalSamples = ((durationMs / 1000.0) * sampleRate).toInt().coerceAtLeast(100)
            val buffer = ShortArray(totalSamples)
            val attackSamples = (0.005 * sampleRate).toInt().coerceAtLeast(1)

            for (i in 0 until totalSamples) {
                val t = i.toDouble() / sampleRate
                val rawVal = if (type == "triangle") {
                    (2.0 / PI) * asin(sin(2.0 * PI * frequency * t).coerceIn(-1.0, 1.0))
                } else {
                    sin(2.0 * PI * frequency * t)
                }

                // Envelope: quick attack, smooth exponential decay
                val envelope = if (i < attackSamples) {
                    i.toDouble() / attackSamples
                } else {
                    exp(-3.5 * (i - attackSamples) / (totalSamples - attackSamples))
                }

                val sample = (rawVal * envelope * gain * 32767.0).toInt().coerceIn(-32768, 32767).toShort()
                buffer[i] = sample
            }

            playBuffer(buffer, sampleRate)
        } catch (_: Exception) {}
    }

    private fun playPcmChord(frequencies: List<Double>, durationMs: Double, gain: Double) {
        try {
            val sampleRate = 44100
            val totalSamples = ((durationMs / 1000.0) * sampleRate).toInt().coerceAtLeast(100)
            val buffer = ShortArray(totalSamples)
            val attackSamples = (0.008 * sampleRate).toInt().coerceAtLeast(1)
            val count = frequencies.size.coerceAtLeast(1)

            for (i in 0 until totalSamples) {
                val t = i.toDouble() / sampleRate
                var sum = 0.0
                for (f in frequencies) {
                    sum += sin(2.0 * PI * f * t)
                }
                val rawVal = sum / count

                val envelope = if (i < attackSamples) {
                    i.toDouble() / attackSamples
                } else {
                    exp(-2.5 * (i - attackSamples) / (totalSamples - attackSamples))
                }

                val sample = (rawVal * envelope * gain * 32767.0).toInt().coerceIn(-32768, 32767).toShort()
                buffer[i] = sample
            }

            playBuffer(buffer, sampleRate)
        } catch (_: Exception) {}
    }

    private fun playPcmApplause(clapCount: Int, durationMs: Double) {
        try {
            val sampleRate = 44100
            val totalSamples = ((durationMs / 1000.0) * sampleRate).toInt().coerceAtLeast(1000)
            val buffer = ShortArray(totalSamples)
            val totalSec = durationMs / 1000.0
            val random = java.util.Random(42)

            for (c in 0 until clapCount) {
                val baseSec = (c.toDouble() / clapCount) * totalSec
                val jitter = ((c * 37) % 19) / 450.0
                val clapStartSample = (((baseSec + jitter) * sampleRate).toInt()).coerceIn(0, totalSamples - 1)
                val clapDurationSamples = (0.025 * sampleRate).toInt() // 25ms clap burst

                for (s in 0 until clapDurationSamples) {
                    val idx = clapStartSample + s
                    if (idx >= totalSamples) break
                    val env = 1.0 - (s.toDouble() / clapDurationSamples)
                    val noise = (random.nextDouble() * 2.0 - 1.0)
                    val sample = (noise * env * 0.18 * 32767.0).toInt().coerceIn(-32768, 32767).toShort()
                    val existing = buffer[idx].toInt()
                    buffer[idx] = (existing + sample).coerceIn(-32768, 32767).toShort()
                }
            }

            playBuffer(buffer, sampleRate)
        } catch (_: Exception) {}
    }

    private fun playBuffer(buffer: ShortArray, sampleRate: Int) {
        val audioTrack = AudioTrack.Builder()
            .setAudioAttributes(
                AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_GAME)
                    .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                    .build()
            )
            .setAudioFormat(
                AudioFormat.Builder()
                    .setEncoding(AudioFormat.ENCODING_PCM_16BIT)
                    .setSampleRate(sampleRate)
                    .setChannelMask(AudioFormat.CHANNEL_OUT_MONO)
                    .build()
            )
            .setBufferSizeInBytes(buffer.size * 2)
            .setTransferMode(AudioTrack.MODE_STATIC)
            .build()

        audioTrack.write(buffer, 0, buffer.size)
        audioTrack.play()

        val durationMs = (buffer.size.toDouble() / sampleRate * 1000).toLong() + 100
        audioExecutor.execute {
            try {
                Thread.sleep(durationMs)
                audioTrack.stop()
                audioTrack.release()
            } catch (_: Exception) {}
        }
    }
}
