package cmd

import (
	"fmt"

	"github.com/spf13/cobra"
)

var RootCmd = &cobra.Command{
	Use:   "fabric-dev",
	Short: "One-step deployment of Hyperledger Fabric on K8s",
	Long:  `One-step deployment of Hyperledger Fabric on K8s`,
	RunE: func(c *cobra.Command, args []string) error {
		fmt.Println("Hello, world!")
		return nil
	},
	SilenceUsage: true,
}
