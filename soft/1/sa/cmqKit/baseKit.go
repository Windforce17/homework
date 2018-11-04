package cmqKit

import (
	"crypto/hmac"
	"crypto/sha1"
	"encoding/base64"
	"encoding/json"
	"errors"
	"fmt"
	"io/ioutil"
	"log"
	"math/rand"
	"net/http"
	"net/url"
	"sort"
	"strconv"
	"time"
)

var CmqKit *baseInf

type baseInf struct {
	Qurl      string
	QcloudId  string
	QcloudKey string
	PublicParam
}

type CmqSendMessage struct {
	QueueName string
	MsgBody   string
}

type CmqConsumerMessage struct {
	QueueName          string
	PollingWaitSeconds string
}

type CmqDelMsg struct {
	QueueName     string
	ReceiptHandle string
}
type PublicParam struct {
	Method          string
	Action          string
	Region          string
	Timestamp       int64
	Nonce           uint32
	SecretId        string
	SignatureMethod string
}

func (kit *baseInf) GetPublicParam() map[string]string {
	params := make(map[string]string)
	params["Action"] = kit.PublicParam.Action
	params["Nonce"] = strconv.FormatUint(uint64(kit.PublicParam.Nonce), 10)
	params["Region"] = kit.PublicParam.Region
	params["SecretId"] = kit.PublicParam.SecretId
	params["SignatureMethod"] = kit.PublicParam.SignatureMethod
	params["Timestamp"] = strconv.FormatInt(kit.PublicParam.Timestamp, 10)
	return params
}
func (kit *baseInf) AddParam(p map[string]string) string {
	var pSord []string
	var sendString string
	for x, _ := range p {
		pSord = append(pSord, x)
	}

	sort.Strings(pSord)
	for _, k := range pSord {
		sendString += fmt.Sprintf("%s=%s&", k, p[k])
	}

	return sendString
}

func (kit *baseInf) GetSig(data string) (string) {

	mac := hmac.New(sha1.New, []byte(kit.QcloudKey))
	mac.Write([]byte(data))
	//fmt.Print(data)
	sig := base64.StdEncoding.EncodeToString(mac.Sum(nil))
	return sig
}

func SendMsg(msg *CmqSendMessage) error {
	if CmqKit == nil {
		return errors.New("you need CreateKit first")

	}

	CmqKit.Action = "SendMessage"
	setTimeStamp()
	param := CmqKit.GetPublicParam()
	param["queueName"] = msg.QueueName
	param["msgBody"] = msg.MsgBody
	rsp:=make(map[string]interface{})
	e:=json.Unmarshal(getRequest(param),&rsp)
	if e !=nil{
		return errors.New("send Msg fail "+e.Error())
	}
	if _,ok:=rsp["code"];!ok||rsp["code"].(float64)!=0{
		return errors.New("send Msg fail "+e.Error())
	}
	return nil


}
func CreateCmqKit(qurl, qcloudId, qcloudkey string) *baseInf {
	if CmqKit == nil {
		CmqKit = new(baseInf)
		*CmqKit = baseInf{
			Qurl:      qurl,
			QcloudId:  qcloudId,
			QcloudKey: qcloudkey,
		}
		CmqKit.Region = "bj"
		CmqKit.Method = "GET"
		CmqKit.SecretId = CmqKit.QcloudId
		CmqKit.SignatureMethod = "HmacSHA1"
	}
	return CmqKit
}

func getRequest(param map[string]string) []byte {
	sendString := CmqKit.PublicParam.Method + CmqKit.Qurl
	sendString += CmqKit.AddParam(param)
	sendString = sendString[:len(sendString)-1]

	sig := CmqKit.GetSig(sendString)
	param["Signature"] = sig
	u := CmqKit.Qurl + CmqKit.AddParam(param)
	u = u[:len(u)-1]
	u1, _ := url.Parse(u)
	u = u1.String()
	resp, err := http.Get("https://" + u)

	if err != nil {
		log.Fatal(err)
	}
	defer resp.Body.Close()
	body, err := ioutil.ReadAll(resp.Body)
	return body
}

func GetCmqKit() *baseInf {
	return CmqKit
}
func ConsumerMsg(msg *CmqConsumerMessage) []byte {
	if CmqKit == nil {
		log.Fatalln("you need create kit first!")
	}
	CmqKit.Action = "ReceiveMessage"
	setTimeStamp()

	param := CmqKit.GetPublicParam()
	param["queueName"] = msg.QueueName
	param["pollingWaitSeconds"] = msg.PollingWaitSeconds

	return getRequest(param)

}
func setTimeStamp() {
	rand.Seed(time.Now().UnixNano())
	CmqKit.Nonce = rand.Uint32()
	CmqKit.Timestamp = time.Now().Unix()
}
func DelMsg(msg *CmqDelMsg) []byte {
	if CmqKit == nil {
		log.Fatalln("you need create kit first!")
	}
	CmqKit.Action = "DeleteMessage"
	setTimeStamp()
	param := CmqKit.GetPublicParam()
	param["queueName"] = msg.QueueName
	param["receiptHandle"] = msg.ReceiptHandle
	return getRequest(param)

}
