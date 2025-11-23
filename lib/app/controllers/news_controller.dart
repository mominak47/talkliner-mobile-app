import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:talkliner/app/services/api_service.dart';

class NewsController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  
  final RxList<NewsModel> news = <NewsModel>[].obs;
  final RxBool isLoading = false.obs;
  final Rxn<String> error = Rxn<String>();

  @override
  void onInit() {
    super.onInit();
    fetchNews();
  }

  Future<void> fetchNews() async {
    if (isLoading.value) return;
    
    isLoading.value = true;
    error.value = null;
    
    try {
      final response = await _apiService.makeGetRequest('/news');
      
      if (response.isOk && response.body != null) {
        final newsData = response.body['data'];
        if (newsData is List) {
          news.assignAll(
            newsData.map((item) => NewsModel.fromJson(item)).toList(),
          );
          debugPrint('[NewsController] Fetched ${news.length} news items');
        } else {
          throw Exception('Invalid news data format');
        }
      } else {
        error.value = response.statusText ?? 'Failed to fetch news';
        debugPrint('[NewsController] Error: ${error.value}');
      }
    } catch (e) {
      error.value = 'Failed to load news: $e';
      debugPrint('[NewsController] Exception: $e');
    } finally {
      isLoading.value = false;
    }
  }
}

// News Model
class NewsModel {
  final int id;
  final String title;
  final String description;
  final String image;
  final String createdAt;

  NewsModel({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    required this.createdAt,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      image: json['image'] ?? '', // Return empty string if null
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image': image,
      'created_at': createdAt,
    };
  }
}