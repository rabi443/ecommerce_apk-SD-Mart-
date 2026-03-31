import 'package:get/get.dart';
import '../AdModel/AdModel.dart';
import '../AdService/AdService.dart';

class AdController extends GetxController {
  var ads = <AdModel>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    fetchAds();
    super.onInit();
  }

  Future<void> fetchAds() async {
    try {
      isLoading(true);
      errorMessage('');
      final result = await AdService.fetchAds();
      result.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
      ads.assignAll(result);
    } catch (e) {
      errorMessage(e.toString());
    } finally {
      isLoading(false);
    }
  }
}