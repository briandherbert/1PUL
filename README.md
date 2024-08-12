# 1PUL (1st Place You Look)


## Making it work
You'll need the following:

### 1. Google service account that can read/write Google Sheets and Google Cloud Storage

### 2. A public Google Cloud Storage bucket

### 3. Google Sheet database
- Duplicate this sheet: https://docs.google.com/spreadsheets/d/1oFp17Q-FQFjlynz2aD6qXtYpoHqOxitGh4ghTYGjurQ/edit?usp=sharing
- Delete the contents of the "inventory" tab
- Put your own values in the "locations" tab
- **GIVE YOUR SERVICE ACCT EMAIL WRITE ACCESS VIA SHARING**

### 4. A .env file at the project root with these values:

GEMINI_KEY = "YOURS"


GCS_PREFIX = "something like https://storage.googleapis.com/organizer_photos/"


GSHEET_ID = "your inventory sheet id like 1oFp17Q-FQFjlynz2aD6qXtYpoHqOxi4ghTYGjurQ"


GROQ_WHIPSER = "optional, for transcribing. get an api key from https://console.groq.com/keys"


SERVICE_ACCT_CREDS = "^^ that google service account converted to base64 string, in terminal do 'base64 -i [KEY_FILE]'"


### 5. Run it!
Launch 1PUL on Chrome. 

- Click the 'Monitor' button.
- Once you see the video feed, click it to change state from Paused to Monitoring, indicated at bottom left.
- Choose a location at the top. This reads from the google sheet.

If you want to run it on other devices on your network, `flutter build web` and serve the folder. One option:
1. flutter build web
2. npm install -g http-server
3. cd build/web
4. http-server -a 0.0.0.0 -p 8080
5. brew install ngrok
5. ngrok http 8080 (localtunnel is another option)
6. on the other devices, go to the tunnel url in a browser

### Very optional HSLSS security cam stream

Get a security cam on the same network as the 1PUL device.
If you have an RTSC stream (Wyze Cam3 firmware downgrade demo_wcv3_4.36.9.139), convert it to HLSLL with
https://github.com/deepch/RTSPtoHLSLL
and edit **config.json** to something like:
```
{
  "server": {
    "http_port": ":8083"
  },
  "streams": {
    "demo1": {
      "on_demand": false,
      "url": "rtsp://foo:bar@192.168.1.99/live",
      "fps_mode": "probe",
      "fps_probe_time": 2,
      "fps": 25   
    }
  }
}
```

The HLS stream url will be something like http://localhost:8083/play/hls/demo1/index.m3u8
You can find it by inspecting network on localhost:8083

While this works, and latency isn't an issue for passive security cams, it's killer on the single web thread. 

## Performance and randomness
Full reload is often required to reflect changes. 

Try tweaking stuff in globals.dart, both for BL performance and the whimsey of prompt engineering.

Camera frames are a gnarly business, obtaining and converting them on Flutter web's single thread. There's a balancing act of what quality to request and how often to request them. Sending a frame to Gemini is a double-whammy, because we have to do a computationally expensive conversion to jpeg, and a time-expensive API call. And if we end up with an inventory item, we also need to send it to GCS.