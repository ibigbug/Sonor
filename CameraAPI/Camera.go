package main

// #include <stdlib.h>
// #include "types.h"
import "C"

import (
	"bufio"
	"bytes"
	"encoding/json"
	"encoding/xml"
	"fmt"
	"io"
	"io/ioutil"
	"log"
	"net"
	"net/http"
	"strings"
	"time"
	"unsafe"
)

const (
	BroadcastAddr = "239.255.255.250:1900"

	RequestLine = "M-SEARCH * HTTP/1.1"
	HOST        = BroadcastAddr
	MAN         = `"ssdp:discover"`
	MX          = "5"
	ST          = "urn:schemas-sony-com:service:ScalarWebAPI:1"
	USER_AGENT  = "Gomobile"
)

//export CameraDiscovery
func CameraDiscovery() (cameraAddr *C.char) {
	var request = []string{
		RequestLine,
		fmt.Sprintf("HOST: %s", HOST),
		fmt.Sprintf("MAN: %s", MAN),
		fmt.Sprintf("MX: %s", MX),
		fmt.Sprintf("ST: %s", ST),
		fmt.Sprintf("USER-AGENT: %s", USER_AGENT),
		"\r\n",
	}

	localAddr, err := net.ResolveUDPAddr("udp", "0.0.0.0:10240")
	if err != nil {
		return
	}
	localConn, err := net.ListenUDP("udp", localAddr)
	if err != nil {
		return
	}
	defer localConn.Close()

	reqString := strings.Join(request, "\r\n")
	serverAddr, err := net.ResolveUDPAddr("udp", BroadcastAddr)
	if err != nil {
		return
	}

	localConn.WriteTo([]byte(reqString), serverAddr)

	localConn.SetReadDeadline(time.Now().Add(5 * time.Second))

	buf := make([]byte, 1024)

	var addressList = []string{}
	for {
		n, addr, err := localConn.ReadFromUDP(buf)
		if nerr, ok := err.(net.Error); ok && nerr.Timeout() {
			break
		}
		if err != nil {
			return
		}

		serverAddr, err := parseServerAddr(bytes.NewReader(buf[:n]), addr)
		addressList = append(addressList, serverAddr)
	}

	if len(addressList) == 0 {
		return
	}

	cameraAddr = C.CString(addressList[0])
	defer C.free(unsafe.Pointer(cameraAddr))

	return
}

//export DeviceDescription
func DeviceDescription(cameraAddr *C.char) (ptr *C.struct_DeviceDescription_t) {
	resp, err := http.Get(C.GoString(cameraAddr))
	if err != nil {
		return
	}
	defer resp.Body.Close()

	b, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		return
	}

	var deviceDescription DeviceDescriptionXML
	err = xml.Unmarshal(b, &deviceDescription)
	if err != nil {
		return
	}

	var rv TDeviceDescription
	for _, s := range deviceDescription.Device.XScalarWebAPIDeviceInfo.XScalarWebAPIServiceList.XScalarWebAPIService {
		if s.XScalarWebAPIServiceType == "guide" {
			rv.GuideUrl = C.CString(s.XScalarWebAPIActionListURL + "/guide")
			defer C.free(unsafe.Pointer(rv.GuideUrl))
		}
		if s.XScalarWebAPIServiceType == "system" {
			rv.SystemUrl = C.CString(s.XScalarWebAPIActionListURL + "/system")
			defer C.free(unsafe.Pointer(rv.SystemUrl))
		}
		if s.XScalarWebAPIServiceType == "accessControl" {
			rv.SystemUrl = C.CString(s.XScalarWebAPIActionListURL + "/accessControl")
			defer C.free(unsafe.Pointer(rv.SystemUrl))
		}
		if s.XScalarWebAPIServiceType == "camera" {
			rv.CameraUrl = C.CString(s.XScalarWebAPIActionListURL + "/camera")
			defer C.free(unsafe.Pointer(rv.CameraUrl))
		}
	}

	ptr = (*C.struct_DeviceDescription_t)(C.malloc(C.size_t(unsafe.Sizeof(C.struct_DeviceDescription_t{}))))
	ptr.GuideUrl = rv.GuideUrl
	ptr.CameraUrl = rv.CameraUrl
	defer C.free(unsafe.Pointer(ptr))

	return
}

//export GetAvailableApiList
func GetAvailableApiList(apiAddr *C.char) (rv *C.struct_SliceHeader_t) {
	bodyJson := RPCRequest{
		Method:  "getAvailableApiList",
		Params:  []string{},
		Id:      1,
		Version: "1.0",
	}
	body, err := json.Marshal(bodyJson)
	if err != nil {
		return
	}

	println("-> ", C.GoString(apiAddr), string(string(body)))

	res, err := http.Post(C.GoString(apiAddr), "application/json", bytes.NewReader(body))
	if err != nil {
		log.Println(err)
		return
	}
	defer res.Body.Close()

	bodyBytes, err := ioutil.ReadAll(res.Body)
	if err != nil {
		log.Println(err)
		return
	}

	println("<- ", string(bodyBytes))

	var rpcRes RPCResponse
	if err := json.Unmarshal(bodyBytes, &rpcRes); err != nil {
		log.Println(err)
		return
	}

	rv = (*C.struct_SliceHeader_t)(C.malloc(C.size_t(unsafe.Sizeof(C.struct_SliceHeader_t{}))))
	defer C.free(unsafe.Pointer(rv))

	if len(rpcRes.Result) > 0 {
		if rList, ok := rpcRes.Result[0].([]interface{}); ok {
			var data []*C.char
			for _, s := range rList {
				data = append(data, C.CString(s.(string)))
			}
			rv.Data = (**C.char)(&data[0])
			rv.Len = C.int(len(rList))
		}
	}

	if len(rpcRes.Error) == 2 {
		if errStr, ok := rpcRes.Error[1].(string); ok {
			println("api error: " + errStr)
		}
	}
	return
}

func parseServerAddr(responseReader io.Reader, responseAddr *net.UDPAddr) (addr string, err error) {
	response, err := http.ReadResponse(bufio.NewReader(responseReader), nil)
	if err != nil {
		return
	}
	defer response.Body.Close()

	headers := response.Header
	return headers.Get("location"), nil
}

func main() {}
