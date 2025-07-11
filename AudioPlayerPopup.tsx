import React, { useRef, useState, useEffect } from 'react';
import './AudioPlayerPopup.css';

interface AudioPlayerPopupProps {
  audioUrl: string;
  title: string;
  onClose: () => void;
}

const AudioPlayerPopup: React.FC<AudioPlayerPopupProps> = ({ audioUrl, title, onClose }) => {
  const audioRef = useRef<HTMLAudioElement>(null);
  const [isPlaying, setIsPlaying] = useState(false);
  const [progress, setProgress] = useState(0);
  const [volume, setVolume] = useState(1);

  useEffect(() => {
    const audio = audioRef.current;
    if (!audio) return;

    const updateProgress = () => {
      setProgress((audio.currentTime / audio.duration) * 100 || 0);
    };

    audio.addEventListener('timeupdate', updateProgress);
    return () => {
      audio.removeEventListener('timeupdate', updateProgress);
    };
  }, []);

  const togglePlay = () => {
    const audio = audioRef.current;
    if (!audio) return;
    if (isPlaying) {
      audio.pause();
    } else {
      audio.play();
    }
    setIsPlaying(!isPlaying);
  };

  const handleSeek = (e: React.ChangeEvent<HTMLInputElement>) => {
    const audio = audioRef.current;
    if (!audio) return;
    const value = Number(e.target.value);
    audio.currentTime = (value / 100) * audio.duration;
    setProgress(value);
  };

  const handleVolume = (e: React.ChangeEvent<HTMLInputElement>) => {
    const audio = audioRef.current;
    if (!audio) return;
    const value = Number(e.target.value);
    audio.volume = value;
    setVolume(value);
  };

  const handleDownload = () => {
    const link = document.createElement('a');
    link.href = audioUrl;
    link.download = audioUrl.split('/').pop()?.split('?')[0] || 'audio';
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  };

  return (
    <div className="audio-popup-overlay">
      <div className="audio-popup">
        <button className="close-btn" onClick={onClose}>✕</button>
        <h3 className="audio-title">{title}</h3>
        <audio ref={audioRef} src={audioUrl} preload="auto" />
        <div className="controls">
          <button onClick={togglePlay}>{isPlaying ? '⏸ Pause' : '▶️ Play'}</button>
          <input
            type="range"
            min="0"
            max="100"
            value={progress}
            onChange={handleSeek}
            className="progress-bar"
          />
          <label className="volume-label">
            🔊
            <input
              type="range"
              min="0"
              max="1"
              step="0.01"
              value={volume}
              onChange={handleVolume}
              className="volume-slider"
            />
          </label>
          <button className="download-btn" onClick={handleDownload}>⬇ Tải về</button>
        </div>
      </div>
    </div>
  );
};

export default AudioPlayerPopup;
