import 'dart:async';

class MonetizationManager {
  static final MonetizationManager _instance = MonetizationManager._internal();
  factory MonetizationManager() => _instance;
  MonetizationManager._internal();

  // 1. Wallet Balance in Tomans (Default: 1,250,000 Tomans)
  double walletBalance = 1250000;

  // 2. Subscription Tier (Bronze, Silver, Gold)
  String activeSubscription = 'Bronze';

  // 3. Expert Bidding Coins (Default: 15 coins)
  int biddingCoins = 15;

  // 4. Transaction History
  final List<Map<String, dynamic>> transactions = [
    {
      'title': 'شارژ مستقیم کیف پول دیجیتال',
      'amount': 500000.0,
      'isIncome': true,
      'date': 'امروز',
      'icon': '💳',
    },
    {
      'title': 'دریافت کارمزد تراکنش خدمت لوله‌کشی (علی رضایی)',
      'amount': 35000.0,
      'isIncome': true,
      'date': 'دیروز',
      'icon': '🛠️',
    },
    {
      'title': 'دریافت کارمزد فروش گجت در غرفه تک‌هاب',
      'amount': 15000.0,
      'isIncome': true,
      'date': '۲ روز پیش',
      'icon': '🛍️',
    },
    {
      'title': 'خرید بسته ۲۵تایی سکه پیشنهاد متخصص',
      'amount': -50000.0,
      'isIncome': false,
      'date': '۳ روز پیش',
      'icon': '🪙',
    },
  ];

  // Stream controller to notify UI of changes
  final _stateController = StreamController<void>.broadcast();
  Stream<void> get onStateChanged => _stateController.stream;

  void notify() {
    _stateController.add(null);
  }

  bool buySubscription(String tier, double price) {
    if (walletBalance >= price) {
      walletBalance -= price;
      activeSubscription = tier;
      addTransaction(
        'خرید و ارتقای اشتراک به لایه $tier غرفه‌داری',
        -price,
        false,
        '👑',
      );
      return true;
    }
    return false;
  }

  bool buyCoins(int count, double price) {
    if (walletBalance >= price) {
      walletBalance -= price;
      biddingCoins += count;
      addTransaction(
        'خرید بسته $count عددی سکه پیشنهاد متخصص',
        -price,
        false,
        '🪙',
      );
      return true;
    }
    return false;
  }

  void depositWallet(double amount) {
    walletBalance += amount;
    addTransaction('افزایش اعتبار کیف پول دیجیتال', amount, true, '💳');
  }

  void addTransaction(String title, double amount, bool isIncome, String icon) {
    transactions.insert(0, {
      'title': title,
      'amount': amount.abs(),
      'isIncome': isIncome,
      'date': 'هم‌اکنون',
      'icon': icon,
    });
    notify();
  }
}
