package main

import (
	"fmt"
	app "github.com/strongjz/go_example_app/app"
)

func main() {

	app := app.New()

	fmt.Println("Starting App")

	app.Engine()

	app.Start()

}
