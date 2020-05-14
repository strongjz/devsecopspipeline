package main

import (
	"fmt"
	"github.com/gin-gonic/gin"
	app "github.com/strongjz/go_example_app/app"
)

func main() {

	go func() {
		routerAdmin := gin.Default()

		routerAdmin.GET("/admin", func(c *gin.Context) {
			c.JSON(200, gin.H{
				"message": "Admin Sections",
			})
		})
		routerAdmin.Run(":8090")
	}()

	app := app.New()

	fmt.Println("Starting App")

	app.Engine()

	app.Start()

}
