class ClientStatisticsModel {
  final int total;
  final int pending;
  final int inProgress;
  final int validated;
  final int rejected;

  const ClientStatisticsModel({
    this.total = 0,
    this.pending = 0,
    this.inProgress = 0,
    this.validated = 0,
    this.rejected = 0,
  });

  factory ClientStatisticsModel.fromJson(Map<String, dynamic> json) {
    return ClientStatisticsModel(
      total:      (json['total']      as num?)?.toInt() ?? 0,
      pending:    (json['pending']    as num?)?.toInt() ?? 0,
      inProgress: (json['inProgress'] as num?)?.toInt() ?? 0,
      validated:  (json['validated']  as num?)?.toInt() ?? 0,
      rejected:   (json['rejected']   as num?)?.toInt() ?? 0,
    );
  }
}
