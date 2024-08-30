class ServiceAccountModel {
  final String type;
  final String projectId;
  final String privateKeyId;
  final String privateKey;
  final String clientEmail;
  final String clientId;
  final String authUri;
  final String tokenUri;
  final String authProviderX509CertUrl;
  final String clientX509CertUrl;
  final String universeDomain;

  ServiceAccountModel({
    required this.type,
    required this.projectId,
    required this.privateKeyId,
    required this.privateKey,
    required this.clientEmail,
    required this.clientId,
    required this.authUri,
    required this.tokenUri,
    required this.authProviderX509CertUrl,
    required this.clientX509CertUrl,
    required this.universeDomain,
  });

  factory ServiceAccountModel.fromJson(Map<String, dynamic> json) {
    return ServiceAccountModel(
      type: json['type'] ?? '',
      projectId: json['project_id'] ?? '',
      privateKeyId: json['private_key_id'] ?? '',
      privateKey: json['private_key'] ?? '',
      clientEmail: json['client_email'] ?? '',
      clientId: json['client_id'] ?? '',
      authUri: json['auth_uri'] ?? '',
      tokenUri: json['token_uri'] ?? '',
      authProviderX509CertUrl: json['auth_provider_x509_cert_url'] ?? '',
      clientX509CertUrl: json['client_x509_cert_url'] ?? '',
      universeDomain: json['universe_domain'] ?? '',
    );
  }

  @override
  String toString() {
    return 'ServiceAccountModel(type: $type, projectId: $projectId, privateKeyId: $privateKeyId, privateKey: $privateKey, clientEmail: $clientEmail, clientId: $clientId, authUri: $authUri, tokenUri: $tokenUri, authProviderX509CertUrl: $authProviderX509CertUrl, clientX509CertUrl: $clientX509CertUrl, universeDomain: $universeDomain)';
  }
}
