package cmd

import (
	"fmt"

	"github.com/spf13/cobra"

	"github.com/koki/fabric-dev/cli/fabric/artifacts"
)

/*

load config file:

* minikube install config
  * use minikube or not
  * download minikube or not
  * install virtualbox or not
* kubeconfig
* download kubectl

*/

var RootCmd = &cobra.Command{
	Use:   "fabric-dev",
	Short: "One-step deployment of Hyperledger Fabric on K8s",
	Long:  `One-step deployment of Hyperledger Fabric on K8s`,
	RunE: func(c *cobra.Command, args []string) error {
		fmt.Println("Hello, world!")
		ctx := artifacts.Context{}
		ctx.Cryptogen()

		return nil
	},
	SilenceUsage: true,
}
