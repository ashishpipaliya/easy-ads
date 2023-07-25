import 'package:easy_ads_flutter/easy_ads_flutter.dart';

class EasyAdManagerAppOpenAd extends EasyAdBase {
  final AdManagerAdRequest _adRequest;
  final int _orientation;

  EasyAdManagerAppOpenAd(super.adUnitId, this._adRequest, this._orientation);

  AppOpenAd? _appOpenAd;
  bool _isShowingAd = false;

  @override
  AdNetwork get adNetwork => AdNetwork.adManager;

  @override
  AdUnitType get adUnitType => AdUnitType.appOpen;

  @override
  bool get isAdLoaded => _appOpenAd != null;

  @override
  void dispose() {
    _appOpenAd?.dispose();
    _appOpenAd = null;
  }

  @override
  Future<void> load() {
    if (isAdLoaded) return Future.value();

    return AppOpenAd.loadWithAdManagerAdRequest(
      adUnitId: adUnitId,
      adManagerAdRequest: _adRequest,
      orientation: _orientation,
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (AppOpenAd ad) {
          _appOpenAd = ad;
          onAdLoaded?.call(adNetwork, adUnitType, ad);
        },
        onAdFailedToLoad: (LoadAdError error) {
          _appOpenAd = null;
          onAdFailedToLoad?.call(adNetwork, adUnitType, error, error.toString());
        },
      ),
    );
  }

  @override
  show() async {
    if (!isAdLoaded) {
      await load();
      return;
    }

    if (_isShowingAd) {
      onAdFailedToShow?.call(adNetwork, adUnitType, null, 'Tried to show ad while already showing an ad.');
      return;
    }

    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (AppOpenAd ad) {
        _isShowingAd = true;

        onAdShowed?.call(adNetwork, adUnitType, ad);
      },
      onAdDismissedFullScreenContent: (AppOpenAd ad) {
        _isShowingAd = false;

        onAdDismissed?.call(adNetwork, adUnitType, ad);
        ad.dispose();
        _appOpenAd = null;
        load();
      },
      onAdFailedToShowFullScreenContent: (AppOpenAd ad, AdError error) {
        _isShowingAd = false;

        onAdFailedToShow?.call(adNetwork, adUnitType, ad, error.toString());

        ad.dispose();
        _appOpenAd = null;
        load();
      },
    );

    _appOpenAd!.show();
    _appOpenAd = null;
    _isShowingAd = false;
  }
}
