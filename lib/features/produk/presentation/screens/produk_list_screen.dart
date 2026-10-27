import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/produk_model.dart';
import '../../data/services/produk_service.dart';
import 'produk_form_screen.dart';


class ProdukListScreen extends StatefulWidget {
  const ProdukListScreen({super.key});

  @override
  State<ProdukListScreen> createState() => _ProdukListScreenState();
}

class _ProdukListScreenState extends State<ProdukListScreen> {
  final _produkService = ProdukService();
  List<ProdukModel> _produkList = [];
  int _totalProduk = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _produkService.getProduk(),
        _produkService.getTotalProduk(),
      ]);

      setState(() {
        _produkList = results[0] as List<ProdukModel>;
        _totalProduk = results[1] as int;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteProduk(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Produk?'),
        content: const Text('Data yang dihapus tidak dapat dikembalikan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _produkService.deleteProduk(id);
        // Pindahkan pengecekan mounted ke sini, sebelum menggunakan context
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Produk berhasil dihapus')),
          );
          _loadData();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menghapus: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Produk Saya',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800),
        ),
        actions: [
                    IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: () async {
              // Tangkap router SEBELUM await
              final router = GoRouter.of(context); 
              
              await Supabase.instance.client.auth.signOut();
              
              // Gunakan router yang sudah ditangkap tadi
              router.go('/login');
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    'Total data dari RPC: $_totalProduk produk',
                    style: const TextStyle(color: Colors.black54, fontSize: 14),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: _produkList.isEmpty
                      ? const Center(child: Text('Belum ada produk. Silakan tambah.'))
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          itemCount: _produkList.length,
                          separatorBuilder: (_, _) => const Divider(),
                          itemBuilder: (context, index) {
                            final produk = _produkList[index];
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                produk.nama,
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                              ),
                              subtitle: Text(
                                'Rp ${produk.harga.toStringAsFixed(0)}',
                                style: const TextStyle(fontSize: 14, color: Colors.black87),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined),
                                    onPressed: () {
                                      // Nanti kita arahkan ke halaman Edit
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                                    onPressed: () => _deleteProduk(produk.id),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        onPressed: () async {
          // Buka form tambah
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProdukFormScreen()),
          );
          // Jika form berhasil disimpan (result == true), refresh list
          if (result == true) _loadData();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}