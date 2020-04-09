def init(self,domain=None,ytt_files=[],docker_registry=None):
  self.domain = domain
  self.__class__.name = "cf-for-k8s"
  self.ytt_files = ytt_files
  self.docker_registry = docker_registry
  self.cf_admin_password = user_credential("cf-admin-password-shalm",username="admin")
  self.secret_key = user_credential("secret-key-shalm",username="admin")
  self.cf_db_admin_password = user_credential("cf-db-admin-password-shalm",username="admin")
  self.capi_database_password = user_credential("capi-database-password-shalm",username="admin")
  self.ca = certificate("ca-shalm",is_ca=True)
  self.system_certificate = certificate("system-certificate-shalm",signer=self.ca,domains=["*.cf-system.svc.cluster.local" ])
  self.log_cache_ca = certificate("log-cache-ca-shalm",is_ca=True)
  self.log_cache = certificate("log-cache-shalm",signer=self.log_cache_ca,domains=["log-cache"])
  self.log_cache_metrics = certificate("log-cache-metrics-shalm",signer=self.log_cache_ca,domains=["log-cache-metrics"])
  self.log_cache_gateway = certificate("log-cache-gateway-shalm",signer=self.log_cache_ca,domains=["log-cache-gateway","localhost"])
  self.log_cache_syslog = certificate("log-cache-syslog-shalm",signer=self.log_cache_ca,domains=["log-cache-syslog"])
  self.log_cache_client = user_credential("log-cache-client-shalm")
  self.metric_proxy_ca = certificate("metrics-proxy-ca-shalm",is_ca=True)
  self.metric_proxy = certificate("metrics-proxy-shalm",signer=self.metric_proxy_ca,domains=["metric-proxy"])

  
  self.uaa_db_password= user_credential("uaa-db-password-shalm",username="admin")
  self.uaa_admin_client_secret= user_credential("uaa-admin-client-secret-shalm",username="admin")
  self.uaa_jwt_policy_signing_key = certificate("uaa-jwt-policy-signing-key-shalm",signer=self.ca,domains=["uaa-jwt-policy-signing-key"])
  self.uaa_login_service_provider = certificate("uaa-login-service-provider-shalm",signer=self.ca,domains=["uaa-login-service-provider"])
  self.uaa_encryption_key_passphrase= user_credential("uaa-encryption-key-passphrase-shalm",username="admin")
  self.docker_registry_http_secret= user_credential("docker-registry-http-secret-shalm",username="admin")

def template(self,glob=""):
  return self.ytt("config",self.helm("templates",glob="values.yaml"),*self.ytt_files)


def apply(self,k8s):
  if not self.domain:
    fail("Mandatory parameter domain not set. Use --set domain=... to pass this parameter.")
  k8s.tool = "kapp"
  self.__apply(k8s)
  k8s.rollout_status("deployment","capi-api-server",namespace='cf-system')


def delete(self,k8s):
  if not self.domain:
    fail("Mandatory parameter domain not set. Use --set domain=... to pass this parameter.")
  k8s.tool = "kapp"
  self.__delete(k8s)

def credentials(self):
  return struct(username=self.cf_admin_password.username, password=self.cf_admin_password.password,url="https://api." + self.domain)

def uaa_credentials(self):
  return struct(url="https://uaa." + self.domain,client_secret=self.uaa_admin_client_secret.password, client_id=self.uaa_admin_client_secret.username)