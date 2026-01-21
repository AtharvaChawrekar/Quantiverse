import React, { useState, useRef } from 'react';
import './ImageUploader.css';

const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:5000';

const ImageUploader = ({ currentImage, onImageChange, onImageUrlChange }) => {
  const [uploading, setUploading] = useState(false);
  const [preview, setPreview] = useState(currentImage || '');
  const [uploadMode, setUploadMode] = useState(currentImage ? 'url' : 'upload');
  const [imageUrl, setImageUrl] = useState(currentImage || '');
  const [error, setError] = useState('');
  const fileInputRef = useRef(null);

  const handleFileSelect = async (e) => {
    const file = e.target.files[0];
    if (!file) return;

    // Validate file
    const validTypes = ['image/png', 'image/jpeg', 'image/jpg', 'image/gif', 'image/webp'];
    if (!validTypes.includes(file.type)) {
      setError('Invalid file type. Please upload PNG, JPG, JPEG, GIF, or WEBP');
      return;
    }

    const maxSize = 5 * 1024 * 1024; // 5MB
    if (file.size > maxSize) {
      setError('File size must be less than 5MB');
      return;
    }

    setError('');
    setUploading(true);

    try {
      // Create preview
      const reader = new FileReader();
      reader.onloadend = () => {
        setPreview(reader.result);
      };
      reader.readAsDataURL(file);

      // Upload file
      const formData = new FormData();
      formData.append('image', file);

      const response = await fetch(`${API_BASE_URL}/api/upload/internship-image`, {
        method: 'POST',
        body: formData,
      });

      const data = await response.json();

      if (data.success) {
        const fullImageUrl = `${API_BASE_URL}${data.image_url}`;
        setImageUrl(fullImageUrl);
        setPreview(fullImageUrl);
        onImageChange && onImageChange(fullImageUrl);
        setError('');
      } else {
        setError(data.error || 'Failed to upload image');
        setPreview('');
      }
    } catch (err) {
      console.error('Upload error:', err);
      setError('Failed to upload image. Please try again.');
      setPreview('');
    } finally {
      setUploading(false);
    }
  };

  const handleUrlChange = (e) => {
    const url = e.target.value;
    setImageUrl(url);
    setPreview(url);
    onImageUrlChange && onImageUrlChange(url);
    setError('');
  };

  const handleDeleteImage = async () => {
    if (uploadMode === 'upload' && imageUrl) {
      try {
        await fetch(`${API_BASE_URL}/api/delete/internship-image`, {
          method: 'DELETE',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({ image_url: imageUrl }),
        });
      } catch (err) {
        console.error('Delete error:', err);
      }
    }

    setPreview('');
    setImageUrl('');
    onImageChange && onImageChange('');
    onImageUrlChange && onImageUrlChange('');
    if (fileInputRef.current) {
      fileInputRef.current.value = '';
    }
  };

  const handleReupload = () => {
    if (fileInputRef.current) {
      fileInputRef.current.click();
    }
  };

  const switchMode = (mode) => {
    setUploadMode(mode);
    setPreview('');
    setImageUrl('');
    setError('');
    onImageChange && onImageChange('');
    onImageUrlChange && onImageUrlChange('');
  };

  return (
    <div className="image-uploader">
      <label className="block text-sm font-semibold mb-2">
        Internship Image
      </label>

      {/* Mode Selector */}
      <div className="mode-selector">
        <button
          type="button"
          className={`mode-btn ${uploadMode === 'upload' ? 'active' : ''}`}
          onClick={() => switchMode('upload')}
        >
          Upload Image
        </button>
        <button
          type="button"
          className={`mode-btn ${uploadMode === 'url' ? 'active' : ''}`}
          onClick={() => switchMode('url')}
        >
          Use URL
        </button>
      </div>

      {/* Upload Mode */}
      {uploadMode === 'upload' && (
        <div className="upload-section">
          {!preview ? (
            <div className="upload-area">
              <input
                ref={fileInputRef}
                type="file"
                accept="image/png,image/jpeg,image/jpg,image/gif,image/webp"
                onChange={handleFileSelect}
                className="file-input"
                id="image-file-input"
              />
              <label htmlFor="image-file-input" className="upload-label">
                {uploading ? (
                  <div className="uploading">
                    <div className="spinner"></div>
                    <span>Uploading...</span>
                  </div>
                ) : (
                  <>
                    <svg className="upload-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12" />
                    </svg>
                    <span className="upload-text">Click to upload image</span>
                    <span className="upload-hint">PNG, JPG, GIF, WEBP (max 5MB)</span>
                  </>
                )}
              </label>
            </div>
          ) : (
            <div className="preview-section">
              <div className="image-preview">
                <img src={preview} alt="Preview" />
              </div>
              <div className="preview-actions">
                <button
                  type="button"
                  className="btn-reupload"
                  onClick={handleReupload}
                >
                  <svg className="btn-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
                  </svg>
                  Re-upload
                </button>
                <button
                  type="button"
                  className="btn-delete"
                  onClick={handleDeleteImage}
                >
                  <svg className="btn-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                  </svg>
                  Delete
                </button>
              </div>
            </div>
          )}
        </div>
      )}

      {/* URL Mode */}
      {uploadMode === 'url' && (
        <div className="url-section">
          <input
            type="url"
            value={imageUrl}
            onChange={handleUrlChange}
            className="url-input"
            placeholder="https://example.com/image.jpg"
          />
          {preview && (
            <div className="preview-section">
              <div className="image-preview">
                <img src={preview} alt="Preview" onError={() => setError('Failed to load image from URL')} />
              </div>
              <button
                type="button"
                className="btn-delete"
                onClick={handleDeleteImage}
              >
                Clear
              </button>
            </div>
          )}
        </div>
      )}

      {/* Error Message */}
      {error && (
        <div className="error-message">
          <svg className="error-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
          <span>{error}</span>
        </div>
      )}

      {/* Help Text */}
      <div className="help-text">
        {uploadMode === 'upload' 
          ? 'Upload an image from your computer (max 5MB, automatically resized if too large)'
          : 'Enter the URL of an image hosted online'
        }
      </div>
    </div>
  );
};

export default ImageUploader;
