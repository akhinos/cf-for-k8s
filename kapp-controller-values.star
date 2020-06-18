load("@ytt:yaml", "yaml")

docker_registry = yaml.decode(env("DOCKER_REGISTRY"))
cf4k8s = chart(".", domain=env("CF_DOMAIN"), docker_registry=docker_registry)
print(cf4k8s.kapp_controller_values())
