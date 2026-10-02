package com.seoulfm.seoulfm

import android.content.ContentProvider
import android.content.ContentValues
import android.database.Cursor
import android.net.Uri
import android.os.ParcelFileDescriptor
import java.io.File
import java.io.FileNotFoundException
import java.net.HttpURLConnection
import java.net.URL
import java.security.MessageDigest

/**
 * Covers for Android Auto and Android Automotive. Their media screens only load artwork from
 * content:// URIs the app serves, never from the web, so the radio hands them
 * `content://com.seoulfm.seoulfm.art/cover?u=<https url>` and this downloads the cover once, keeps
 * it in the cache and serves the file. Only https images: it is not a general-purpose proxy.
 */
class ArtProvider : ContentProvider() {
  override fun onCreate() = true

  override fun getType(uri: Uri) = "image/jpeg"

  override fun openFile(uri: Uri, mode: String): ParcelFileDescriptor {
    if (mode != "r") throw SecurityException("read only")
    val source = uri.getQueryParameter("u") ?: throw FileNotFoundException("no u")
    if (!source.startsWith("https://")) throw FileNotFoundException("https only")
    val dir = File(context!!.cacheDir, "car-art").apply { mkdirs() }
    val file = File(dir, sha1(source))
    if (!file.exists() || file.length() == 0L) download(source, file)
    return ParcelFileDescriptor.open(file, ParcelFileDescriptor.MODE_READ_ONLY)
  }

  /** Runs on the caller's binder thread (never the main one), so a blocking download is fine. */
  private fun download(source: String, file: File) {
    val conn = URL(source).openConnection() as HttpURLConnection
    try {
      conn.connectTimeout = 8000
      conn.readTimeout = 10000
      conn.instanceFollowRedirects = true
      if (conn.responseCode != 200) throw FileNotFoundException("HTTP ${conn.responseCode}")
      val type = conn.contentType ?: ""
      if (!type.startsWith("image/")) throw FileNotFoundException("not an image: $type")
      // Write beside, then rename: a reader never sees half a file.
      val part = File(file.parentFile, file.name + ".part")
      conn.inputStream.use { input -> part.outputStream().use { input.copyTo(it) } }
      if (!part.renameTo(file)) throw FileNotFoundException("cache write failed")
    } finally {
      conn.disconnect()
    }
    trim(file.parentFile!!)
  }

  /** Keeps the cache to the most recent 200 covers. */
  private fun trim(dir: File) {
    val files = dir.listFiles { f -> !f.name.endsWith(".part") } ?: return
    if (files.size <= 200) return
    files.sortedBy { it.lastModified() }.take(files.size - 200).forEach { it.delete() }
  }

  private fun sha1(s: String) =
    MessageDigest.getInstance("SHA-1").digest(s.toByteArray()).joinToString("") { "%02x".format(it) }

  override fun query(uri: Uri, projection: Array<String>?, selection: String?, selectionArgs: Array<String>?, sortOrder: String?): Cursor? = null
  override fun insert(uri: Uri, values: ContentValues?): Uri? = null
  override fun delete(uri: Uri, selection: String?, selectionArgs: Array<String>?) = 0
  override fun update(uri: Uri, values: ContentValues?, selection: String?, selectionArgs: Array<String>?) = 0
}
