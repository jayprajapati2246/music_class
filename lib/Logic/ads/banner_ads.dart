import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class BannerAds extends GetxController {
  BannerAd? bannerAd;
  bool isLoaded = false;

  Future<void> loadAd(double width) async {
    if (bannerAd != null) return;

    final size =
    await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
      width.truncate(),
    );

    if (size == null) return;

    bannerAd = BannerAd(
      adUnitId: "ca-app-pub-3940256099942544/9214589741",
      request: const AdRequest(),
      size: size,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint("Banner Ad Loaded");
          isLoaded = true;
          update();
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint("Banner Ad Failed: $error");
          ad.dispose();
        },
      ),
    );

    await bannerAd!.load();
  }

  @override
  void onClose() {
    bannerAd?.dispose();
    super.onClose();
  }
}