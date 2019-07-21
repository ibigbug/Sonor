package CameraAPI

import "C"

import (
	"bufio"
	"bytes"
	"encoding/xml"
	"fmt"
	"io"
	"io/ioutil"
	"net"
	"net/http"
	"strings"
	"time"
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

func CameraDiscovery() (cameraAddr string) {
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

	cameraAddr = addressList[0]

	return
}

func GetDeviceDescription(cameraAddr string) (rv *DeviceDescription) {
	resp, err := http.Get(cameraAddr)
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

	rv = new(DeviceDescription)

	for _, s := range deviceDescription.Device.XScalarWebAPIDeviceInfo.XScalarWebAPIServiceList.XScalarWebAPIService {
		if s.XScalarWebAPIServiceType == "guide" {
			rv.GuideUrl = s.XScalarWebAPIActionListURL + "/guide"
		}
		if s.XScalarWebAPIServiceType == "system" {
			rv.SystemUrl = s.XScalarWebAPIActionListURL + "/system"
		}
		if s.XScalarWebAPIServiceType == "accessControl" {
			rv.AccessControlUrl = s.XScalarWebAPIActionListURL + "/accessControl"
		}
		if s.XScalarWebAPIServiceType == "camera" {
			rv.CameraUrl = s.XScalarWebAPIActionListURL + "/camera"
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
