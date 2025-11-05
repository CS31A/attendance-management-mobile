import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService _apiService = ApiService();

  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _account;

  @override
  void initState() {
    super.initState();
    _loadAccount();
  }

  Future<void> _loadAccount() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final res = await _apiService.getCurrentAccount();
    if (!mounted) return;

    if (res['success'] == true && res['data'] is Map<String, dynamic>) {
      setState(() {
        _account = Map<String, dynamic>.from(res['data'] as Map<String, dynamic>);
        _isLoading = false;
      });
    } else {
      setState(() {
        _error = res['message']?.toString() ?? 'Failed to load account';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        elevation: 0,
        backgroundColor: const Color(0xFF1E3A8A),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1E3A8A),
              Color(0xFF3B82F6),
              Color(0xFF60A5FA),
            ],
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _loadAccount,
            color: const Color(0xFF1E3A8A),
            child: _buildContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_error != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildErrorCard(_error!),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _loadAccount,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white, width: 2),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Retry', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      );
    }

    final username = _account?['username']?.toString() ?? '-';
    final email = _account?['email']?.toString() ?? '-';
    final role = _account?['role']?.toString() ?? '-';
    final createdAt = _account?['createdAt']?.toString();
    final updatedAt = _account?['updatedAt']?.toString();

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: [
        _buildHeader(username: username, role: role),
        const SizedBox(height: 24),
        _buildInfoCard(
          title: 'Account',
          items: [
            _InfoRow(icon: Icons.person_outline, label: 'Username', value: username),
            _InfoRow(icon: Icons.email_outlined, label: 'Email', value: email),
            _InfoRow(icon: Icons.verified_user_outlined, label: 'Role', value: role),
          ],
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          title: 'Timestamps',
          items: [
            _InfoRow(icon: Icons.calendar_today_outlined, label: 'Created', value: createdAt ?? '-'),
            _InfoRow(icon: Icons.update, label: 'Updated', value: updatedAt ?? '-'),
          ],
        ),
      ],
    );
  }

  Widget _buildHeader({String? username, String? role}) {
    return Column(
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.person, size: 48, color: Colors.white),
        ),
        const SizedBox(height: 16),
        Text(
          username ?? 'My Profile',
          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
        ),
        if ((role ?? '').isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            role!,
            style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ],
    );
  }

  Widget _buildInfoCard({required String title, required List<_InfoRow> items}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 24, offset: const Offset(0, 12)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF1E3A8A),
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            for (int i = 0; i < items.length; i++) ...[
              if (i > 0)
                Divider(height: 1, thickness: 1, color: const Color(0xFFE4E7EC).withOpacity(0.9)),
              Padding(padding: const EdgeInsets.symmetric(vertical: 14), child: items[i]),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Color(0xFF1F2937), fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF667085), size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF667085),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value.isEmpty ? '-' : value,
                style: const TextStyle(
                  color: Color(0xFF1E3A8A),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}


