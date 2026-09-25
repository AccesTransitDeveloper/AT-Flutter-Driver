class WorkFlowRequest {
  final int workflowType;
  final List<int> priceModes;

  const WorkFlowRequest({
    required this.workflowType,
    required this.priceModes,
  });

  Map<String, dynamic> toJson() => {
        'workflowType': workflowType,
        'priceModes': priceModes,
      };
}
