function initializeHls(videoElement, streamUrl) {
    if (Hls.isSupported()) {
      var hls = new Hls();
      hls.loadSource(streamUrl);
      hls.attachMedia(videoElement);
      hls.on(Hls.Events.MANIFEST_PARSED, function () {
        videoElement.play();
      });
    } else if (videoElement.canPlayType('application/vnd.apple.mpegurl')) {
      videoElement.src = streamUrl;
      videoElement.addEventListener('loadedmetadata', function () {
        videoElement.play();
      });
    }
  }