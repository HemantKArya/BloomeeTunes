package ls.bloomee.musicplayer

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.Handler
import android.os.Looper
import android.provider.DocumentsContract
import android.util.AtomicFile
import android.webkit.MimeTypeMap
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject
import java.io.File
import java.util.concurrent.Executors

/** SAF works from API 21 onward without broad storage permissions. */
class DownloadStorage(private val activity: Activity) {
    companion object { const val PICK_FOLDER = 49261 }
    private var picker: MethodChannel.Result? = null
    private val io = Executors.newSingleThreadExecutor()
    private val main = Handler(Looper.getMainLooper())
    private val resolver get() = activity.contentResolver

    fun handle(call: MethodCall, result: MethodChannel.Result) {
        if (call.method == "pick") {
            if (picker != null) {
                result.error("busy", "Folder picker is already open", null)
                return
            }
            picker = result
            try {
                activity.startActivityForResult(Intent(Intent.ACTION_OPEN_DOCUMENT_TREE).apply {
                    addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION or
                        Intent.FLAG_GRANT_WRITE_URI_PERMISSION or
                        Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION or
                        Intent.FLAG_GRANT_PREFIX_URI_PERMISSION)
                }, PICK_FOLDER)
            } catch (e: Exception) {
                picker = null
                result.error("folder_picker", e.message, null)
            }
            return
        }
        if (call.method !in setOf("publish", "exists", "delete")) {
            result.notImplemented()
            return
        }
        io.execute {
            try {
                val value: Any? = when (call.method) {
                    "publish" -> publish(requireNotNull(call.argument<String>("path")))
                    "exists" -> {
                        val uri = Uri.parse(requireNotNull(call.argument<String>("uri")))
                        // Missing or revoked documents are unavailable, not stale DB rows.
                        runCatching { resolver.openFileDescriptor(uri, "r")?.use { true } ?: false }
                            .getOrDefault(false)
                    }
                    else -> {
                        check(DocumentsContract.deleteDocument(resolver,
                            Uri.parse(requireNotNull(call.argument<String>("uri"))))) {
                            "Document provider could not delete the file"
                        }
                        null
                    }
                }
                main.post { result.success(value) }
            } catch (e: Exception) {
                main.post { result.error("download_storage", e.message, null) }
            }
        }
    }

    fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode != PICK_FOLDER) return false
        val result = picker
        picker = null
        if (result == null) return true
        val uri = data?.data
        if (resultCode != Activity.RESULT_OK || uri == null) {
            result.success(null)
            return true
        }
        try {
            val flags = data.flags and (Intent.FLAG_GRANT_READ_URI_PERMISSION or
                Intent.FLAG_GRANT_WRITE_URI_PERMISSION)
            check(flags and Intent.FLAG_GRANT_WRITE_URI_PERMISSION != 0) {
                "The selected folder is read-only"
            }
            resolver.takePersistableUriPermission(uri, flags)
            result.success(uri.toString())
        } catch (e: Exception) {
            result.error("folder_permission", e.message, null)
        }
        return true
    }

    private fun publish(path: String): String {
        val file = File(path).canonicalFile
        val dir = requireNotNull(file.parentFile)
        val root = File(activity.filesDir, "download_staging").canonicalFile
        require(dir.parentFile == root) { "Invalid download staging path" }
        val journalFile = AtomicFile(File(dir, "destination.json"))
        val journal = JSONObject(journalFile.openRead().bufferedReader().use { it.readText() })
        if (journal.optBoolean("complete")) return journal.getString("document")
        val tree = Uri.parse(journal.getString("tree"))
        val parent = DocumentsContract.buildDocumentUriUsingTree(tree, DocumentsContract.getTreeDocumentId(tree))
        val document = if (journal.has("document")) Uri.parse(journal.getString("document")) else {
            val mime = MimeTypeMap.getSingleton().getMimeTypeFromExtension(file.extension.lowercase())
                ?: "application/octet-stream"
            requireNotNull(DocumentsContract.createDocument(resolver, parent, mime, file.name))
                .also {
                    // Persist the URI before copying. Retries overwrite only this task's
                    // document and never another song with the same display name.
                    journal.put("document", it.toString())
                    saveJournal(journalFile, journal)
                }
        }
        resolver.openOutputStream(document, "wt")?.use { output ->
            file.inputStream().use { it.copyTo(output) }
        } ?: error("Document provider did not supply a writable stream")
        journal.put("complete", true)
        saveJournal(journalFile, journal)
        return document.toString()
    }

    private fun saveJournal(file: AtomicFile, json: JSONObject) {
        val output = file.startWrite()
        try {
            output.write(json.toString().toByteArray(Charsets.UTF_8))
            file.finishWrite(output)
        } catch (e: Exception) {
            file.failWrite(output)
            throw e
        }
    }
}
