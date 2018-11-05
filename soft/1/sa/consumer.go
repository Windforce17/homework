package main

import (
	"./cmqKit"
	"encoding/json"
	"fmt"
	"log"
)

func main() {
	var qurl = "cmq-queue-bj.api.qcloud.com/v2/index.php?"
	var qcloudId = "AKID3xe9RWZ1SffRzKwM3XnqfGeomX4OrP5Y"
	var qcloudKey = "MXUDj15wa1EF2cz95oKchYCdrsfFclgO"
	cmqKit.CreateCmqKit(qurl, qcloudId, qcloudKey)
	msg := cmqKit.CmqConsumerMessage{
		"sa-homeWork",
		"0",
	}


	m := make(map[string]interface{})
	res := cmqKit.ConsumerMsg(&msg)
	json.Unmarshal(res, &m)
	log.Println(m)
	if m["receiptHandle"]==nil{
		log.Fatalln(string(res))
	}
	msgdel := cmqKit.CmqDelMsg{
		"sa-homeWork",
		m["receiptHandle"].(string),
	}
	fmt.Println(string(cmqKit.DelMsg(&msgdel)))
}
