
# Manually reconfigure Docker on each Kubernetes worker node.

* put the DNS stuff in `/etc/docker/daemon.json`
* `systemctl daemon-reload`
* `systemctl restart docker`


```
{  "dns": ["100.64.0.10", "192.168.0.1"]
,  "dns-opts": ["ndots:2", "timeout:2", "attempts:2"]
,  "dns-search": ["hltest.svc.cluster.local", "default.svc.cluster.local", "svc.cluster.local"]
}
```
