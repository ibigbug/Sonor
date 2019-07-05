#ifndef _CameraAPI_types
#define _CameraAPI_types

struct DeviceDescription_t
{
	char *GuideUrl;
	char *SystemUrl;
	char *AccessControlUrl;
	char *CameraUrl;
};

struct SliceHeader_t
{
	int Len;
	char **Data;
};

#endif