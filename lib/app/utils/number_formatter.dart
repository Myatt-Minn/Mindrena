extension NumberFormatter on int {
  String formatCompact() {
    if (this >= 1000000) {
      return '${(this / 1000000).toStringAsFixed(1)}M';
    } else if (this >= 1000) {
      return '${(this / 1000).toStringAsFixed(1)}K';
    } else {
      return toString();
    }
  }

  String formatWithCommas() {
    return toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match match) => '${match[1]},',
    );
  }
}

extension DoubleFormatter on double {
  String formatPercentage({int decimals = 1}) {
    return '${toStringAsFixed(decimals)}%';
  }
}
