package main

import (
	"fmt"
	"io/ioutil"
	"os"
	"os/exec"
	"text/template"
)

type KubeadmControlPlane struct {
	Replicas int
	Version  string
}

type AWSMachineTemplate struct {
	InstanceType string
	SshKeyName   string
}

type AWSMachinePool struct {
	InstanceType string
	SshKeyName   string
	MaxSize      int
	MinSize      int
}

type MachinePool struct {
	Replicas int
	Version  string
}

type AwsEksParams struct {
	Namespace   string
	ClusterName string
	KubeadmControlPlane
	AWSMachineTemplate
	AWSMachinePool
	MachinePool
}

//Convertion template to real yaml file
func RenderTemplateToFile(awsEksParams AwsEksParams, fileName string) string {
	// Read from this file
	tplFileName := "./cluster-machinePoll.tpl"
	tplEks, err := template.ParseFiles(tplFileName)
	if err != nil {
		fmt.Println("Error: ", err)
		os.Exit(1)
	}
	// Output to this file
	outFileName, err := os.Create(fileName)
	if err != nil {
		fmt.Println("Create file: ", err)
		os.Exit(1)
	}

	//K8sTemplate := ioutil.ReadFile(fileName)
	// Render tpl file
	err = tplEks.Execute(outFileName, awsEksParams)
	if err != nil {
		panic(err)
	}
	return fileName
}

// Create AWS EKS by command kubectl apply -f ...
func (awsEks AwsEksParams) CreateAwsEks(fileName string) {
	manifests := RenderTemplateToFile(awsEks, fileName)
	cmd := exec.Command("kubectl", "apply", "-f", manifests, "--dry-run")
	fmt.Printf("cmd content:%s", cmd)
	stdout, err := cmd.StdoutPipe()
	if err != nil {
		fmt.Println("err: ", err)
		os.Exit(1)
	}

	if err := cmd.Start(); err != nil {
		fmt.Println("Error: ", err)
		os.Exit(1)
	}
	data, err := ioutil.ReadAll(stdout)
	if err != nil {
		fmt.Println("Err: ", err)
		os.Exit(1)
	}
	cmd.Wait()
	fmt.Printf("\nOutput: %s\n", data)

}
