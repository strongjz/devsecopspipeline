package main

import (
	"fmt"
	app "github.com/strongjz/devsecopspipeline/src"
)

func main() {

	app := app.New()

	fmt.Println("Starting App")

	app.Engine()

	app.Start()

}
