package CameraAPI

import "encoding/xml"

type DeviceDescriptionXML struct {
	XMLName     xml.Name `xml:"root"`
	Text        string   `xml:",chardata"`
	Xmlns       string   `xml:"xmlns,attr"`
	Dlna        string   `xml:"dlna,attr"`
	Av          string   `xml:"av,attr"`
	SpecVersion struct {
		Text  string `xml:",chardata"`
		Major string `xml:"major"`
		Minor string `xml:"minor"`
	} `xml:"specVersion"`
	Device struct {
		Text             string `xml:",chardata"`
		DeviceType       string `xml:"deviceType"`
		FriendlyName     string `xml:"friendlyName"`
		Manufacturer     string `xml:"manufacturer"`
		ManufacturerURL  string `xml:"manufacturerURL"`
		ModelDescription string `xml:"modelDescription"`
		ModelName        string `xml:"modelName"`
		ModelURL         string `xml:"modelURL"`
		UDN              string `xml:"UDN"`
		ServiceList      struct {
			Text    string `xml:",chardata"`
			Service []struct {
				Text        string `xml:",chardata"`
				ServiceType string `xml:"serviceType"`
				ServiceId   string `xml:"serviceId"`
				SCPDURL     string `xml:"SCPDURL"`
				ControlURL  string `xml:"controlURL"`
				EventSubURL string `xml:"eventSubURL"`
			} `xml:"service"`
		} `xml:"serviceList"`
		XScalarWebAPIDeviceInfo struct {
			Text                     string `xml:",chardata"`
			Av                       string `xml:"av,attr"`
			XScalarWebAPIVersion     string `xml:"X_ScalarWebAPI_Version"`
			XScalarWebAPIServiceList struct {
				Text                 string `xml:",chardata"`
				XScalarWebAPIService []struct {
					Text                       string `xml:",chardata"`
					XScalarWebAPIServiceType   string `xml:"X_ScalarWebAPI_ServiceType"`
					XScalarWebAPIActionListURL string `xml:"X_ScalarWebAPI_ActionList_URL"`
					XScalarWebAPIAccessType    string `xml:"X_ScalarWebAPI_AccessType"`
				} `xml:"X_ScalarWebAPI_Service"`
			} `xml:"X_ScalarWebAPI_ServiceList"`
			XScalarWebAPIImagingDevice struct {
				Text                         string `xml:",chardata"`
				XScalarWebAPILiveViewURL     string `xml:"X_ScalarWebAPI_LiveView_URL"`
				XScalarWebAPIDefaultFunction string `xml:"X_ScalarWebAPI_DefaultFunction"`
			} `xml:"X_ScalarWebAPI_ImagingDevice"`
		} `xml:"X_ScalarWebAPI_DeviceInfo"`
	} `xml:"device"`
}

type DeviceDescription struct {
	GuideUrl         string
	SystemUrl        string
	AccessControlUrl string
	CameraUrl        string
}

type RPCRequest struct {
	Method  string   `json:"method,omitempty"`
	Params  []string `json:"params"`
	Id      int      `json:"id,omitempty"`
	Version string   `json:"version,omitempty"`
}

type RPCResponse struct {
	Id     int           `json:"id,omitempty"`
	Result []interface{} `json:"result,omitempty"`
	Error  []interface{} `json:"error,omitempty"`
}
