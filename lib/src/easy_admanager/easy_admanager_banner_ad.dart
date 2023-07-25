import 'package:easy_ads_flutter/src/easy_ad_base.dart';
import 'package:easy_ads_flutter/src/enums/ad_network.dart';
import 'package:easy_ads_flutter/src/enums/ad_unit_type.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class EasyAdManagerBannerAd extends EasyAdBase {
  final AdManagerAdRequest _adRequest;
  final AdSize adSize;

  EasyAdManagerBannerAd(
    String adUnitId, {
    AdManagerAdRequest? adRequest,
    this.adSize = AdSize.banner,
  })  : _adRequest = adRequest ?? const AdManagerAdRequest(),
        super(adUnitId);

  AdManagerBannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  AdUnitType get adUnitType => AdUnitType.banner;

  @override
  AdNetwork get adNetwork => AdNetwork.adManager;

  @override
  void dispose() {
    _isAdLoaded = false;
    _bannerAd?.dispose();
    _bannerAd = null;
  }

  @override
  bool get isAdLoaded => _isAdLoaded;

  @override
  Future<void> load() async {
    await _bannerAd?.dispose();
    _bannerAd = null;
    _isAdLoaded = false;

    _bannerAd = AdManagerBannerAd(
      sizes: [adSize],
      adUnitId: adUnitId,
      listener: AdManagerBannerAdListener(
        onAdLoaded: (Ad ad) {
          _bannerAd = ad as AdManagerBannerAd?;
          _isAdLoaded = true;
          onAdLoaded?.call(adNetwork, adUnitType, ad);
          onBannerAdReadyForSetState?.call(adNetwork, adUnitType, ad);
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          _bannerAd = null;
          _isAdLoaded = false;
          onAdFailedToLoad?.call(adNetwork, adUnitType, ad, error.toString());
          ad.dispose();
        },
        onAdOpened: (Ad ad) => onAdClicked?.call(adNetwork, adUnitType, ad),
        onAdClosed: (Ad ad) => onAdDismissed?.call(adNetwork, adUnitType, ad),
        onAdImpression: (Ad ad) => onAdShowed?.call(adNetwork, adUnitType, ad),
      ),
      request: _adRequest,
    );
    _bannerAd?.load();
  }

  @override
  dynamic show() {
    if (_bannerAd == null || _isAdLoaded == false) {
      load();
      return const SizedBox();
    }

    return Container(
      alignment: Alignment.center,
      height: adSize.height.toDouble(),
      width: adSize.width.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
