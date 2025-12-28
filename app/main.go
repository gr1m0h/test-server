package main

import (
	"database/sql"
	"fmt"
	"log"
	"time"

	"github.com/labstack/echo/v4"
	_ "github.com/lib/pq"
	"github.com/spf13/viper"

	_articleHttpDelivery "github.com/grimoh/test-server/article/delivery/http"
	_articleHTTPDeliveryMiddleware "github.com/grimoh/test-server/article/delivery/http/middleware"
	_articleRepo "github.com/grimoh/test-server/article/repository/postgres"
	_articleUsecase "github.com/grimoh/test-server/article/usecase"
	_authorRepo "github.com/grimoh/test-server/author/repository/postgres"
)

func init() {
	viper.SetConfigFile(`config.json`)
	if err := viper.ReadInConfig(); err != nil {
		panic(err)
	}

	if viper.GetBool(`debug`) {
		log.Println("Service RUN on DEBUG mode")
	}
}

func main() {
	dbHost := viper.GetString(`database.host`)
	dbPort := viper.GetString(`database.port`)
	dbUser := viper.GetString(`database.user`)
	dbPass := viper.GetString(`database.pass`)
	dbName := viper.GetString(`database.name`)

	dsn := fmt.Sprintf("host=%s port=%s user=%s password=%s dbname=%s sslmode=disable",
		dbHost, dbPort, dbUser, dbPass, dbName)

	dbConn, err := sql.Open(`postgres`, dsn)
	if err != nil {
		log.Fatal(err)
	}

	if err = dbConn.Ping(); err != nil {
		log.Fatal(err)
	}
	defer func() {
		if err := dbConn.Close(); err != nil {
			log.Fatal(err)
		}
	}()

	e := echo.New()
	middle := _articleHTTPDeliveryMiddleware.InitMiddleware()
	e.Use(middle.CORS)

	authorRepo := _authorRepo.NewPostgresAuthorRepository(dbConn)
	ar := _articleRepo.NewPostgresArticleRepository(dbConn)

	timeoutContext := time.Duration(viper.GetInt("context.timeout")) * time.Second
	au := _articleUsecase.NewArticleUsecase(ar, authorRepo, timeoutContext)
	_articleHttpDelivery.NewArticleHandler(e, au)

	log.Fatal(e.Start(viper.GetString("server.address")))
}
