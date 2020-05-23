package devsecopspipeline

import (
	"fmt"
	"github.com/gin-gonic/gin"
)

type App struct {
	router            *gin.Engine
}

func New() *App {
	return &App{}
}

func (a *App) Engine() *gin.Engine {

	fmt.Println("Starting App Engine")
	// set server mode
	gin.SetMode(gin.DebugMode)

	r := gin.New()

	// Global middleware
	r.Use(gin.Logger())
	r.Use(gin.Recovery())

	r.GET("/", rootHandler)
	r.GET("/ping", pingHandler)
	r.GET("/data", dataHandler)
	r.GET("/secret", secretHandler)
	r.GET("/host", hostHandler)
	r.GET("/external", externalHandler)

	a.router = r

	return a.router
}

func (a *App) Start() {

	a.router.Run()
}