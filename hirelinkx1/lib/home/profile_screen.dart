import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/education_model.dart';
import '../../models/experience_model.dart';
import 'add_education_screen.dart';
import 'add_experience_screen.dart';
import 'profile_bottom_sheet.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final supabase = Supabase.instance.client;

  Map<String, dynamic>? profile;
  List<Experience> experiences = [];
  List<Education> educations = [];

  bool showAllExperience = false;
  bool showAllEducation = false;
  bool deleteModeExperience = false;
  bool deleteModeEducation = false;

  @override
  void initState() {
    super.initState();
    fetchProfile();
    _loadExperience();
    _loadEducation();
  }

  Future<void> fetchProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final response = await supabase.from('profiles').select().eq('id', user.id).single();
    setState(() {
      profile = response;
    });
  }

  Future<void> _loadExperience() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final response = await supabase
        .from('experience')
        .select()
        .eq('profile_id', user.id)
        .order('created_at', ascending: false);

    final data = (response as List)
        .map((e) => Experience.fromJson(e as Map<String, dynamic>))
        .toList();

    setState(() {
      experiences = data;
    });
  }

  Future<void> _loadEducation() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final response = await supabase
        .from('education')
        .select()
        .eq('profile_id', user.id)
        .order('created_at', ascending: false);

    final data = (response as List)
        .map((e) => Education.fromJson(e as Map<String, dynamic>))
        .toList();

    setState(() {
      educations = data;
    });
  }

  Future<void> deleteExperience(String id) async {
    await supabase.from('experience').delete().eq('id', id);
    _loadExperience();
  }

  Future<void> deleteEducation(String id) async {
    await supabase.from('education').delete().eq('id', id);
    _loadEducation();
  }

  @override
  Widget build(BuildContext context) {
    final avatarUrl = profile?['avatar_url'] ??
        'https://ui-avatars.com/api/?name=${profile?['username'] ?? 'User'}';
    final username = profile?['username'] ?? 'Loading...';
    final title = profile?['title'] ?? '';
    final noTelp = profile?['no_telp'] ?? '-';
    final emailPesan = profile?['email_pesan'] ?? '-';

    return Scaffold(
      backgroundColor: const Color(0xFF1565C0),
      body: SafeArea(
        child: profile == null
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(avatarUrl, username, title, noTelp, emailPesan),
                      const SizedBox(height: 20),
                      _buildExperienceSection(),
                      const SizedBox(height: 20),
                      _buildEducationSection(),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildHeader(String avatarUrl, String username, String title, String noTelp, String emailPesan) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const BackButton(color: Colors.white),
            TextButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                  ),
                  builder: (_) => ProfileBottomSheet(onProfileUpdated: fetchProfile),
                );
              },
              child: const Text('Edit', style: TextStyle(color: Colors.white70)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Center(
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(avatarUrl),
                backgroundColor: Colors.white24,
              ),
              const SizedBox(height: 12),
              Text(
                username,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title.isNotEmpty ? title : '-',
                    style: const TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  const SizedBox(width: 6),
                  if (title.isNotEmpty)
                    const Icon(Icons.verified, color: Colors.white, size: 18),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.phone, size: 16, color: Colors.white70),
                  const SizedBox(width: 4),
                  Text(noTelp, style: const TextStyle(color: Colors.white70)),
                  const SizedBox(width: 12),
                  const Icon(Icons.email, size: 16, color: Colors.white70),
                  const SizedBox(width: 4),
                  Text(emailPesan, style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExperienceSection() {
    final displayed = showAllExperience ? experiences : experiences.take(2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text("Experience", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          Row(
            children: [
              TextButton(
                onPressed: () => setState(() => showAllExperience = !showAllExperience),
                child: Text(showAllExperience ? 'Show less' : 'See all', style: const TextStyle(color: Colors.white70)),
              ),
              TextButton(
                onPressed: () => setState(() {
                  deleteModeExperience = !deleteModeExperience;
                  showAllExperience = true;
                }),
                child: Text(deleteModeExperience ? 'Batal Hapus' : 'Hapus', style: const TextStyle(color: Colors.redAccent)),
              ),
            ],
          )
        ]),
        const SizedBox(height: 12),
        ...displayed.map((exp) => Stack(
              alignment: Alignment.center,
              children: [
                Opacity(
                  opacity: deleteModeExperience ? 0.4 : 1.0,
                  child: _infoCard(
                    icon: Icons.settings,
                    title: exp.jabatan,
                    subtitle: exp.tempat,
                    location: exp.wilayah,
                    duration: exp.waktu,
                  ),
                ),
                if (deleteModeExperience)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red, size: 30),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Hapus Experience?'),
                          content: const Text('Yakin ingin menghapus pengalaman ini?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
                            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus')),
                          ],
                        ),
                      );
                      if (confirm == true) await deleteExperience(exp.id);
                    },
                  ),
              ],
            )),
        _addButton('Add Experience', () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AddExperienceScreen()))
              .then((_) => _loadExperience());
        }),
      ],
    );
  }

  Widget _buildEducationSection() {
    final displayed = showAllEducation ? educations : educations.take(2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text("Education", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          Row(
            children: [
              TextButton(
                onPressed: () => setState(() => showAllEducation = !showAllEducation),
                child: Text(showAllEducation ? 'Show less' : 'See all', style: const TextStyle(color: Colors.white70)),
              ),
              TextButton(
                onPressed: () => setState(() {
                  deleteModeEducation = !deleteModeEducation;
                  showAllEducation = true;
                }),
                child: Text(deleteModeEducation ? 'Batal Hapus' : 'Hapus', style: const TextStyle(color: Colors.redAccent)),
              ),
            ],
          )
        ]),
        const SizedBox(height: 12),
        ...displayed.map((edu) => Stack(
              alignment: Alignment.center,
              children: [
                Opacity(
                  opacity: deleteModeEducation ? 0.4 : 1.0,
                  child: _infoCard(
                    icon: Icons.school,
                    title: edu.jurusan,
                    subtitle: edu.namaTempat,
                    location: 'Tahun',
                    duration: edu.waktu,
                  ),
                ),
                if (deleteModeEducation)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red, size: 30),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Hapus Education?'),
                          content: const Text('Yakin ingin menghapus pendidikan ini?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
                            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus')),
                          ],
                        ),
                      );
                      if (confirm == true) await deleteEducation(edu.id);
                    },
                  ),
              ],
            )),
        _addButton('Add Education', () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AddEducationScreen()))
              .then((_) => _loadEducation());
        }),
      ],
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String location,
    required String duration,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(radius: 24, backgroundColor: const Color(0xFFECF3FE), child: Icon(icon, color: Colors.black)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(subtitle, style: const TextStyle(color: Colors.black54)),
            ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(location, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(duration, style: const TextStyle(color: Colors.black54)),
          ]),
        ],
      ),
    );
  }

  Widget _addButton(String label, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_circle, color: Colors.blue),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
