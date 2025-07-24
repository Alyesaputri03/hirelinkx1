import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient supabase = Supabase.instance.client;

  // ------------------------ Upload Gambar ------------------------

  Future<String> uploadImage(
    File file,
    String fileName,
    String bucketName,
  ) async {
    final bytes = await file.readAsBytes();
    await supabase.storage.from(bucketName).uploadBinary(
      fileName,
      bytes,
      fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
    );
    return supabase.storage.from(bucketName).getPublicUrl(fileName);
  }

  Future<String> uploadImageBytes(
    Uint8List bytes,
    String fileName,
    String bucketName,
  ) async {
    await supabase.storage.from(bucketName).uploadBinary(
      fileName,
      bytes,
      fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
    );
    return supabase.storage.from(bucketName).getPublicUrl(fileName);
  }

  // ------------------------ Profiles ------------------------

  Future<Map<String, dynamic>?> getProfile() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return null;

    return await supabase.from('profiles').select().eq('id', userId).single();
  }

  Future<void> updateProfile({
    required String username,
    String? avatarUrl,
    String? title,
    String? noTelp,
    String? emailPesan,
  }) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    await supabase.from('profiles').update({
      'username': username,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (title != null) 'title': title,
      if (noTelp != null) 'no_telp': noTelp,
      if (emailPesan != null) 'email_pesan': emailPesan,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', userId);
  }

  // ------------------------ Generic CRUD ------------------------

  Future<List<Map<String, dynamic>>> getAll(String table) async {
    final data = await supabase
        .from(table)
        .select()
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }

  Future<void> insertRow(String table, Map<String, dynamic> data) async {
    await supabase.from(table).insert(data);
  }

  Future<void> updateRow(
      String table, Map<String, dynamic> data, String id) async {
    await supabase.from(table).update(data).eq('id', id);
  }

  Future<void> deleteRow(String table, String idField, String id) async {
    await supabase.from(table).delete().eq(idField, id);
  }

  Future<void> insert(String table, Map<String, dynamic> data) async {
    await supabase.from(table).insert(data);
  }

  Future<void> delete(String table, String id) async {
    await supabase.from(table).delete().match({'id': id});
  }
}
