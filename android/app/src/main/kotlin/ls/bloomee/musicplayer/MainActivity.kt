package ls.bloomee.musicplayer

import android.content.Intent
import android.net.Uri
import android.os.Handler
import android.os.Looper
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.util.UUID
import java.util.concurrent.Executors
import java.util.concurrent.ConcurrentLinkedQueue

/** Consume document URIs while their grants are valid; Flutter receives private files. */
class MainActivity : AudioServiceActivity() {
    private val downloadStorage by lazy { DownloadStorage(this) }
    private val io = Executors.newSingleThreadExecutor()
    private val main = Handler(Looper.getMainLooper())
    private var channel: MethodChannel? = null
    private val errors = ConcurrentLinkedQueue<String>()
    private val sharedTexts = ConcurrentLinkedQueue<String>()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "ls.bloomee/download_storage")
            .setMethodCallHandler(downloadStorage::handle)
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "ls.bloomee/imports")
        channel!!.setMethodCallHandler { call, result ->
            when (call.method) {
                "texts" -> {
                    val messages = mutableListOf<String>()
                    while (true) { messages.add(sharedTexts.poll() ?: break) }
                    result.success(messages)
                }
                "errors" -> {
                    val messages = mutableListOf<String>()
                    while (true) { messages.add(errors.poll() ?: break) }
                    result.success(messages)
                }
                "pending" -> {
                    val pending = cacheDir.listFiles()?.filter {
                        it.isDirectory && it.name.startsWith("bloomee_import_") && File(it, ".pending").exists()
                    }?.sortedBy { it.lastModified() }?.mapNotNull { dir ->
                        dir.listFiles()?.firstOrNull { it.name != ".pending" }?.absolutePath
                    } ?: emptyList<String>()
                    result.success(pending)
                }
                "acknowledge" -> {
                    val path = call.argument<String>("path")
                    if (path != null) {
                        val parent = File(path).canonicalFile.parentFile
                        if (parent?.parentFile == cacheDir.canonicalFile && parent.name.startsWith("bloomee_import_")) {
                            File(parent, ".pending").delete()
                        }
                    }
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
        receive(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        receive(intent)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (!downloadStorage.onActivityResult(requestCode, resultCode, data)) {
            super.onActivityResult(requestCode, resultCode, data)
        }
    }

    @Suppress("DEPRECATION")
    private fun receive(intent: Intent?) {
        if (intent == null) return
        if (intent.getBooleanExtra("ls.bloomee.imports.received", false)) return
        intent.putExtra("ls.bloomee.imports.received", true)
        val uris: List<Uri> = when (intent.action) {
            Intent.ACTION_VIEW -> listOfNotNull(intent.data)
            Intent.ACTION_SEND -> listOfNotNull(intent.getParcelableExtra<Uri>(Intent.EXTRA_STREAM))
            Intent.ACTION_SEND_MULTIPLE -> intent.getParcelableArrayListExtra<Uri>(Intent.EXTRA_STREAM) ?: emptyList()
            else -> emptyList()
        }
        if (uris.isEmpty() && intent.action == Intent.ACTION_SEND) {
            intent.getStringExtra(Intent.EXTRA_TEXT)?.let {
                sharedTexts.add(it)
                channel?.invokeMethod("available", null)
            }
        }
        for (uri in uris) {
            if (uri.scheme != "content" && uri.scheme != "file") continue
            io.execute {
                val dir = File(cacheDir, "bloomee_import_${UUID.randomUUID()}")
                try {
                    dir.mkdirs()
                    val displayName = runCatching {
                        contentResolver.query(uri, arrayOf(android.provider.OpenableColumns.DISPLAY_NAME), null, null, null)?.use {
                            if (it.moveToFirst()) it.getString(0) else null
                        }
                    }.getOrNull() ?: uri.lastPathSegment ?: "document.json"
                    val safe = displayName.substringAfterLast('/').replace(Regex("[<>:\"/\\\\|?*\\p{Cntrl}]"), "_")
                    val file = File(dir, if (safe.isBlank() || safe == "." || safe == "..") "document.json" else safe)
                    contentResolver.openInputStream(uri)?.use { input ->
                        file.outputStream().use { output ->
                            val buffer = ByteArray(64 * 1024)
                            var total = 0L
                            while (true) {
                                val read = input.read(buffer)
                                if (read < 0) break
                                total += read
                                require(total <= 256L * 1024 * 1024) { "Document exceeds 256 MB" }
                                output.write(buffer, 0, read)
                            }
                            output.fd.sync()
                        }
                    } ?: error("Document provider did not supply a readable stream")
                    File(dir, ".pending").outputStream().use {
                        it.write(byteArrayOf(49))
                        it.fd.sync()
                    }
                    main.post { channel?.invokeMethod("available", null) }
                } catch (error: Exception) {
                    dir.deleteRecursively()
                    errors.add(error.message ?: "Could not read document")
                    main.post { channel?.invokeMethod("available", null) }
                }
            }
        }
    }
}
