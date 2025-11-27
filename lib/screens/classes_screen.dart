import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ClassesScreen extends StatefulWidget {
  final VoidCallback? onBackPressed;

  const ClassesScreen({super.key, this.onBackPressed});

  @override
  State<ClassesScreen> createState() => _ClassesScreenState();
}

class _ClassesScreenState extends State<ClassesScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();

  late TabController _tabController;

  // Classrooms
  List<Map<String, dynamic>> _classrooms = [];
  bool _isLoadingClassrooms = false;
  String? _classroomsErrorMessage;

  // Courses
  List<Map<String, dynamic>> _courses = [];
  bool _isLoadingCourses = false;
  String? _coursesErrorMessage;

  // Sections
  List<Map<String, dynamic>> _sections = [];
  bool _isLoadingSections = false;
  String? _sectionsErrorMessage;

  // Subjects
  List<Map<String, dynamic>> _subjects = [];
  bool _isLoadingSubjects = false;
  String? _subjectsErrorMessage;

  // Schedules
  List<Map<String, dynamic>> _schedules = [];
  bool _isLoadingSchedules = false;
  String? _schedulesErrorMessage;

  // Instructors
  List<Map<String, dynamic>> _instructors = [];
  bool _isLoadingInstructors = false;
  String? _instructorsErrorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        if (_tabController.index == 0 &&
            _classrooms.isEmpty &&
            !_isLoadingClassrooms) {
          _loadClassrooms();
        } else if (_tabController.index == 1 &&
            _courses.isEmpty &&
            !_isLoadingCourses) {
          _loadCourses();
        } else if (_tabController.index == 2 &&
            _sections.isEmpty &&
            !_isLoadingSections) {
          _loadSections();
        } else if (_tabController.index == 3 &&
            _subjects.isEmpty &&
            !_isLoadingSubjects) {
          _loadSubjects();
        } else if (_tabController.index == 4 &&
            _schedules.isEmpty &&
            !_isLoadingSchedules) {
          _loadSchedules();
        }
      }
    });
    _loadClassrooms();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadClassrooms() async {
    setState(() {
      _isLoadingClassrooms = true;
      _classroomsErrorMessage = null;
    });

    try {
      final response = await _apiService.getClassrooms();
      if (response['success'] == true) {
        final data = response['data'];
        if (data is List) {
          setState(() {
            _classrooms = List<Map<String, dynamic>>.from(data);
            _isLoadingClassrooms = false;
          });
        } else {
          setState(() {
            _classrooms = [];
            _isLoadingClassrooms = false;
          });
        }
      } else {
        setState(() {
          _classroomsErrorMessage =
              response['message'] ?? 'Failed to load classrooms';
          _isLoadingClassrooms = false;
        });
      }
    } catch (e) {
      setState(() {
        _classroomsErrorMessage = 'Failed to load classrooms: $e';
        _isLoadingClassrooms = false;
      });
    }
  }

  Future<void> _loadCourses() async {
    setState(() {
      _isLoadingCourses = true;
      _coursesErrorMessage = null;
    });

    try {
      final response = await _apiService.getCourses();
      if (response['success'] == true) {
        final data = response['data'];
        if (data is List) {
          setState(() {
            _courses = List<Map<String, dynamic>>.from(data);
            _isLoadingCourses = false;
          });
        } else {
          setState(() {
            _courses = [];
            _isLoadingCourses = false;
          });
        }
      } else {
        setState(() {
          _coursesErrorMessage =
              response['message'] ?? 'Failed to load courses';
          _isLoadingCourses = false;
        });
      }
    } catch (e) {
      setState(() {
        _coursesErrorMessage = 'Failed to load courses: $e';
        _isLoadingCourses = false;
      });
    }
  }

  int get _totalClassesCount => _classrooms.length;
  int get _totalCoursesCount => _courses.length;
  int get _totalSectionsCount => _sections.length;
  int get _totalSubjectsCount => _subjects.length;
  int get _totalSchedulesCount => _schedules.length;

  Future<void> _loadSchedules() async {
    setState(() {
      _isLoadingSchedules = true;
      _schedulesErrorMessage = null;
    });

    try {
      final response = await _apiService.getSchedules();
      if (response['success'] == true) {
        final data = response['data'];
        if (data is List) {
          setState(() {
            _schedules = List<Map<String, dynamic>>.from(data);
            _isLoadingSchedules = false;
          });
        } else {
          setState(() {
            _schedules = [];
            _isLoadingSchedules = false;
          });
        }
      } else {
        setState(() {
          _schedulesErrorMessage =
              response['message'] ?? 'Failed to load schedules';
          _isLoadingSchedules = false;
        });
      }
    } catch (e) {
      setState(() {
        _schedulesErrorMessage = 'Failed to load schedules: $e';
        _isLoadingSchedules = false;
      });
    }
  }

  Future<void> _loadInstructors() async {
    setState(() {
      _isLoadingInstructors = true;
      _instructorsErrorMessage = null;
    });

    try {
      final response = await _apiService.getInstructors();
      if (response['success'] == true) {
        final data = response['data'];
        if (data is List) {
          setState(() {
            _instructors = List<Map<String, dynamic>>.from(data);
            _isLoadingInstructors = false;
          });
        } else {
          setState(() {
            _instructors = [];
            _isLoadingInstructors = false;
          });
        }
      } else {
        setState(() {
          _instructorsErrorMessage =
              response['message'] ?? 'Failed to load instructors';
          _isLoadingInstructors = false;
        });
      }
    } catch (e) {
      setState(() {
        _instructorsErrorMessage = 'Failed to load instructors: $e';
        _isLoadingInstructors = false;
      });
    }
  }

  Future<void> _loadSubjects() async {
    setState(() {
      _isLoadingSubjects = true;
      _subjectsErrorMessage = null;
    });

    try {
      final response = await _apiService.getSubjects();
      if (response['success'] == true) {
        final data = response['data'];
        if (data is List) {
          setState(() {
            _subjects = List<Map<String, dynamic>>.from(data);
            _isLoadingSubjects = false;
          });
        } else {
          setState(() {
            _subjects = [];
            _isLoadingSubjects = false;
          });
        }
      } else {
        setState(() {
          _subjectsErrorMessage =
              response['message'] ?? 'Failed to load subjects';
          _isLoadingSubjects = false;
        });
      }
    } catch (e) {
      setState(() {
        _subjectsErrorMessage = 'Failed to load subjects: $e';
        _isLoadingSubjects = false;
      });
    }
  }

  Future<void> _loadSections() async {
    setState(() {
      _isLoadingSections = true;
      _sectionsErrorMessage = null;
    });

    try {
      final response = await _apiService.getSections();
      if (response['success'] == true) {
        final data = response['data'];
        if (data is List) {
          setState(() {
            _sections = List<Map<String, dynamic>>.from(data);
            _isLoadingSections = false;
          });
        } else {
          setState(() {
            _sections = [];
            _isLoadingSections = false;
          });
        }
      } else {
        setState(() {
          _sectionsErrorMessage =
              response['message'] ?? 'Failed to load sections';
          _isLoadingSections = false;
        });
      }
    } catch (e) {
      setState(() {
        _sectionsErrorMessage = 'Failed to load sections: $e';
        _isLoadingSections = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          child: Column(
            children: [
              // Header
              _buildHeader(),

              // Tabs
              _buildTabBar(),

              // Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Classrooms Tab
                    _isLoadingClassrooms
                        ? const Center(
                            child:
                                CircularProgressIndicator(color: Colors.white),
                          )
                        : _classroomsErrorMessage != null
                            ? _buildErrorState(
                                _classroomsErrorMessage!, _loadClassrooms)
                            : _buildClassroomsContent(),

                    // Courses Tab
                    _isLoadingCourses
                        ? const Center(
                            child:
                                CircularProgressIndicator(color: Colors.white),
                          )
                        : _coursesErrorMessage != null
                            ? _buildErrorState(
                                _coursesErrorMessage!, _loadCourses)
                            : _buildCoursesContent(),

                    // Sections Tab
                    _isLoadingSections
                        ? const Center(
                            child:
                                CircularProgressIndicator(color: Colors.white),
                          )
                        : _sectionsErrorMessage != null
                            ? _buildErrorState(
                                _sectionsErrorMessage!, _loadSections)
                            : _buildSectionsContent(),

                    // Subjects Tab
                    _isLoadingSubjects
                        ? const Center(
                            child:
                                CircularProgressIndicator(color: Colors.white),
                          )
                        : _subjectsErrorMessage != null
                            ? _buildErrorState(
                                _subjectsErrorMessage!, _loadSubjects)
                            : _buildSubjectsContent(),

                    // Schedules Tab
                    _isLoadingSchedules
                        ? const Center(
                            child:
                                CircularProgressIndicator(color: Colors.white),
                          )
                        : _schedulesErrorMessage != null
                            ? _buildErrorState(
                                _schedulesErrorMessage!, _loadSchedules)
                            : _buildSchedulesContent(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // ACLC Logo
          SizedBox(
            width: 50,
            height: 50,
            child: Image.asset(
              'assets/acla logo.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.school,
                    color: Colors.white,
                    size: 30,
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          // Classes Title
          const Expanded(
            child: Text(
              'Classes',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: Colors.black26,
                    offset: Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
          // Add Button (changes based on tab)
          IconButton(
            onPressed: () {
              if (_tabController.index == 0) {
                _showAddClassroomModal();
              } else if (_tabController.index == 1) {
                _showAddCourseModal();
              } else if (_tabController.index == 2) {
                _showAddSectionModal();
              } else if (_tabController.index == 3) {
                _showAddSubjectModal();
              } else {
                _showAddScheduleModal();
              }
            },
            icon: const Icon(Icons.add, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(
            width: 3,
            color: Colors.white,
          ),
          insets: EdgeInsets.symmetric(horizontal: 16),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white.withOpacity(0.7),
        labelStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        tabs: const [
          Tab(text: 'Classrooms'),
          Tab(text: 'Courses'),
          Tab(text: 'Sections'),
          Tab(text: 'Subjects'),
          Tab(text: 'Schedules'),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Unable to Load',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.white.withOpacity(0.9),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF3B82F6),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassroomsContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Classrooms Overview
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                const Text(
                  'Classrooms Overview',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Stats Grid
          _buildClassroomsStatsGrid(),

          const SizedBox(height: 24),

          // Classrooms List Section
          const Text(
            'Classrooms List',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          // Classrooms Cards
          _buildClassroomsList(),
        ],
      ),
    );
  }

  Widget _buildCoursesContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Courses Overview
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                const Text(
                  'Courses Overview',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Stats Grid
          _buildCoursesStatsGrid(),

          const SizedBox(height: 24),

          // Courses List Section
          const Text(
            'Courses List',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          // Courses Cards
          _buildCoursesList(),
        ],
      ),
    );
  }

  Widget _buildClassroomsStatsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.0,
      children: [
        _buildStatCard(
          title: 'Total Classrooms',
          value: _totalClassesCount.toString(),
          progress: _totalClassesCount > 0 ? 1.0 : 0.0,
          gradientColors: [const Color(0xFF3B82F6), const Color(0xFF60A5FA)],
          icon: Icons.class_,
        ),
        _buildStatCard(
          title: 'Active Classrooms',
          value: _totalClassesCount.toString(),
          progress: _totalClassesCount > 0 ? 1.0 : 0.0,
          gradientColors: [const Color(0xFF3B82F6), const Color(0xFF60A5FA)],
          icon: Icons.school,
        ),
      ],
    );
  }

  Widget _buildCoursesStatsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.0,
      children: [
        _buildStatCard(
          title: 'Total Courses',
          value: _totalCoursesCount.toString(),
          progress: _totalCoursesCount > 0 ? 1.0 : 0.0,
          gradientColors: [const Color(0xFF3B82F6), const Color(0xFF60A5FA)],
          icon: Icons.book,
        ),
        _buildStatCard(
          title: 'Active Courses',
          value: _totalCoursesCount.toString(),
          progress: _totalCoursesCount > 0 ? 1.0 : 0.0,
          gradientColors: [const Color(0xFF3B82F6), const Color(0xFF60A5FA)],
          icon: Icons.menu_book,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required double progress,
    required List<Color> gradientColors,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: gradientColors[0].withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3B82F6),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress.clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: gradientColors,
                        ),
                        borderRadius: BorderRadius.circular(3),
                        boxShadow: [
                          BoxShadow(
                            color: gradientColors[0].withOpacity(0.5),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 12,
                  color: gradientColors[0],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildClassroomsList() {
    if (_classrooms.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              Icons.class_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No classrooms available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add a new classroom to get started',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _classrooms.length,
      itemBuilder: (context, index) {
        final classroom = _classrooms[index];
        return _buildClassroomCard(classroom);
      },
    );
  }

  Widget _buildCoursesList() {
    if (_courses.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              Icons.book_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No courses available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add a new course to get started',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _courses.length,
      itemBuilder: (context, index) {
        final course = _courses[index];
        return _buildCourseCard(course);
      },
    );
  }

  Widget _buildClassroomCard(Map<String, dynamic> classroom) {
    final id = classroom['id']?.toString() ?? 'N/A';
    final name = classroom['name']?.toString() ?? 'Unnamed';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Classroom Icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF3B82F6),
                  Color(0xFF60A5FA),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.class_,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          // Classroom Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ID: $id',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          // Action Buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => _showEditClassroomModal(classroom),
                icon: const Icon(Icons.edit, color: Color(0xFF3B82F6)),
                tooltip: 'Edit',
              ),
              IconButton(
                onPressed: () => _showDeleteClassroomConfirmation(classroom),
                icon: const Icon(Icons.delete, color: Colors.red),
                tooltip: 'Delete',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard(Map<String, dynamic> course) {
    final id = course['id']?.toString() ?? 'N/A';
    final name = course['name']?.toString() ?? 'Unnamed';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Course Icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF3B82F6),
                  Color(0xFF60A5FA),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.book,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          // Course Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ID: $id',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          // Action Buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => _showEditCourseModal(course),
                icon: const Icon(Icons.edit, color: Color(0xFF3B82F6)),
                tooltip: 'Edit',
              ),
              IconButton(
                onPressed: () => _showDeleteCourseConfirmation(course),
                icon: const Icon(Icons.delete, color: Colors.red),
                tooltip: 'Delete',
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Classrooms Modals
  void _showAddClassroomModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.5,
          ),
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top,
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
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
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: _AddClassroomModalContent(
            onClassroomCreated: () => _loadClassrooms(),
          ),
        ),
      ),
    );
  }

  void _showEditClassroomModal(Map<String, dynamic> classroom) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.5,
          ),
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top,
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
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
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: _EditClassroomModalContent(
            classroom: classroom,
            onClassroomUpdated: () => _loadClassrooms(),
          ),
        ),
      ),
    );
  }

  void _showDeleteClassroomConfirmation(Map<String, dynamic> classroom) {
    final name = classroom['name']?.toString() ?? 'this classroom';

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1E3A8A),
                Color(0xFF3B82F6),
                Color(0xFF60A5FA),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ACLC Logo
              SizedBox(
                width: 50,
                height: 50,
                child: Image.asset(
                  'assets/acla logo.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.school,
                        color: Colors.white,
                        size: 30,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Delete Classroom',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Are you sure you want to delete "$name"? This action cannot be undone.',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white, width: 2),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.of(context).pop();
                        await _handleDeleteClassroom(classroom);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Delete',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleDeleteClassroom(Map<String, dynamic> classroom) async {
    final id = classroom['id'];
    if (id == null) return;

    try {
      final response = await _apiService.deleteClassroom(id as int);
      if (response['success'] == true) {
        if (mounted) {
          _showSuccessModal('Classroom deleted successfully');
          _loadClassrooms();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text(response['message'] ?? 'Failed to delete classroom'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Sections Content
  Widget _buildSectionsContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sections Overview
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                const Text(
                  'Sections Overview',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Stats Grid
          _buildSectionsStatsGrid(),

          const SizedBox(height: 24),

          // Sections List Section
          const Text(
            'Sections List',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          // Sections Cards
          _buildSectionsList(),
        ],
      ),
    );
  }

  // Schedules Content
  Widget _buildSchedulesContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Schedules Overview
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                const Text(
                  'Schedules Overview',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Stats Grid
          _buildSchedulesStatsGrid(),

          const SizedBox(height: 24),

          // Schedules List Section
          const Text(
            'Schedules List',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          // Schedules Cards
          _buildSchedulesList(),
        ],
      ),
    );
  }

  Widget _buildSchedulesStatsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.0,
      children: [
        _buildStatCard(
          title: 'Total Schedules',
          value: _totalSchedulesCount.toString(),
          progress: _totalSchedulesCount > 0 ? 1.0 : 0.0,
          gradientColors: [const Color(0xFF3B82F6), const Color(0xFF60A5FA)],
          icon: Icons.calendar_today,
        ),
        _buildStatCard(
          title: 'Active Schedules',
          value: _totalSchedulesCount.toString(),
          progress: _totalSchedulesCount > 0 ? 1.0 : 0.0,
          gradientColors: [const Color(0xFF3B82F6), const Color(0xFF60A5FA)],
          icon: Icons.event,
        ),
      ],
    );
  }

  Widget _buildSchedulesList() {
    if (_schedules.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No schedules available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add a new schedule to get started',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _schedules.length,
      itemBuilder: (context, index) {
        final schedule = _schedules[index];
        return _buildScheduleCard(schedule);
      },
    );
  }

  Widget _buildScheduleCard(Map<String, dynamic> schedule) {
    final id = schedule['id']?.toString() ?? 'N/A';
    final dayOfWeek = schedule['dayOfWeek']?.toString() ?? 'N/A';
    final timeIn = schedule['timeIn']?.toString() ?? 'N/A';
    final timeOut = schedule['timeOut']?.toString() ?? 'N/A';
    final subject =
        schedule['subject']?['name']?.toString() ?? 'Unknown Subject';
    final classroom =
        schedule['classroom']?['name']?.toString() ?? 'Unknown Room';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Schedule Icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF3B82F6),
                  Color(0xFF60A5FA),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  dayOfWeek.substring(0, 3).toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                const Icon(
                  Icons.calendar_today,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Schedule Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$timeIn - $timeOut',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF3B82F6),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$classroom • ID: $id',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          // Action Buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => _showEditScheduleModal(schedule),
                icon: const Icon(Icons.edit, color: Color(0xFF3B82F6)),
                tooltip: 'Edit',
              ),
              IconButton(
                onPressed: () => _showDeleteScheduleConfirmation(schedule),
                icon: const Icon(Icons.delete, color: Colors.red),
                tooltip: 'Delete',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionsStatsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.0,
      children: [
        _buildStatCard(
          title: 'Total Sections',
          value: _totalSectionsCount.toString(),
          progress: _totalSectionsCount > 0 ? 1.0 : 0.0,
          gradientColors: [const Color(0xFF3B82F6), const Color(0xFF60A5FA)],
          icon: Icons.view_list,
        ),
        _buildStatCard(
          title: 'Active Sections',
          value: _totalSectionsCount.toString(),
          progress: _totalSectionsCount > 0 ? 1.0 : 0.0,
          gradientColors: [const Color(0xFF3B82F6), const Color(0xFF60A5FA)],
          icon: Icons.list_alt,
        ),
      ],
    );
  }

  Widget _buildSectionsList() {
    if (_sections.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              Icons.view_list_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No sections available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add a new section to get started',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _sections.length,
      itemBuilder: (context, index) {
        final section = _sections[index];
        return _buildSectionCard(section);
      },
    );
  }

  Widget _buildSectionCard(Map<String, dynamic> section) {
    final id = section['id']?.toString() ?? 'N/A';
    final name = section['name']?.toString() ?? 'Unnamed';
    final courseId = section['courseId']?.toString() ?? 'N/A';

    // Find course name
    String courseName = 'Course ID: $courseId';
    final course = _courses.firstWhere(
      (c) => c['id'] == section['courseId'],
      orElse: () => {},
    );
    if (course.isNotEmpty && course['name'] != null) {
      courseName = course['name'].toString();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Section Icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF3B82F6),
                  Color(0xFF60A5FA),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.view_list,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          // Section Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ID: $id • Course: $courseName',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          // Action Buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => _showEditSectionModal(section),
                icon: const Icon(Icons.edit, color: Color(0xFF3B82F6)),
                tooltip: 'Edit',
              ),
              IconButton(
                onPressed: () => _showDeleteSectionConfirmation(section),
                icon: const Icon(Icons.delete, color: Colors.red),
                tooltip: 'Delete',
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddScheduleModal() async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await Future.wait([
        if (_subjects.isEmpty) _loadSubjects(),
        if (_classrooms.isEmpty) _loadClassrooms(),
        if (_courses.isEmpty) _loadCourses(),
        if (_sections.isEmpty) _loadSections(),
        if (_instructors.isEmpty) _loadInstructors(),
      ]);
    } finally {
      // Close loading indicator
      if (mounted) {
        Navigator.of(context).pop();
      }
    }

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top,
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
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
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: _AddScheduleModalContent(
            subjects: _subjects,
            classrooms: _classrooms,
            sections: _sections,
            instructors: _instructors,
            onScheduleCreated: () => _loadSchedules(),
          ),
        ),
      ),
    );
  }

  void _showEditScheduleModal(Map<String, dynamic> schedule) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await Future.wait([
        if (_subjects.isEmpty) _loadSubjects(),
        if (_classrooms.isEmpty) _loadClassrooms(),
        if (_courses.isEmpty) _loadCourses(),
        if (_sections.isEmpty) _loadSections(),
        if (_instructors.isEmpty) _loadInstructors(),
      ]);
    } finally {
      // Close loading indicator
      if (mounted) {
        Navigator.of(context).pop();
      }
    }

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top,
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
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
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: _EditScheduleModalContent(
            schedule: schedule,
            subjects: _subjects,
            classrooms: _classrooms,
            sections: _sections,
            instructors: _instructors,
            onScheduleUpdated: () => _loadSchedules(),
          ),
        ),
      ),
    );
  }

  void _showDeleteScheduleConfirmation(Map<String, dynamic> schedule) {
    final subjectName =
        schedule['subject']?['name']?.toString() ?? 'this schedule';
    final day = schedule['dayOfWeek']?.toString() ?? '';
    final time = schedule['timeIn']?.toString() ?? '';

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1E3A8A),
                Color(0xFF3B82F6),
                Color(0xFF60A5FA),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ACLC Logo
              SizedBox(
                width: 50,
                height: 50,
                child: Image.asset(
                  'assets/acla logo.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.school,
                        color: Colors.white,
                        size: 30,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Delete Schedule',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Are you sure you want to delete the schedule for $subjectName on $day at $time? This action cannot be undone.',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white, width: 2),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.of(context).pop();
                        final response =
                            await _apiService.deleteSchedule(schedule['id']);
                        if (response['success'] == true) {
                          _loadSchedules();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Schedule deleted successfully'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } else {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(response['message'] ??
                                    'Failed to delete schedule'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF3B82F6),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Delete',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Sections Modals
  void _showAddSectionModal() async {
    // Ensure courses are loaded before showing modal
    if (_courses.isEmpty && !_isLoadingCourses) {
      await _loadCourses();
    }

    if (_courses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please create a course first before adding sections'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top,
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
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
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: _AddSectionModalContent(
            courses: _courses,
            onSectionCreated: () => _loadSections(),
          ),
        ),
      ),
    );
  }

  void _showEditSectionModal(Map<String, dynamic> section) async {
    // Ensure courses are loaded before showing modal
    if (_courses.isEmpty && !_isLoadingCourses) {
      await _loadCourses();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top,
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
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
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: _EditSectionModalContent(
            section: section,
            courses: _courses,
            onSectionUpdated: () => _loadSections(),
          ),
        ),
      ),
    );
  }

  void _showDeleteSectionConfirmation(Map<String, dynamic> section) {
    final name = section['name']?.toString() ?? 'this section';

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1E3A8A),
                Color(0xFF3B82F6),
                Color(0xFF60A5FA),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ACLC Logo
              SizedBox(
                width: 50,
                height: 50,
                child: Image.asset(
                  'assets/acla logo.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.school,
                        color: Colors.white,
                        size: 30,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Delete Section',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Are you sure you want to delete "$name"? This action cannot be undone.',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white, width: 2),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.of(context).pop();
                        await _handleDeleteSection(section);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Delete',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleDeleteSection(Map<String, dynamic> section) async {
    var id = section['id'];
    if (id == null) return;

    // Ensure id is int
    if (id is String) {
      id = int.tryParse(id);
    }

    if (id is! int) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid section ID'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    try {
      final response = await _apiService.deleteSection(id as int);
      if (response['success'] == true) {
        if (mounted) {
          _showSuccessModal('Section deleted successfully');
          _loadSections();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Failed to delete section'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Subjects Content
  Widget _buildSubjectsContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subjects Overview
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                const Text(
                  'Subjects Overview',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Stats Grid
          _buildSubjectsStatsGrid(),

          const SizedBox(height: 24),

          // Subjects List Section
          const Text(
            'Subjects List',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          // Subjects Cards
          _buildSubjectsList(),
        ],
      ),
    );
  }

  Widget _buildSubjectsStatsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.0,
      children: [
        _buildStatCard(
          title: 'Total Subjects',
          value: _totalSubjectsCount.toString(),
          progress: _totalSubjectsCount > 0 ? 1.0 : 0.0,
          gradientColors: [const Color(0xFF3B82F6), const Color(0xFF60A5FA)],
          icon: Icons.subject,
        ),
        _buildStatCard(
          title: 'Active Subjects',
          value: _totalSubjectsCount.toString(),
          progress: _totalSubjectsCount > 0 ? 1.0 : 0.0,
          gradientColors: [const Color(0xFF3B82F6), const Color(0xFF60A5FA)],
          icon: Icons.menu_book,
        ),
      ],
    );
  }

  Widget _buildSubjectsList() {
    if (_subjects.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              Icons.subject_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No subjects available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add a new subject to get started',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _subjects.length,
      itemBuilder: (context, index) {
        final subject = _subjects[index];
        return _buildSubjectCard(subject);
      },
    );
  }

  Widget _buildSubjectCard(Map<String, dynamic> subject) {
    final id = subject['id']?.toString() ?? 'N/A';
    final name = subject['name']?.toString() ?? 'Unnamed';
    final code = subject['code']?.toString() ?? 'N/A';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Subject Icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF3B82F6),
                  Color(0xFF60A5FA),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.subject,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          // Subject Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ID: $id • Code: $code',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          // Action Buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => _showEditSubjectModal(subject),
                icon: const Icon(Icons.edit, color: Color(0xFF3B82F6)),
                tooltip: 'Edit',
              ),
              IconButton(
                onPressed: () => _showDeleteSubjectConfirmation(subject),
                icon: const Icon(Icons.delete, color: Colors.red),
                tooltip: 'Delete',
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Subjects Modals
  void _showAddSubjectModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top,
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
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
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: _AddSubjectModalContent(
            onSubjectCreated: () => _loadSubjects(),
          ),
        ),
      ),
    );
  }

  void _showEditSubjectModal(Map<String, dynamic> subject) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top,
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
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
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: _EditSubjectModalContent(
            subject: subject,
            onSubjectUpdated: () => _loadSubjects(),
          ),
        ),
      ),
    );
  }

  void _showDeleteSubjectConfirmation(Map<String, dynamic> subject) {
    final name = subject['name']?.toString() ?? 'this subject';

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1E3A8A),
                Color(0xFF3B82F6),
                Color(0xFF60A5FA),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ACLC Logo
              SizedBox(
                width: 50,
                height: 50,
                child: Image.asset(
                  'assets/acla logo.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.school,
                        color: Colors.white,
                        size: 30,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Delete Subject',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Are you sure you want to delete "$name"? This action cannot be undone.',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white, width: 2),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.of(context).pop();
                        await _handleDeleteSubject(subject);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Delete',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleDeleteSubject(Map<String, dynamic> subject) async {
    final id = subject['id'];
    if (id == null) return;

    try {
      final response = await _apiService.deleteSubject(id as int);
      if (response['success'] == true) {
        if (mounted) {
          _showSuccessModal('Subject deleted successfully');
          _loadSubjects();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Failed to delete subject'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Courses Modals
  void _showAddCourseModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.5,
          ),
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top,
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
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
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: _AddCourseModalContent(
            onCourseCreated: () => _loadCourses(),
          ),
        ),
      ),
    );
  }

  void _showEditCourseModal(Map<String, dynamic> course) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.5,
          ),
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top,
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
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
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: _EditCourseModalContent(
            course: course,
            onCourseUpdated: () => _loadCourses(),
          ),
        ),
      ),
    );
  }

  void _showDeleteCourseConfirmation(Map<String, dynamic> course) {
    final name = course['name']?.toString() ?? 'this course';

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1E3A8A),
                Color(0xFF3B82F6),
                Color(0xFF60A5FA),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ACLC Logo
              SizedBox(
                width: 50,
                height: 50,
                child: Image.asset(
                  'assets/acla logo.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.school,
                        color: Colors.white,
                        size: 30,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Delete Course',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Are you sure you want to delete "$name"? This action cannot be undone.',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white, width: 2),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.of(context).pop();
                        await _handleDeleteCourse(course);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Delete',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleDeleteCourse(Map<String, dynamic> course) async {
    final id = course['id'];
    if (id == null) return;

    try {
      final response = await _apiService.deleteCourse(id as int);
      if (response['success'] == true) {
        if (mounted) {
          _showSuccessModal('Course deleted successfully');
          _loadCourses();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Failed to delete course'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showSuccessModal(String message) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1E3A8A),
                Color(0xFF3B82F6),
                Color(0xFF60A5FA),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ACLC Logo
              SizedBox(
                width: 50,
                height: 50,
                child: Image.asset(
                  'assets/acla logo.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.school,
                        color: Colors.white,
                        size: 30,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Success!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF3B82F6),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'OK',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Add Classroom Modal
class _AddClassroomModalContent extends StatefulWidget {
  final VoidCallback? onClassroomCreated;

  const _AddClassroomModalContent({this.onClassroomCreated});

  @override
  State<_AddClassroomModalContent> createState() =>
      _AddClassroomModalContentState();
}

class _AddClassroomModalContentState extends State<_AddClassroomModalContent> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  final TextEditingController _nameController = TextEditingController();
  bool _isCreating = false;
  Map<String, String?> _fieldErrors = {};

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleCreate() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isCreating = true;
      _fieldErrors = {};
    });

    final response =
        await _apiService.createClassroom(_nameController.text.trim());

    setState(() {
      _isCreating = false;
    });

    if (response['success'] == true) {
      if (mounted) {
        widget.onClassroomCreated?.call();
        Navigator.of(context).pop();
      }
    } else {
      Map<String, List<String>>? apiErrors =
          response['errors'] as Map<String, List<String>>?;

      setState(() {
        _fieldErrors = {};
        if (apiErrors != null && apiErrors.containsKey('Name')) {
          _fieldErrors['name'] = apiErrors['Name']!.first;
        }
      });

      _formKey.currentState?.validate();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Failed to create classroom'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Add Classroom',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Classroom Name',
                  hintText: 'Enter classroom name',
                  prefixIcon: const Icon(Icons.class_, color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: Colors.white.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white, width: 2),
                  ),
                  labelStyle: const TextStyle(color: Colors.white70),
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  errorText: _fieldErrors['name'],
                ),
                style: const TextStyle(color: Colors.white),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Classroom name is required';
                  }
                  if (value.trim().length < 2) {
                    return 'Classroom name must be at least 2 characters';
                  }
                  if (value.trim().length > 100) {
                    return 'Classroom name must be at most 100 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Create Button
              ElevatedButton(
                onPressed: _isCreating ? null : _handleCreate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF3B82F6),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isCreating
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
                        ),
                      )
                    : const Text(
                        'Create Classroom',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Edit Classroom Modal
class _EditClassroomModalContent extends StatefulWidget {
  final Map<String, dynamic> classroom;
  final VoidCallback? onClassroomUpdated;

  const _EditClassroomModalContent({
    required this.classroom,
    this.onClassroomUpdated,
  });

  @override
  State<_EditClassroomModalContent> createState() =>
      _EditClassroomModalContentState();
}

class _EditClassroomModalContentState
    extends State<_EditClassroomModalContent> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  late final TextEditingController _nameController;
  bool _isUpdating = false;
  Map<String, String?> _fieldErrors = {};

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.classroom['name']?.toString() ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isUpdating = true;
      _fieldErrors = {};
    });

    final id = widget.classroom['id'] as int;
    final response =
        await _apiService.updateClassroom(id, _nameController.text.trim());

    setState(() {
      _isUpdating = false;
    });

    if (response['success'] == true) {
      if (mounted) {
        widget.onClassroomUpdated?.call();
        Navigator.of(context).pop();
      }
    } else {
      Map<String, List<String>>? apiErrors =
          response['errors'] as Map<String, List<String>>?;

      setState(() {
        _fieldErrors = {};
        if (apiErrors != null && apiErrors.containsKey('Name')) {
          _fieldErrors['name'] = apiErrors['Name']!.first;
        }
      });

      _formKey.currentState?.validate();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Failed to update classroom'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Edit Classroom',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Classroom Name',
                  hintText: 'Enter classroom name',
                  prefixIcon: const Icon(Icons.class_, color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: Colors.white.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white, width: 2),
                  ),
                  labelStyle: const TextStyle(color: Colors.white70),
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  errorText: _fieldErrors['name'],
                ),
                style: const TextStyle(color: Colors.white),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Classroom name is required';
                  }
                  if (value.trim().length < 2) {
                    return 'Classroom name must be at least 2 characters';
                  }
                  if (value.trim().length > 100) {
                    return 'Classroom name must be at most 100 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Update Button
              ElevatedButton(
                onPressed: _isUpdating ? null : _handleUpdate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF3B82F6),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isUpdating
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
                        ),
                      )
                    : const Text(
                        'Update Classroom',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Add Course Modal
class _AddCourseModalContent extends StatefulWidget {
  final VoidCallback? onCourseCreated;

  const _AddCourseModalContent({this.onCourseCreated});

  @override
  State<_AddCourseModalContent> createState() => _AddCourseModalContentState();
}

class _AddCourseModalContentState extends State<_AddCourseModalContent> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  final TextEditingController _nameController = TextEditingController();
  bool _isCreating = false;
  Map<String, String?> _fieldErrors = {};

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleCreate() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isCreating = true;
      _fieldErrors = {};
    });

    final response =
        await _apiService.createCourse(_nameController.text.trim());

    setState(() {
      _isCreating = false;
    });

    if (response['success'] == true) {
      if (mounted) {
        widget.onCourseCreated?.call();
        Navigator.of(context).pop();
      }
    } else {
      Map<String, List<String>>? apiErrors =
          response['errors'] as Map<String, List<String>>?;

      setState(() {
        _fieldErrors = {};
        if (apiErrors != null && apiErrors.containsKey('Name')) {
          _fieldErrors['name'] = apiErrors['Name']!.first;
        }
      });

      _formKey.currentState?.validate();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Failed to create course'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Add Course',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Course Name',
                  hintText: 'Enter course name',
                  prefixIcon: const Icon(Icons.book, color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: Colors.white.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white, width: 2),
                  ),
                  labelStyle: const TextStyle(color: Colors.white70),
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  errorText: _fieldErrors['name'],
                ),
                style: const TextStyle(color: Colors.white),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Course name is required';
                  }
                  if (value.trim().length < 20) {
                    return 'Course name must be at least 20 characters';
                  }
                  if (value.trim().length > 100) {
                    return 'Course name must be at most 100 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Create Button
              ElevatedButton(
                onPressed: _isCreating ? null : _handleCreate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF3B82F6),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isCreating
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
                        ),
                      )
                    : const Text(
                        'Create Course',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Edit Course Modal
class _EditCourseModalContent extends StatefulWidget {
  final Map<String, dynamic> course;
  final VoidCallback? onCourseUpdated;

  const _EditCourseModalContent({
    required this.course,
    this.onCourseUpdated,
  });

  @override
  State<_EditCourseModalContent> createState() =>
      _EditCourseModalContentState();
}

class _EditCourseModalContentState extends State<_EditCourseModalContent> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  late final TextEditingController _nameController;
  bool _isUpdating = false;
  Map<String, String?> _fieldErrors = {};

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.course['name']?.toString() ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isUpdating = true;
      _fieldErrors = {};
    });

    final id = widget.course['id'] as int;
    final response =
        await _apiService.updateCourse(id, _nameController.text.trim());

    setState(() {
      _isUpdating = false;
    });

    if (response['success'] == true) {
      if (mounted) {
        widget.onCourseUpdated?.call();
        Navigator.of(context).pop();
      }
    } else {
      Map<String, List<String>>? apiErrors =
          response['errors'] as Map<String, List<String>>?;

      setState(() {
        _fieldErrors = {};
        if (apiErrors != null && apiErrors.containsKey('Name')) {
          _fieldErrors['name'] = apiErrors['Name']!.first;
        }
      });

      _formKey.currentState?.validate();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Failed to update course'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Edit Course',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Course Name',
                  hintText: 'Enter course name',
                  prefixIcon: const Icon(Icons.book, color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: Colors.white.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white, width: 2),
                  ),
                  labelStyle: const TextStyle(color: Colors.white70),
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  errorText: _fieldErrors['name'],
                ),
                style: const TextStyle(color: Colors.white),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Course name is required';
                  }
                  if (value.trim().length < 1) {
                    return 'Course name must be at least 1 character';
                  }
                  if (value.trim().length > 100) {
                    return 'Course name must be at most 100 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Update Button
              ElevatedButton(
                onPressed: _isUpdating ? null : _handleUpdate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF3B82F6),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isUpdating
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
                        ),
                      )
                    : const Text(
                        'Update Course',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Add Section Modal
class _AddSectionModalContent extends StatefulWidget {
  final List<Map<String, dynamic>> courses;
  final VoidCallback? onSectionCreated;

  const _AddSectionModalContent({
    required this.courses,
    this.onSectionCreated,
  });

  @override
  State<_AddSectionModalContent> createState() =>
      _AddSectionModalContentState();
}

class _AddSectionModalContentState extends State<_AddSectionModalContent> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  final TextEditingController _nameController = TextEditingController();
  int? _selectedCourseId;
  bool _isCreating = false;
  Map<String, String?> _fieldErrors = {};

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleCreate() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCourseId == null) {
      setState(() {
        _fieldErrors['courseId'] = 'Please select a course';
      });
      return;
    }

    setState(() {
      _isCreating = true;
      _fieldErrors = {};
    });

    final response = await _apiService.createSection(
      _nameController.text.trim(),
      _selectedCourseId!,
    );

    setState(() {
      _isCreating = false;
    });

    if (response['success'] == true) {
      if (mounted) {
        widget.onSectionCreated?.call();
        Navigator.of(context).pop();
      }
    } else {
      Map<String, List<String>>? apiErrors =
          response['errors'] as Map<String, List<String>>?;

      setState(() {
        _fieldErrors = {};
        if (apiErrors != null) {
          if (apiErrors.containsKey('Name')) {
            _fieldErrors['name'] = apiErrors['Name']!.first;
          }
          if (apiErrors.containsKey('CourseId')) {
            _fieldErrors['courseId'] = apiErrors['CourseId']!.first;
          }
        }
      });

      _formKey.currentState?.validate();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Failed to create section'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Add Section',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Course Dropdown
              DropdownButtonFormField<int>(
                value: _selectedCourseId,
                decoration: InputDecoration(
                  labelText: 'Course',
                  hintText: 'Select a course',
                  prefixIcon: const Icon(Icons.book, color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: Colors.white.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white, width: 2),
                  ),
                  labelStyle: const TextStyle(color: Colors.white70),
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  errorText: _fieldErrors['courseId'],
                ),
                dropdownColor: const Color(0xFF1E3A8A),
                style: const TextStyle(color: Colors.white),
                items: widget.courses.map((course) {
                  return DropdownMenuItem<int>(
                    value: course['id'] as int,
                    child: Text(course['name']?.toString() ?? 'Unnamed'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCourseId = value;
                    _fieldErrors['courseId'] = null;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a course';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Section Name',
                  hintText: 'Enter section name',
                  prefixIcon:
                      const Icon(Icons.view_list, color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: Colors.white.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white, width: 2),
                  ),
                  labelStyle: const TextStyle(color: Colors.white70),
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  errorText: _fieldErrors['name'],
                ),
                style: const TextStyle(color: Colors.white),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Section name is required';
                  }
                  if (value.trim().length < 4) {
                    return 'Section name must be at least 4 characters';
                  }
                  if (value.trim().length > 100) {
                    return 'Section name must be at most 100 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Create Button
              ElevatedButton(
                onPressed: _isCreating ? null : _handleCreate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF3B82F6),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isCreating
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
                        ),
                      )
                    : const Text(
                        'Create Section',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Edit Section Modal
class _EditSectionModalContent extends StatefulWidget {
  final Map<String, dynamic> section;
  final List<Map<String, dynamic>> courses;
  final VoidCallback? onSectionUpdated;

  const _EditSectionModalContent({
    required this.section,
    required this.courses,
    this.onSectionUpdated,
  });

  @override
  State<_EditSectionModalContent> createState() =>
      _EditSectionModalContentState();
}

class _EditSectionModalContentState extends State<_EditSectionModalContent> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  late final TextEditingController _nameController;
  late int? _selectedCourseId;
  bool _isUpdating = false;
  Map<String, String?> _fieldErrors = {};

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.section['name']?.toString() ?? '');
    _selectedCourseId = widget.section['courseId'] as int?;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isUpdating = true;
      _fieldErrors = {};
    });

    final id = widget.section['id'] as int;
    final response = await _apiService.updateSection(
      id,
      _nameController.text.trim(),
      _selectedCourseId,
    );

    setState(() {
      _isUpdating = false;
    });

    if (response['success'] == true) {
      if (mounted) {
        widget.onSectionUpdated?.call();
        Navigator.of(context).pop();
      }
    } else {
      Map<String, List<String>>? apiErrors =
          response['errors'] as Map<String, List<String>>?;

      setState(() {
        _fieldErrors = {};
        if (apiErrors != null) {
          if (apiErrors.containsKey('Name')) {
            _fieldErrors['name'] = apiErrors['Name']!.first;
          }
          if (apiErrors.containsKey('CourseId')) {
            _fieldErrors['courseId'] = apiErrors['CourseId']!.first;
          }
        }
      });

      _formKey.currentState?.validate();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Failed to update section'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Edit Section',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Course Dropdown
              DropdownButtonFormField<int>(
                value: _selectedCourseId,
                decoration: InputDecoration(
                  labelText: 'Course',
                  hintText: 'Select a course',
                  prefixIcon: const Icon(Icons.book, color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: Colors.white.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white, width: 2),
                  ),
                  labelStyle: const TextStyle(color: Colors.white70),
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  errorText: _fieldErrors['courseId'],
                ),
                dropdownColor: const Color(0xFF1E3A8A),
                style: const TextStyle(color: Colors.white),
                items: widget.courses.map((course) {
                  return DropdownMenuItem<int>(
                    value: course['id'] as int,
                    child: Text(course['name']?.toString() ?? 'Unnamed'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCourseId = value;
                    _fieldErrors['courseId'] = null;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a course';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Section Name',
                  hintText: 'Enter section name',
                  prefixIcon:
                      const Icon(Icons.view_list, color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: Colors.white.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white, width: 2),
                  ),
                  labelStyle: const TextStyle(color: Colors.white70),
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  errorText: _fieldErrors['name'],
                ),
                style: const TextStyle(color: Colors.white),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Section name is required';
                  }
                  if (value.trim().length < 4) {
                    return 'Section name must be at least 4 characters';
                  }
                  if (value.trim().length > 100) {
                    return 'Section name must be at most 100 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Update Button
              ElevatedButton(
                onPressed: _isUpdating ? null : _handleUpdate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF3B82F6),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isUpdating
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
                        ),
                      )
                    : const Text(
                        'Update Section',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Add Schedule Modal
class _AddScheduleModalContent extends StatefulWidget {
  final List<Map<String, dynamic>> subjects;
  final List<Map<String, dynamic>> classrooms;
  final List<Map<String, dynamic>> sections;
  final List<Map<String, dynamic>> instructors;
  final VoidCallback? onScheduleCreated;

  const _AddScheduleModalContent({
    required this.subjects,
    required this.classrooms,
    required this.sections,
    required this.instructors,
    this.onScheduleCreated,
  });

  @override
  State<_AddScheduleModalContent> createState() =>
      _AddScheduleModalContentState();
}

class _AddScheduleModalContentState extends State<_AddScheduleModalContent> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  int? _selectedSubjectId;
  int? _selectedClassroomId;
  int? _selectedSectionId;
  int? _selectedInstructorId;
  String? _selectedDayOfWeek;
  TimeOfDay? _timeIn;
  TimeOfDay? _timeOut;

  final TextEditingController _timeInController = TextEditingController();
  final TextEditingController _timeOutController = TextEditingController();

  bool _isCreating = false;
  Map<String, String?> _fieldErrors = {};

  final List<String> _daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  @override
  void dispose() {
    _timeInController.dispose();
    _timeOutController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(bool isTimeIn) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isTimeIn
          ? (_timeIn ?? TimeOfDay.now())
          : (_timeOut ?? TimeOfDay.now()),
    );
    if (picked != null) {
      setState(() {
        if (isTimeIn) {
          _timeIn = picked;
          _timeInController.text = picked.format(context);
        } else {
          _timeOut = picked;
          _timeOutController.text = picked.format(context);
        }
      });
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute:00';
  }

  Future<void> _handleCreate() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_timeIn == null || _timeOut == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both Start and End times'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isCreating = true;
      _fieldErrors = {};
    });

    final response = await _apiService.createSchedule(
      timeIn: _formatTime(_timeIn!),
      timeOut: _formatTime(_timeOut!),
      dayOfWeek: _selectedDayOfWeek!,
      subjectId: _selectedSubjectId!,
      classroomId: _selectedClassroomId!,
      sectionId: _selectedSectionId!,
      instructorId: _selectedInstructorId!,
    );

    setState(() {
      _isCreating = false;
    });

    if (response['success'] == true) {
      if (mounted) {
        widget.onScheduleCreated?.call();
        Navigator.of(context).pop();
      }
    } else {
      Map<String, List<String>>? apiErrors =
          response['errors'] as Map<String, List<String>>?;

      setState(() {
        _fieldErrors = {};
        if (apiErrors != null) {
          // Map API errors to fields if possible
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Failed to create schedule'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Add Schedule',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Subject Dropdown
              DropdownButtonFormField<int>(
                value: _selectedSubjectId,
                decoration: InputDecoration(
                  hintText: 'Subject',
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                dropdownColor: const Color(0xFF1E3A8A),
                style: const TextStyle(color: Colors.white),
                items: widget.subjects.map((subject) {
                  return DropdownMenuItem<int>(
                    value: subject['id'] as int,
                    child: Text(subject['name']?.toString() ?? 'Unnamed'),
                  );
                }).toList(),
                onChanged: (value) =>
                    setState(() => _selectedSubjectId = value),
                validator: (value) =>
                    value == null ? 'Please select a subject' : null,
              ),
              const SizedBox(height: 16),

              // Classroom Dropdown
              DropdownButtonFormField<int>(
                value: _selectedClassroomId,
                decoration: InputDecoration(
                  hintText: 'Classroom',
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                dropdownColor: const Color(0xFF1E3A8A),
                style: const TextStyle(color: Colors.white),
                items: widget.classrooms.map((classroom) {
                  return DropdownMenuItem<int>(
                    value: classroom['id'] as int,
                    child: Text(classroom['name']?.toString() ?? 'Unnamed'),
                  );
                }).toList(),
                onChanged: (value) =>
                    setState(() => _selectedClassroomId = value),
                validator: (value) =>
                    value == null ? 'Please select a classroom' : null,
              ),
              const SizedBox(height: 16),

              // Section Dropdown
              DropdownButtonFormField<int>(
                value: _selectedSectionId,
                decoration: InputDecoration(
                  hintText: 'Section',
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                dropdownColor: const Color(0xFF1E3A8A),
                style: const TextStyle(color: Colors.white),
                items: widget.sections.map((section) {
                  return DropdownMenuItem<int>(
                    value: section['id'] as int,
                    child: Text(section['name']?.toString() ?? 'Unnamed'),
                  );
                }).toList(),
                onChanged: (value) =>
                    setState(() => _selectedSectionId = value),
                validator: (value) =>
                    value == null ? 'Please select a section' : null,
              ),
              const SizedBox(height: 16),

              // Instructor Dropdown
              DropdownButtonFormField<int>(
                value: _selectedInstructorId,
                decoration: InputDecoration(
                  hintText: 'Instructor',
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                dropdownColor: const Color(0xFF1E3A8A),
                style: const TextStyle(color: Colors.white),
                items: widget.instructors.map((instructor) {
                  final name =
                      '${instructor['firstname']} ${instructor['lastname']}';
                  return DropdownMenuItem<int>(
                    value: instructor['id'] as int,
                    child: Text(name),
                  );
                }).toList(),
                onChanged: (value) =>
                    setState(() => _selectedInstructorId = value),
                validator: (value) =>
                    value == null ? 'Please select an instructor' : null,
              ),
              const SizedBox(height: 16),

              // Day of Week Dropdown
              DropdownButtonFormField<String>(
                value: _selectedDayOfWeek,
                decoration: InputDecoration(
                  hintText: 'Day of Week',
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                dropdownColor: const Color(0xFF1E3A8A),
                style: const TextStyle(color: Colors.white),
                items: _daysOfWeek.map((day) {
                  return DropdownMenuItem<String>(
                    value: day,
                    child: Text(day),
                  );
                }).toList(),
                onChanged: (value) =>
                    setState(() => _selectedDayOfWeek = value),
                validator: (value) =>
                    value == null ? 'Please select a day' : null,
              ),
              const SizedBox(height: 16),

              // Time Pickers
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _timeInController,
                      readOnly: true,
                      onTap: () => _selectTime(true),
                      decoration: InputDecoration(
                        hintText: 'Start Time',
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _timeOutController,
                      readOnly: true,
                      onTap: () => _selectTime(false),
                      decoration: InputDecoration(
                        hintText: 'End Time',
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Create Button
              ElevatedButton(
                onPressed: _isCreating ? null : _handleCreate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF3B82F6),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isCreating
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
                        ),
                      )
                    : const Text(
                        'Create Schedule',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Edit Schedule Modal
class _EditScheduleModalContent extends StatefulWidget {
  final Map<String, dynamic> schedule;
  final List<Map<String, dynamic>> subjects;
  final List<Map<String, dynamic>> classrooms;
  final List<Map<String, dynamic>> sections;
  final List<Map<String, dynamic>> instructors;
  final VoidCallback? onScheduleUpdated;

  const _EditScheduleModalContent({
    required this.schedule,
    required this.subjects,
    required this.classrooms,
    required this.sections,
    required this.instructors,
    this.onScheduleUpdated,
  });

  @override
  State<_EditScheduleModalContent> createState() =>
      _EditScheduleModalContentState();
}

class _EditScheduleModalContentState extends State<_EditScheduleModalContent> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  int? _selectedSubjectId;
  int? _selectedClassroomId;
  int? _selectedSectionId;
  int? _selectedInstructorId;
  String? _selectedDayOfWeek;
  TimeOfDay? _timeIn;
  TimeOfDay? _timeOut;

  final TextEditingController _timeInController = TextEditingController();
  final TextEditingController _timeOutController = TextEditingController();

  bool _isUpdating = false;
  Map<String, String?> _fieldErrors = {};

  final List<String> _daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  @override
  void dispose() {
    _timeInController.dispose();
    _timeOutController.dispose();
    super.dispose();
  }

  void _initializeFields() {
    final schedule = widget.schedule;
    _selectedSubjectId = schedule['subject']?['id'];
    _selectedClassroomId = schedule['classroom']?['id'];
    _selectedSectionId = schedule['section']?['id'];
    _selectedInstructorId = schedule['instructor']?['id'];
    _selectedDayOfWeek = schedule['dayOfWeek'];

    if (schedule['timeIn'] != null) {
      _timeIn = _parseTime(schedule['timeIn']);
      _timeInController.text = _timeIn!.format(context);
    }
    if (schedule['timeOut'] != null) {
      _timeOut = _parseTime(schedule['timeOut']);
      _timeOutController.text = _timeOut!.format(context);
    }
  }

  TimeOfDay _parseTime(String timeStr) {
    try {
      final parts = timeStr.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    } catch (e) {
      return TimeOfDay.now();
    }
  }

  Future<void> _selectTime(bool isTimeIn) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isTimeIn
          ? (_timeIn ?? TimeOfDay.now())
          : (_timeOut ?? TimeOfDay.now()),
    );
    if (picked != null) {
      setState(() {
        if (isTimeIn) {
          _timeIn = picked;
          _timeInController.text = picked.format(context);
        } else {
          _timeOut = picked;
          _timeOutController.text = picked.format(context);
        }
      });
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute:00';
  }

  Future<void> _handleUpdate() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_timeIn == null || _timeOut == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both Start and End times'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isUpdating = true;
      _fieldErrors = {};
    });

    final response = await _apiService.updateSchedule(
      widget.schedule['id'],
      timeIn: _formatTime(_timeIn!),
      timeOut: _formatTime(_timeOut!),
      dayOfWeek: _selectedDayOfWeek!,
      subjectId: _selectedSubjectId!,
      classroomId: _selectedClassroomId!,
      sectionId: _selectedSectionId!,
      instructorId: _selectedInstructorId!,
    );

    setState(() {
      _isUpdating = false;
    });

    if (response['success'] == true) {
      if (mounted) {
        widget.onScheduleUpdated?.call();
        Navigator.of(context).pop();
      }
    } else {
      Map<String, List<String>>? apiErrors =
          response['errors'] as Map<String, List<String>>?;

      setState(() {
        _fieldErrors = {};
        if (apiErrors != null) {
          // Map API errors to fields if possible
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Failed to update schedule'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Edit Schedule',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Subject Dropdown
              DropdownButtonFormField<int>(
                value: _selectedSubjectId,
                decoration: InputDecoration(
                  hintText: 'Subject',
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                dropdownColor: const Color(0xFF1E3A8A),
                style: const TextStyle(color: Colors.white),
                items: widget.subjects.map((subject) {
                  return DropdownMenuItem<int>(
                    value: subject['id'] as int,
                    child: Text(subject['name']?.toString() ?? 'Unnamed'),
                  );
                }).toList(),
                onChanged: (value) =>
                    setState(() => _selectedSubjectId = value),
                validator: (value) =>
                    value == null ? 'Please select a subject' : null,
              ),
              const SizedBox(height: 16),

              // Classroom Dropdown
              DropdownButtonFormField<int>(
                value: _selectedClassroomId,
                decoration: InputDecoration(
                  hintText: 'Classroom',
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                dropdownColor: const Color(0xFF1E3A8A),
                style: const TextStyle(color: Colors.white),
                items: widget.classrooms.map((classroom) {
                  return DropdownMenuItem<int>(
                    value: classroom['id'] as int,
                    child: Text(classroom['name']?.toString() ?? 'Unnamed'),
                  );
                }).toList(),
                onChanged: (value) =>
                    setState(() => _selectedClassroomId = value),
                validator: (value) =>
                    value == null ? 'Please select a classroom' : null,
              ),
              const SizedBox(height: 16),

              // Section Dropdown
              DropdownButtonFormField<int>(
                value: _selectedSectionId,
                decoration: InputDecoration(
                  hintText: 'Section',
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                dropdownColor: const Color(0xFF1E3A8A),
                style: const TextStyle(color: Colors.white),
                items: widget.sections.map((section) {
                  return DropdownMenuItem<int>(
                    value: section['id'] as int,
                    child: Text(section['name']?.toString() ?? 'Unnamed'),
                  );
                }).toList(),
                onChanged: (value) =>
                    setState(() => _selectedSectionId = value),
                validator: (value) =>
                    value == null ? 'Please select a section' : null,
              ),
              const SizedBox(height: 16),

              // Instructor Dropdown
              DropdownButtonFormField<int>(
                value: _selectedInstructorId,
                decoration: InputDecoration(
                  hintText: 'Instructor',
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                dropdownColor: const Color(0xFF1E3A8A),
                style: const TextStyle(color: Colors.white),
                items: widget.instructors.map((instructor) {
                  final name =
                      '${instructor['firstname']} ${instructor['lastname']}';
                  return DropdownMenuItem<int>(
                    value: instructor['id'] as int,
                    child: Text(name),
                  );
                }).toList(),
                onChanged: (value) =>
                    setState(() => _selectedInstructorId = value),
                validator: (value) =>
                    value == null ? 'Please select an instructor' : null,
              ),
              const SizedBox(height: 16),

              // Day of Week Dropdown
              DropdownButtonFormField<String>(
                value: _selectedDayOfWeek,
                decoration: InputDecoration(
                  hintText: 'Day of Week',
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                dropdownColor: const Color(0xFF1E3A8A),
                style: const TextStyle(color: Colors.white),
                items: _daysOfWeek.map((day) {
                  return DropdownMenuItem<String>(
                    value: day,
                    child: Text(day),
                  );
                }).toList(),
                onChanged: (value) =>
                    setState(() => _selectedDayOfWeek = value),
                validator: (value) =>
                    value == null ? 'Please select a day' : null,
              ),
              const SizedBox(height: 16),

              // Time Pickers
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _timeInController,
                      readOnly: true,
                      onTap: () => _selectTime(true),
                      decoration: InputDecoration(
                        hintText: 'Start Time',
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _timeOutController,
                      readOnly: true,
                      onTap: () => _selectTime(false),
                      decoration: InputDecoration(
                        hintText: 'End Time',
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Update Button
              ElevatedButton(
                onPressed: _isUpdating ? null : _handleUpdate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF3B82F6),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isUpdating
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
                        ),
                      )
                    : const Text(
                        'Update Schedule',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Add Subject Modal
class _AddSubjectModalContent extends StatefulWidget {
  final VoidCallback? onSubjectCreated;

  const _AddSubjectModalContent({
    this.onSubjectCreated,
  });

  @override
  State<_AddSubjectModalContent> createState() =>
      _AddSubjectModalContentState();
}

class _AddSubjectModalContentState extends State<_AddSubjectModalContent> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  bool _isCreating = false;
  Map<String, String?> _fieldErrors = {};

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _handleCreate() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isCreating = true;
      _fieldErrors = {};
    });

    final response = await _apiService.createSubject(
      _nameController.text.trim(),
      _codeController.text.trim(),
    );

    setState(() {
      _isCreating = false;
    });

    if (response['success'] == true) {
      if (mounted) {
        widget.onSubjectCreated?.call();
        Navigator.of(context).pop();
      }
    } else {
      Map<String, List<String>>? apiErrors =
          response['errors'] as Map<String, List<String>>?;

      setState(() {
        _fieldErrors = {};
        if (apiErrors != null) {
          if (apiErrors.containsKey('Name')) {
            _fieldErrors['name'] = apiErrors['Name']!.first;
          }
          if (apiErrors.containsKey('Code')) {
            _fieldErrors['code'] = apiErrors['Code']!.first;
          }
        }
      });

      _formKey.currentState?.validate();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Failed to create subject'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Add Subject',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Subject Name',
                  hintText: 'Enter subject name',
                  prefixIcon: const Icon(Icons.subject, color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: Colors.white.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white, width: 2),
                  ),
                  labelStyle: const TextStyle(color: Colors.white70),
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  errorText: _fieldErrors['name'],
                ),
                style: const TextStyle(color: Colors.white),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Subject name is required';
                  }
                  if (value.trim().length < 2) {
                    return 'Subject name must be at least 2 characters';
                  }
                  if (value.trim().length > 100) {
                    return 'Subject name must be at most 100 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Code Field
              TextFormField(
                controller: _codeController,
                decoration: InputDecoration(
                  labelText: 'Subject Code',
                  hintText: 'Enter subject code',
                  prefixIcon: const Icon(Icons.code, color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: Colors.white.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white, width: 2),
                  ),
                  labelStyle: const TextStyle(color: Colors.white70),
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  errorText: _fieldErrors['code'],
                ),
                style: const TextStyle(color: Colors.white),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Subject code is required';
                  }
                  if (value.trim().length < 5) {
                    return 'Subject code must be at least 5 characters';
                  }
                  if (value.trim().length > 30) {
                    return 'Subject code must be at most 30 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Create Button
              ElevatedButton(
                onPressed: _isCreating ? null : _handleCreate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF3B82F6),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isCreating
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
                        ),
                      )
                    : const Text(
                        'Create Subject',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Edit Subject Modal
class _EditSubjectModalContent extends StatefulWidget {
  final Map<String, dynamic> subject;
  final VoidCallback? onSubjectUpdated;

  const _EditSubjectModalContent({
    required this.subject,
    this.onSubjectUpdated,
  });

  @override
  State<_EditSubjectModalContent> createState() =>
      _EditSubjectModalContentState();
}

class _EditSubjectModalContentState extends State<_EditSubjectModalContent> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  late final TextEditingController _nameController;
  late final TextEditingController _codeController;
  bool _isUpdating = false;
  Map<String, String?> _fieldErrors = {};

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.subject['name']?.toString() ?? '');
    _codeController =
        TextEditingController(text: widget.subject['code']?.toString() ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isUpdating = true;
      _fieldErrors = {};
    });

    final id = widget.subject['id'] as int;
    final response = await _apiService.updateSubject(
      id,
      _nameController.text.trim().isNotEmpty
          ? _nameController.text.trim()
          : null,
      _codeController.text.trim().isNotEmpty
          ? _codeController.text.trim()
          : null,
    );

    setState(() {
      _isUpdating = false;
    });

    if (response['success'] == true) {
      if (mounted) {
        widget.onSubjectUpdated?.call();
        Navigator.of(context).pop();
      }
    } else {
      Map<String, List<String>>? apiErrors =
          response['errors'] as Map<String, List<String>>?;

      setState(() {
        _fieldErrors = {};
        if (apiErrors != null) {
          if (apiErrors.containsKey('Name')) {
            _fieldErrors['name'] = apiErrors['Name']!.first;
          }
          if (apiErrors.containsKey('Code')) {
            _fieldErrors['code'] = apiErrors['Code']!.first;
          }
        }
      });

      _formKey.currentState?.validate();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Failed to update subject'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Edit Subject',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Subject Name',
                  hintText: 'Enter subject name',
                  prefixIcon: const Icon(Icons.subject, color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: Colors.white.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white, width: 2),
                  ),
                  labelStyle: const TextStyle(color: Colors.white70),
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  errorText: _fieldErrors['name'],
                ),
                style: const TextStyle(color: Colors.white),
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    if (value.trim().length < 2) {
                      return 'Subject name must be at least 2 characters';
                    }
                    if (value.trim().length > 100) {
                      return 'Subject name must be at most 100 characters';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Code Field
              TextFormField(
                controller: _codeController,
                decoration: InputDecoration(
                  labelText: 'Subject Code',
                  hintText: 'Enter subject code',
                  prefixIcon: const Icon(Icons.code, color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: Colors.white.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white, width: 2),
                  ),
                  labelStyle: const TextStyle(color: Colors.white70),
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  errorText: _fieldErrors['code'],
                ),
                style: const TextStyle(color: Colors.white),
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    if (value.trim().length < 5) {
                      return 'Subject code must be at least 5 characters';
                    }
                    if (value.trim().length > 30) {
                      return 'Subject code must be at most 30 characters';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Update Button
              ElevatedButton(
                onPressed: _isUpdating ? null : _handleUpdate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF3B82F6),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isUpdating
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
                        ),
                      )
                    : const Text(
                        'Update Subject',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
