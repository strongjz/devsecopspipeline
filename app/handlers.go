package devsecopspipeline

import (
	"database/sql"
	"fmt"
	"github.com/gin-gonic/gin"
	_ "github.com/lib/pq"
	"log"
	"os"
)

func adminHandler(c *gin.Context) {
	c.JSON(200, gin.H{
		"message": "Admin Sections",
	})
}

func rootHandler(c *gin.Context) {
	c.JSON(200, gin.H{
		"message": "Default Page",
	})
}

func pingHandler(c *gin.Context){

	version := os.Getenv("VERSION")

	message := fmt.Sprintf("Pong Version %v", version)

	c.JSON(200, gin.H{
		"message": message,
	})
}

func secretHandler(c *gin.Context) {
	c.JSON(200, gin.H{
		"message": "You should not see this",
	})
}

func dataHandler(c *gin.Context) {
	db := CreateCon()

	err := db.Ping()
	if err != nil {
		c.JSON(500, gin.H{
			"message": "DB is not connected",
		})

	}else{
		c.JSON(200, gin.H{
			"message": "Database Connected",
		})
	}
}
/*Create sql database connection*/
func CreateCon() *sql.DB {
	user := os.Getenv("DB_USER")
	pass := os.Getenv("DB_PASSWORD")
	host := os.Getenv("DB_HOST")
	port := os.Getenv("DB_PORT")

	connStr := fmt.Sprintf("postgres://%v:%v@%v:%v?sslmode=disable",user,pass,host,port)

	fmt.Printf("Database Connection String: %v \n",connStr)

	db, err := sql.Open("postgres", connStr)

	if err != nil {
		log.Fatalf("ERROR: %v", err)
	}

	return db
}
func hostHandler(c *gin.Context){
	node := os.Getenv("MY_NODE_NAME")
	podIP := os.Getenv("MY_POD_IP")

	information := fmt.Sprintf("NODE: %v, POD IP:%v",node, podIP)

	c.JSON(200, gin.H{
		"message": "" + information ,
	})
}

func externalHandler(c *gin.Context){

	c.JSON(200, gin.H{
		"message": "External host test message" ,
	})

}
