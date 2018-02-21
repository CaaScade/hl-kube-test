package main

import (
	"os"

	"github.com/koki/fabric-dev/cli/cmd"
)

func main() {
	if err := cmd.RootCmd.Execute(); err != nil {
		os.Exit(1)
	}
}
