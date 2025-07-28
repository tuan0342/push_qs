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
      <div className="camera-popup-container">
        <div className="camera-popup-header">
          <h2>Camera Source Info</h2>
          <button className="camera-close-btn" onClick={onClose}>×</button>
        </div>
        <div className="camera-popup-content">
          <div className="info-row"><span>Tên:</span> {name}</div>
          <div className="info-row"><span>Loại nguồn:</span> {source.type}</div>
          <div className="info-row"><span>Trạng thái:</span> {ready ? 'Sẵn sàng ✅' : 'Chưa sẵn sàng ❌'}</div>
          <div className="info-row"><span>Thời gian sẵn sàng:</span> {formatDate(readyTime)}</div>
          <div className="info-row"><span>Track:</span> {track.join(', ')}</div>
          <div className="info-row"><span>Dữ liệu nhận:</span> {formatBytes(bytesReceived)}</div>
          <div className="info-row"><span>Dữ liệu gửi:</span> {formatBytes(bytesSent)}</div>
          <div className="info-row"><span>Readers:</span> {readers.length}</div>
        </div>
      </div>
    </div>
  );
};

export default CameraSourcePopup;
