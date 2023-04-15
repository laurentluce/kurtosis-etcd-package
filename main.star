ETCD_IMAGE = "softlang/etcd-alpine:v3.4.14"

ETCD_CLIENT_PORT_ID = "client"
ETCD_CLIENT_PORT_NUMBER = 2379
ETCD_CLIENT_PORT_PROTOCOL = "TCP"

ETCD_SERVICE_NAME = "etcd"

def run(plan, args):

    etcd_service_config= ServiceConfig(
        image = ETCD_IMAGE,
        ports = {
            ETCD_CLIENT_PORT_ID: PortSpec(number = ETCD_CLIENT_PORT_NUMBER, transport_protocol = ETCD_CLIENT_PORT_PROTOCOL)
        },
        env_vars = {
            "ALLOW_NONE_AUTHENTICATION": "yes",
            "ETCD_DATA_DIR": "/etcd_data"
        },
        # Check condition here once ExecRecipe is supported
        #ready_conditions = ReadyCondition(
        #    recipe = ExecRecipe(
        #        command = ["etcdctl", "get", "test"]
        #    ),
        #    field = "code",
        #    assertion = "==",
        #    target_value = 0
        #)
    )

    etcd = plan.add_service(name = ETCD_SERVICE_NAME, config = etcd_service_config)

    check_etcdctl = ExecRecipe(
        command = ["etcdctl", "get", "test"],
    )
    plan.wait(recipe = check_etcdctl, field = "code", assertion = "==", target_value = 0, timeout = "8m", service_name = ETCD_SERVICE_NAME)

    return {"service-name": ETCD_SERVICE_NAME, "hostname": etcd.hostname}
