// components/PopupVideoSelector.tsx
import React from 'react';
import './VideoConverter.css'; // dùng chung style

interface Video {
  id: string;
  userId: string;
  name: string;
  thumbnailUrl: string;
  defaultUrl: string;
}

interface Props {
  videos: Video[];
  selectedVideo: Video | null;
  onSelect: (video: Video) => void;
  onCancel: () => void;
  onConfirm: () => void;
}

export default function PopupVideoSelector({
  videos,
  selectedVideo,
  onSelect,
  onCancel,
  onConfirm,
}: Props) {
  return (
    <div className="popup-overlay">
      <div className="popup-content">
        <h3 className="popup-title">Select a video</h3>
        <div className="video-grid">
          {videos.map((video) => (
            <div
              key={video.id}
              className={`video-card ${selectedVideo?.id === video.id ? 'selected' : ''}`}
              onClick={() => onSelect(video)}
            >
              <img src={video.thumbnailUrl} alt={video.name} />
              <div className="video-name">{video.name}</div>
            </div>
          ))}
        </div>
        <div className="popup-actions">
          <button className="popup-btn cancel" onClick={onCancel}>Cancel</button>
          <button className="popup-btn confirm" onClick={onConfirm}>OK</button>
        </div>
      </div>
    </div>
  );
}
