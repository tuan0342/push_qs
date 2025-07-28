// components/CameraSourcePopup.tsx
import React from 'react';
import './CameraSourcePopup.css';

export interface CameraSource {
  name: string;
  source: {
    type: string;
  };
  ready: boolean;
  readyTime: string;
  track: string[];
  bytesReceived: number;
  bytesSent: number;
  readers: any[];
  onClose?: () => void;
}

const formatBytes = (bytes: number): string => {
  if (bytes === 0) return '0 Bytes';
  const k = 1024;
  const sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB'];
  const i = Math.floor(Math.log(bytes) / Math.log(k));
  return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
};

const formatDate = (iso: string): string => {
  const date = new Date(iso);
  return date.toLocaleString();
};

const CameraSourcePopup: React.FC<CameraSource> = ({
  name,
  source,
  ready,
  readyTime,
  track,
  bytesReceived,
  bytesSent,
  readers,
  onClose
}) => {
  return (
   <div className="camera-popup-backdrop">
      <div className="camera-popup-container animate-popup">
        <div className="camera-popup-header">
          <h2>🎥 {name}</h2>
          <button className="camera-close-btn" onClick={onClose}>×</button>
        </div>
        <div className="camera-popup-content">
          <div className="info-row">
            <FaVideo className="icon" />
            <span>Loại nguồn:</span>
            <span>{source.type}</span>
          </div>
          <div className="info-row">
            {ready ? <FaCheckCircle className="icon green" /> : <FaTimesCircle className="icon red" />}
            <span>Trạng thái:</span>
            <span>{ready ? 'Sẵn sàng' : 'Không sẵn sàng'}</span>
          </div>
          <div className="info-row">
            <FaClock className="icon" />
            <span>Ready lúc:</span>
            <span>{formatDate(readyTime)}</span>
          </div>
          <div className="info-row">
            <FaCompactDisc className="icon" />
            <span>Track:</span>
            <span>{track.join(', ')}</span>
          </div>
          <div className="info-row">
            <FaDownload className="icon" />
            <span>Đã nhận:</span>
            <span>{formatBytes(bytesReceived)}</span>
          </div>
          <div className="info-row">
            <FaUpload className="icon" />
            <span>Đã gửi:</span>
            <span>{formatBytes(bytesSent)}</span>
          </div>
          <div className="info-row">
            <FaUser className="icon" />
            <span>Người xem:</span>
            <span>{readers.length}</span>
          </div>
        </div>
      </div>
    </div>
  );
};

export default CameraSourcePopup;
