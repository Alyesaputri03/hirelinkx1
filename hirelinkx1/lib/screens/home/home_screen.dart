import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'detail_loker_screen.dart';
import 'menu.dart';
import 'user_sidebar.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onProfileUpdated;

  const HomeScreen({super.key, required this.onProfileUpdated});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final supabase = Supabase.instance.client;
  List<dynamic> _onsiteJobs = [];
  List<dynamic> _remoteJobs = [];
  List<dynamic> _filteredOnsiteJobs = [];
  List<dynamic> _filteredRemoteJobs = [];
  final TextEditingController _searchController = TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    fetchLoker();
    _searchController.addListener(_filterJobs);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchLoker() async {
    try {
      final response = await supabase
          .from('loker')
          .select('*, kategori(nama)')
          .order('created_at', ascending: false);

      setState(() {
        _onsiteJobs = response.where((job) => job['tipe']?.toLowerCase() == 'onsite').toList();
        _remoteJobs = response.where((job) => job['tipe']?.toLowerCase() == 'remote').toList();
        _filteredOnsiteJobs = List.from(_onsiteJobs);
        _filteredRemoteJobs = List.from(_remoteJobs);
        _loading = false;
      });
    } catch (e) {
      print('Error fetching loker: $e');
      setState(() {
        _loading = false;
      });
    }
  }

  void _filterJobs() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredOnsiteJobs = _onsiteJobs.where((job) {
        final jabatan = job['jabatan']?.toLowerCase() ?? '';
        final tempat = job['tempat']?.toLowerCase() ?? '';
        return jabatan.contains(query) || tempat.contains(query);
      }).toList();

      _filteredRemoteJobs = _remoteJobs.where((job) {
        final jabatan = job['jabatan']?.toLowerCase() ?? '';
        final tempat = job['tempat']?.toLowerCase() ?? '';
        return jabatan.contains(query) || tempat.contains(query);
      }).toList();
    });
  }

  Widget _buildTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.blue, fontSize: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 47, 147, 254),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color.fromARGB(255, 255, 255, 255)),
        title: Row(
          children: [
            const Spacer(),
            const Text(
              'HireLink',
              style: TextStyle(
                color: Color.fromARGB(255, 255, 255, 255),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
      drawer: UserSidebar(onProfileUpdated: widget.onProfileUpdated),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Field
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari jabatan atau tempat...',
                      hintStyle: const TextStyle(color: Colors.black45),
                      prefixIcon: const Icon(Icons.search, color: Colors.blue),
                      filled: true,
                      fillColor: Colors.blue[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'On-site Job',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_filteredOnsiteJobs.isEmpty)
                    const Text(
                      'Tidak ada loker On-site.',
                      style: TextStyle(color: Colors.black45),
                    )
                  else
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _filteredOnsiteJobs.length,
                        itemBuilder: (context, index) {
                          final job = _filteredOnsiteJobs[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DetailLokerScreen(loker: job),
                                ),
                              );
                            },
                            child: Container(
                              width: 290,
                              margin: const EdgeInsets.only(right: 16),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: job['gambar'] != null
                                            ? Image.network(
                                                job['gambar'],
                                                width: 40,
                                                height: 40,
                                                fit: BoxFit.cover,
                                              )
                                            : const Icon(Icons.image,
                                                size: 40, color: Colors.blue),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              job['jabatan'] ?? '',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: Colors.black,
                                              ),
                                            ),
                                            Text(
                                              job['tempat'] ?? '',
                                              style: const TextStyle(
                                                  color: Colors.black54),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 4,
                                    children: [
                                      _buildTag(job['kategori']?['nama'] ?? ''),
                                      _buildTag(job['detail'] ?? ''),
                                    ],
                                  ),
                                  const Spacer(),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '\$${job['gaji'] ?? '0'},00/year',
                                        style: const TextStyle(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        job['wilayah'] ?? '',
                                        style: const TextStyle(
                                            color: Colors.black45),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 32),

                  const Text(
                    'Remote Job',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_filteredRemoteJobs.isEmpty)
                    const Text(
                      'Tidak ada loker Remote.',
                      style: TextStyle(color: Colors.black45),
                    )
                  else
                    ..._filteredRemoteJobs.map((job) => GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetailLokerScreen(loker: job),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.blue, width: 1),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              children: [
                                ClipOval(
                                  child: job['gambar'] != null
                                      ? Image.network(
                                          job['gambar'],
                                          width: 40,
                                          height: 40,
                                          fit: BoxFit.cover,
                                        )
                                      : const Icon(Icons.image,
                                          size: 40, color: Colors.blue),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        job['jabatan'] ?? '',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(job['tempat'] ?? ''),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Rp. ${job['gaji'] ?? 0}/B',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue),
                                    ),
                                    Text(job['wilayah'] ?? ''),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )),
                ],
              ),
            ),
      bottomNavigationBar: const Menu(currentIndex: 0),
    );
  }
}
