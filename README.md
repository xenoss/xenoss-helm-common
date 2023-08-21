# Xenoss Common Library Chart

A [Helm Library Chart](https://helm.sh/docs/topics/library_charts/#helm) for grouping common logic between Xenoss charts.

## TL;DR

```yaml
dependencies:
  - name: common
    version: 1.x.x
    repository: https://docker.xenoss.io
```

```console
helm dependency update
```

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "common.fullname" . }}
data:
  myvalue: "Hello World"
```

