package main

import (
	"encoding/json"
	"fmt"
	"github.com/gin-gonic/gin"
	"log"
	"net/http"
	"sa3-1/cmqKit"
)

var qurl = "cmq-queue-bj.api.qcloud.com/v2/index.php?"
var qcloudId = "AKID3xe9RWZ1SffRzKwM3XnqfGeomX4OrP5Y"
var qcloudKey = "MXUDj15wa1EF2cz95oKchYCdrsfFclgO"

type Msg struct {
	Message string `json:"msg"`
} 
func main() {
	cmqKit.CreateCmqKit(qurl, qcloudId, qcloudKey)
	route:=gin.Default()
	route.POST("/sendMsg",sendmsg)
	route.GET("/recvMsg",recvmsg)
	route.StaticFile("/",`send.html`)
	route.StaticFile("/getmsg",`recv.html`)

	route.Run(":8080")




}

func ping(c *gin.Context){
	c.JSON(200, gin.H{
		"message": "pong",
	})
}

func sendmsg(c *gin.Context){
	var m Msg
	if err:=c.ShouldBindJSON(&m);err!=nil{

		c.JSON(http.StatusBadRequest,gin.H{"error":err.Error()})
		log.Println(err.Error())
		return
	}
	msg := cmqKit.CmqSendMessage{
		QueueName: "sa-homeWork",
		MsgBody:   m.Message,
	}

	if e:=cmqKit.SendMsg(&msg);e!=nil{
		c.JSON(http.StatusBadRequest,gin.H{"error":e.Error()})
		log.Println(e.Error())
		return
	}
	c.JSON(http.StatusOK,gin.H{
		"msg":m.Message,
	})
}

func recvmsg(c *gin.Context){
	msg := cmqKit.CmqConsumerMessage{
		"sa-homeWork",
		"0",
	}


	m := make(map[string]interface{})
	res := cmqKit.ConsumerMsg(&msg)
	json.Unmarshal(res, &m)
	if m["receiptHandle"]==nil{
		c.String(http.StatusInternalServerError,fmt.Sprintln(m))
		return
	}
	msgdel := cmqKit.CmqDelMsg{
		"sa-homeWork",
		m["receiptHandle"].(string),
	}
	cmqKit.DelMsg(&msgdel)
	c.JSON(http.StatusOK,gin.H{"msg":m["msgBody"]})
}