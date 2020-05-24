package main

import (
	"fmt"
	"github.com/strongjz/devsecopspipeline/devsecopspipeline"
)

func main() {

	app := devsecopspipeline.New()

	fmt.Println("Starting App")

	app.Engine()

	app.Start()

}
