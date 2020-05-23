package main

import (
	"fmt"
	app "github.com/strongjz/devsecops-container-pipeline/app"
)

func main() {


	app := app.New()

	fmt.Println("Starting App")

	app.Engine()

	app.Start()

}
