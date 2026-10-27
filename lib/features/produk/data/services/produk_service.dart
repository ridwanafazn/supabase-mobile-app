import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/produk_model.dart';

class ProdukService {
  final _client = Supabase.instance.client;

  // 1. READ: Ambil semua produk milik user yang login
  Future<List<ProdukModel>> getProduk() async {
    final response = await _client
        .from('produk')
        .select()
        .order('created_at', ascending: false);

    return (response as List).map((json) => ProdukModel.fromJson(json)).toList();
  }

  // 2. CREATE: Tambah produk baru
  Future<void> insertProduk(ProdukModel produk) async {
    await _client.from('produk').insert(produk.toJson());
  }

  // 3. UPDATE: Ubah produk berdasarkan ID
  Future<void> updateProduk(int id, ProdukModel produk) async {
    await _client.from('produk').update(produk.toJson()).eq('id', id);
  }

  // 4. DELETE: Hapus produk berdasarkan ID
  Future<void> deleteProduk(int id) async {
    await _client.from('produk').delete().eq('id', id);
  }

  // 5. RPC: Contoh panggil function dari Supabase
  Future<int> getTotalProduk() async {
    final response = await _client.rpc('get_total_produk');
    return response as int;
  }
}