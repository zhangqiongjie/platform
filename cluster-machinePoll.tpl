apiVersion: cluster.x-k8s.io/v1beta1
kind: Cluster
metadata:
  name: {{.ClusterName}}
  namespace: {{.Namespace}}
spec:
  controlPlaneRef:
    apiVersion: controlplane.cluster.x-k8s.io/v1beta1
    kind: KubeadmControlPlane
    name: {{.ClusterName}}-control-plane
  infrastructureRef:
    apiVersion: infrastructure.cluster.x-k8s.io/v1beta1
    kind: AWSCluster
    name: {{.ClusterName}}
---
apiVersion: infrastructure.cluster.x-k8s.io/v1beta1
kind: AWSCluster
metadata:
  name: {{.ClusterName}}
  namespace: {{.Namespace}}
spec:
  region: us-east-1
  sshKeyName: bs-kevin-test
---
apiVersion: controlplane.cluster.x-k8s.io/v1beta1
kind: KubeadmControlPlane
metadata:
  name: {{.ClusterName}}-control-plane
  namespace: {{.Namespace}}
spec:
  kubeadmConfigSpec:
    clusterConfiguration:
      apiServer:
        extraArgs:
          cloud-provider: aws
      controllerManager:
        extraArgs:
          cloud-provider: aws
    initConfiguration:
      nodeRegistration:
        kubeletExtraArgs:
          cloud-provider: aws
    joinConfiguration:
      nodeRegistration:
        kubeletExtraArgs:
          cloud-provider: aws
  machineTemplate:
    infrastructureRef:
      apiVersion: infrastructure.cluster.x-k8s.io/v1beta1
      kind: AWSMachineTemplate
      name: {{.ClusterName}}-control-plane
  replicas: {{.KubeadmControlPlane.Replicas}}
  version: {{.KubeadmControlPlane.Version}}
---
apiVersion: infrastructure.cluster.x-k8s.io/v1beta1
kind: AWSMachineTemplate
metadata:
  name: {{.ClusterName}}-control-plane
  namespace: {{.Namespace}}
spec:
  template:
    spec:
      iamInstanceProfile: control-plane.cluster-api-provider-aws.sigs.k8s.io
      instanceType: t2.medium
      sshKeyName: bs-kevin-test
---
apiVersion: cluster.x-k8s.io/v1beta1
kind: MachinePool
metadata:
  name: {{.ClusterName}}-mp-0
  namespace: {{.Namespace}}
spec:
  .ClusterName: {{.ClusterName}}
  replicas: {{.MachinePool.Replicas}}
  template:
    spec:
      bootstrap:
        configRef:
          apiVersion: bootstrap.cluster.x-k8s.io/v1beta1
          kind: KubeadmConfig
          name: {{.ClusterName}}-mp-0
      .ClusterName: {{.ClusterName}}
      infrastructureRef:
        apiVersion: infrastructure.cluster.x-k8s.io/v1beta1
        kind: AWSMachinePool
        name: {{.ClusterName}}-mp-0
      version: {{.MachinePool.Version}}
---
apiVersion: infrastructure.cluster.x-k8s.io/v1beta1
kind: AWSMachinePool
metadata:
  name: {{.ClusterName}}-mp-0
  namespace: {{.Namespace}}
spec:
  availabilityZones:
  - us-east-1a, us-east-1d
  awsLaunchTemplate:
    instanceType: t2.medium
    sshKeyName: bs-kevin-test
maxSize: {{.AWSMachinePool.MaxSize}}
minSize: {{.AWSMachinePool.MinSize}}
---
apiVersion: bootstrap.cluster.x-k8s.io/v1beta1
kind: KubeadmConfig
metadata:
  name: {{.ClusterName}}-mp-0
  namespace: {{.Namespace}}
spec:
  joinConfiguration:
    nodeRegistration:
      kubeletExtraArgs:
        cloud-provider: aws
