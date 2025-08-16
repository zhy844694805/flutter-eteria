import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/memorial.dart';

class MemorialService {
  static const String _memorialsKey = 'memorials';
  static MemorialService? _instance;
  SharedPreferences? _prefs;

  MemorialService._();

  static Future<MemorialService> getInstance() async {
    _instance ??= MemorialService._();
    _instance!._prefs ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  // 获取所有纪念
  Future<List<Memorial>> getMemorials() async {
    final String? memorialsJson = _prefs?.getString(_memorialsKey);
    if (memorialsJson == null) return [];
    
    try {
      final List<dynamic> memorialsList = json.decode(memorialsJson);
      return memorialsList.map((json) => Memorial.fromJson(json)).toList();
    } catch (e) {
      print('Error loading memorials: $e');
      return [];
    }
  }

  // 保存纪念
  Future<bool> saveMemorial(Memorial memorial) async {
    try {
      final memorials = await getMemorials();
      memorials.add(memorial);
      await _saveMemorials(memorials);
      return true;
    } catch (e) {
      print('Error saving memorial: $e');
      return false;
    }
  }

  // 更新纪念
  Future<bool> updateMemorial(Memorial memorial) async {
    try {
      final memorials = await getMemorials();
      final index = memorials.indexWhere((m) => m.id == memorial.id);
      if (index != -1) {
        memorials[index] = memorial;
        await _saveMemorials(memorials);
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating memorial: $e');
      return false;
    }
  }

  // 删除纪念
  Future<bool> deleteMemorial(int id) async {
    try {
      final memorials = await getMemorials();
      memorials.removeWhere((memorial) => memorial.id == id);
      await _saveMemorials(memorials);
      return true;
    } catch (e) {
      print('Error deleting memorial: $e');
      return false;
    }
  }

  // 私有方法：保存纪念列表
  Future<void> _saveMemorials(List<Memorial> memorials) async {
    final String memorialsJson = json.encode(
      memorials.map((memorial) => memorial.toJson()).toList(),
    );
    await _prefs?.setString(_memorialsKey, memorialsJson);
  }

  // 清空所有数据
  Future<void> clearAll() async {
    await _prefs?.remove(_memorialsKey);
  }

  // 获取模拟数据
  static List<Memorial> getMockData() {
    return [
      Memorial(
        id: 1,
        type: MemorialType.person,
        name: '张奶奶',
        birthDate: DateTime(1935, 8, 10),
        deathDate: DateTime(2023, 10, 15),
        description: '慈祥的奶奶，用一生的爱呵护着家人。她的笑容和温暖的怀抱永远留在我们心中。愿奶奶在天堂安好，我们永远怀念您。',
        imageUrls: [
          'https://images.unsplash.com/photo-1551836022-d5d88e9218df?w=400&h=300&fit=crop',
          'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400&h=300&fit=crop',
          'https://images.unsplash.com/photo-1609220136736-443140cffec6?w=400&h=300&fit=crop'
        ],
        isPublic: true,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      Memorial(
        id: 2,
        type: MemorialType.person,
        name: '李爷爷',
        birthDate: DateTime(1940, 3, 22),
        deathDate: DateTime(2023, 9, 30),
        description: '和蔼可亲的爷爷，总是有很多有趣的故事跟我们分享。他教会了我们做人的道理，他的智慧和温暖将永远伴随着我们。',
        imageUrls: [
          'https://images.unsplash.com/photo-1552053831-71594a27632d?w=400&h=300&fit=crop',
          'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?w=400&h=300&fit=crop'
        ],
        isPublic: true,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        updatedAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
      Memorial(
        id: 3,
        type: MemorialType.person,
        name: '王叔叔',
        birthDate: DateTime(1975, 11, 8),
        deathDate: DateTime(2023, 12, 5),
        description: '亲爱的叔叔，您是我们家的开心果，总是带给大家欢声笑语。虽然您离开了我们，但您的音容笑貌永远活在我们心中。',
        imageUrls: [
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=300&fit=crop',
          'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400&h=300&fit=crop',
          'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=400&h=300&fit=crop',
          'https://images.unsplash.com/photo-1519345182560-3f2917c472ef?w=400&h=300&fit=crop'
        ],
        isPublic: true,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Memorial(
        id: 4,
        type: MemorialType.person,
        name: '陈阿姨',
        birthDate: DateTime(1958, 6, 18),
        deathDate: DateTime(2023, 11, 22),
        description: '温柔善良的陈阿姨，总是把最好的留给别人。她的爱心和无私奉献精神激励着我们每一个人。',
        imageUrls: [
          'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=400&h=300&fit=crop',
          'https://images.unsplash.com/photo-1494790108755-2616c96565c6?w=400&h=300&fit=crop'
        ],
        isPublic: true,
        createdAt: DateTime.now().subtract(const Duration(days: 8)),
        updatedAt: DateTime.now().subtract(const Duration(days: 8)),
      ),
      Memorial(
        id: 5,
        type: MemorialType.person,
        name: '赵老师',
        birthDate: DateTime(1945, 4, 3),
        deathDate: DateTime(2023, 8, 14),
        description: '敬爱的赵老师，您用知识点亮了无数学生的心灵。您的教诲如甘露，滋润着我们成长的每一个阶段。',
        imageUrls: [
          'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=400&h=300&fit=crop',
          'https://images.unsplash.com/photo-1582750433449-648ed127bb54?w=400&h=300&fit=crop',
          'https://images.unsplash.com/photo-1607990281513-2c110a25bd8c?w=400&h=300&fit=crop'
        ],
        isPublic: true,
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
        updatedAt: DateTime.now().subtract(const Duration(days: 25)),
      ),
      Memorial(
        id: 6,
        type: MemorialType.person,
        name: '小明',
        birthDate: DateTime(1995, 9, 12),
        deathDate: DateTime(2023, 7, 30),
        description: '我们的好朋友小明，总是那么阳光开朗。虽然您英年早逝，但您的笑容和友谊将永远温暖着我们的心。',
        imageUrls: [
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=300&fit=crop',
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400&h=300&fit=crop'
        ],
        isPublic: true,
        createdAt: DateTime.now().subtract(const Duration(days: 12)),
        updatedAt: DateTime.now().subtract(const Duration(days: 12)),
      ),
      Memorial(
        id: 7,
        type: MemorialType.person,
        name: '刘奶奶',
        birthDate: DateTime(1932, 12, 25),
        deathDate: DateTime(2023, 6, 8),
        description: '亲爱的刘奶奶，您的手艺和关爱是我们童年最美好的回忆。您做的饭菜至今还是我们心中最香的味道。',
        imageUrls: [
          'https://images.unsplash.com/photo-1594824891470-b8be40d79d74?w=400&h=300&fit=crop',
          'https://images.unsplash.com/photo-1508214751196-bcfd4ca60f91?w=400&h=300&fit=crop',
          'https://images.unsplash.com/photo-1548013146-72479768bada?w=400&h=300&fit=crop',
          'https://images.unsplash.com/photo-1551836022-aadb801c60ae?w=400&h=300&fit=crop'
        ],
        isPublic: true,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      Memorial(
        id: 8,
        type: MemorialType.person,
        name: '马大夫',
        birthDate: DateTime(1955, 2, 14),
        deathDate: DateTime(2023, 9, 5),
        description: '尊敬的马大夫，您救死扶伤的精神永远值得我们学习。您的医者仁心让无数患者重获健康。',
        imageUrls: [
          'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?w=400&h=300&fit=crop',
          'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=400&h=300&fit=crop',
          'https://images.unsplash.com/photo-1582750433449-648ed127bb54?w=400&h=300&fit=crop'
        ],
        isPublic: true,
        createdAt: DateTime.now().subtract(const Duration(days: 18)),
        updatedAt: DateTime.now().subtract(const Duration(days: 18)),
      ),
    ];
  }

  // 初始化模拟数据
  Future<void> initializeMockData() async {
    final existingMemorials = await getMemorials();
    if (existingMemorials.isEmpty) {
      final mockData = getMockData();
      await _saveMemorials(mockData);
    }
  }
}