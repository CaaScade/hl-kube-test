package artifacts

import (
	"os"
	"os/exec"
)

// ../bin/cryptogen generate --config=./crypto-config.yaml

func (c *Context) Cryptogen() error {
	cmd := exec.Command("echo", "--config=./crypto-config.yaml")
	cmd.Stdout = os.Stdout
	err := cmd.Start()
	if err != nil {
		return err
	}
	return cmd.Wait()
}
