import { useState } from 'react';
import { FaFileUpload } from 'react-icons/fa';
import { FiSettings } from 'react-icons/fi';
import { AiOutlineCloudDownload } from 'react-icons/ai';
import './VideoConverter.css';

const formats = ['mp4', 'avi', 'mpeg', 'mov', 'flv', '3gp', 'webm', 'mkv', 'Apple', 'Android'];

export default function VideoConverter() {
  const [selectedFormat, setSelectedFormat] = useState('mp4');
  const [resolution, setResolution] = useState('Same as source');
  const [showSettings, setShowSettings] = useState(false);
  const [videoCodec, setVideoCodec] = useState('H.264 / AVC');
  const [audioCodec, setAudioCodec] = useState('AAC (Advanced Audio Coding)');
  const [noAudio, setNoAudio] = useState(false);
  const [outputSize, setOutputSize] = useState(700);

  return (
    <div className="vc-container">
      {/* Step 1 */}
      <div className="vc-section">
        <h2 className="vc-title">1. Open file</h2>
        <button className="vc-button vc-upload">
          <FaFileUpload /> Open File
        </button>
        <div className="vc-cloud-links">
          <span>Google Drive</span>
          <span>Dropbox</span>
          <span>URL</span>
        </div>
      </div>

      {/* Step 2 */}
      <div className="vc-section">
        <h2 className="vc-title">2. Select Format</h2>
        <div className="vc-format-list">
          {formats.map((f) => (
            <button
              key={f}
              className={`vc-format ${selectedFormat === f ? 'selected' : ''}`}
              onClick={() => setSelectedFormat(f)}
            >
              {f}
            </button>
          ))}
        </div>

        <div className="vc-row">
          <label>Resolution:</label>
          <select value={resolution} onChange={(e) => setResolution(e.target.value)}>
            <option>Same as source</option>
            <option>1080p</option>
            <option>720p</option>
            <option>480p</option>
          </select>
          <button className="vc-settings-button" onClick={() => setShowSettings(!showSettings)}>
            <FiSettings /> Settings
          </button>
        </div>

        {showSettings && (
          <div className="vc-settings-panel">
            <div className="vc-row">
              <label>Video code:</label>
              <select value={videoCodec} onChange={(e) => setVideoCodec(e.target.value)}>
                <option>H.264 / AVC</option>
                <option>VP8</option>
                <option>VP9</option>
              </select>
            </div>
            <div className="vc-row">
              <label>Audio code:</label>
              <select
                value={audioCodec}
                onChange={(e) => setAudioCodec(e.target.value)}
                disabled={noAudio}
              >
                <option>AAC (Advanced Audio Coding)</option>
                <option>Opus</option>
                <option>MP3</option>
              </select>
              <label><input type="checkbox" checked={noAudio} onChange={(e) => setNoAudio(e.target.checked)} /> No audio</label>
            </div>
            <div className="vc-row">
              <label>Approximate output file size:</label>
              <input type="range" min={10} max={1000} value={outputSize} onChange={(e) => setOutputSize(Number(e.target.value))} />
              <span>{outputSize} Mb</span>
            </div>
          </div>
        )}
      </div>

      {/* Step 3 */}
      <div className="vc-section vc-convert">
        <h2 className="vc-title">3. Convert</h2>
        <button className="vc-button vc-convert-button">
          <AiOutlineCloudDownload /> Convert
        </button>
      </div>
    </div>
  );
}
