const getWebRTCStats = async (pc: RTCPeerConnection) => {
  const stats = await pc.getStats();

  let result = {
    codecMimeType: '',
    sdpFmtpLine: '',
    jitter: 0,
    packetsLost: 0,
    rttMedia: 0,
    rttIce: 0,
    bitrateKbps: 0,
    frameRate: 0,
  };

  let codecs: Record<string, any> = {};

  stats.forEach(report => {
    // 1. Lưu lại codec theo id
    if (report.type === 'codec' && report.mimeType?.startsWith('video')) {
      codecs[report.id] = report;
    }

    // 2. Lấy dữ liệu từ remote-inbound-rtp
    if (report.type === 'remote-inbound-rtp' && report.kind === 'video') {
      result.jitter = report.jitter ?? 0;
      result.packetsLost = report.packetsLost ?? 0;
      result.rttMedia = report.roundTripTime ?? 0;

      const codec = codecs[report.codecId];
      if (codec) {
        result.codecMimeType = codec.mimeType;
        result.sdpFmtpLine = codec.sdpFmtpLine;
      }
    }

    // 3. Lấy dữ liệu ICE RTT
    if (report.type === 'candidate-pair' && report.state === 'succeeded') {
      result.rttIce = report.currentRoundTripTime ?? 0;
    }

    // 4. Tính bitrate từ inbound-rtp
    if (report.type === 'inbound-rtp' && report.kind === 'video') {
      // Optional: tính toán bitrate thủ công bằng cách so sánh bytesReceived giữa 2 lần gọi
      result.bitrateKbps = ((report.bytesReceived ?? 0) * 8) / 1000;
      result.frameRate = report.framesPerSecond ?? 0;
    }
  });

  console.log('📊 WebRTC Stats:', result);
  return result;
};
