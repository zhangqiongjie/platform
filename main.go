package main

func main() {
	GetAwsEksParams()
}

func GetAwsEksParams() AwsEksParams {
	//Define real values that from web UI for EKS
	myaws := AwsEksParams{
		Namespace:   "mycluster",
		ClusterName: "capa-test",
		KubeadmControlPlane: KubeadmControlPlane{
			Replicas: 2,
			Version:  "v1.21.1",
		},
		AWSMachineTemplate: AWSMachineTemplate{
			InstanceType: "t2.medium",
			SshKeyName:   "bs-kevin-test",
		},
		AWSMachinePool: AWSMachinePool{
			InstanceType: "t2.medium",
			SshKeyName:   "bs-kevin-test",
			MaxSize:      3,
			MinSize:      1,
		},
		MachinePool: MachinePool{
			Replicas: 2,
			Version:  "v1.21.1",
		},
	}
	myaws.CreateAwsEks("cluster-machinePoll.yaml")
	return myaws
}
