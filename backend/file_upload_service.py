"""
File Upload Service for Internship Images
Handles image uploads with validation and storage
"""

from flask import Blueprint, request, jsonify
from werkzeug.utils import secure_filename
from pathlib import Path
import uuid
import os
from PIL import Image
import io

file_upload_bp = Blueprint('file_upload', __name__)

# Configuration
UPLOAD_FOLDER = Path('uploads/internship_images')
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'gif', 'webp'}
MAX_FILE_SIZE = 5 * 1024 * 1024  # 5MB
MAX_IMAGE_DIMENSION = 2000  # Max width/height in pixels

# Create upload directory if it doesn't exist
UPLOAD_FOLDER.mkdir(parents=True, exist_ok=True)


def allowed_file(filename):
    """Check if file extension is allowed"""
    return '.' in filename and \
           filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS


def validate_image(file_stream):
    """Validate image file"""
    try:
        img = Image.open(file_stream)
        img.verify()
        return True
    except Exception as e:
        print(f"Image validation error: {str(e)}")
        return False


def resize_image_if_needed(image_path, max_dimension=MAX_IMAGE_DIMENSION):
    """Resize image if it exceeds max dimensions"""
    try:
        with Image.open(image_path) as img:
            # Get current dimensions
            width, height = img.size
            
            # Check if resize is needed
            if width > max_dimension or height > max_dimension:
                # Calculate new dimensions maintaining aspect ratio
                if width > height:
                    new_width = max_dimension
                    new_height = int((max_dimension / width) * height)
                else:
                    new_height = max_dimension
                    new_width = int((max_dimension / height) * width)
                
                # Resize image
                img_resized = img.resize((new_width, new_height), Image.Resampling.LANCZOS)
                
                # Save resized image
                img_resized.save(image_path, quality=85, optimize=True)
                print(f"Image resized from {width}x{height} to {new_width}x{new_height}")
    except Exception as e:
        print(f"Error resizing image: {str(e)}")


@file_upload_bp.route('/api/upload/internship-image', methods=['POST'])
def upload_internship_image():
    """
    Upload an internship image
    
    Expected: multipart/form-data with 'image' file
    Returns: { success: true, image_url: '/uploads/...' }
    """
    try:
        # Check if file is in request
        if 'image' not in request.files:
            return jsonify({'error': 'No image file provided'}), 400
        
        file = request.files['image']
        
        # Check if file is selected
        if file.filename == '':
            return jsonify({'error': 'No file selected'}), 400
        
        # Check file size
        file.seek(0, os.SEEK_END)
        file_size = file.tell()
        file.seek(0)
        
        if file_size > MAX_FILE_SIZE:
            return jsonify({'error': f'File size exceeds {MAX_FILE_SIZE // (1024*1024)}MB limit'}), 400
        
        # Check if file type is allowed
        if not allowed_file(file.filename):
            return jsonify({'error': 'Invalid file type. Allowed: PNG, JPG, JPEG, GIF, WEBP'}), 400
        
        # Validate image
        if not validate_image(file.stream):
            return jsonify({'error': 'Invalid image file'}), 400
        
        # Reset file pointer after validation
        file.seek(0)
        
        # Generate unique filename
        file_ext = file.filename.rsplit('.', 1)[1].lower()
        unique_filename = f"{uuid.uuid4().hex}.{file_ext}"
        file_path = UPLOAD_FOLDER / unique_filename
        
        # Save file
        file.save(str(file_path))
        
        # Resize if needed
        resize_image_if_needed(file_path)
        
        # Generate URL (relative path from backend)
        image_url = f"/uploads/internship_images/{unique_filename}"
        
        return jsonify({
            'success': True,
            'image_url': image_url,
            'filename': unique_filename,
            'message': 'Image uploaded successfully'
        }), 200
        
    except Exception as e:
        print(f"Error uploading image: {str(e)}")
        return jsonify({'error': 'Failed to upload image', 'details': str(e)}), 500


@file_upload_bp.route('/api/delete/internship-image', methods=['DELETE'])
def delete_internship_image():
    """
    Delete an internship image
    
    Expected JSON: { "image_url": "/uploads/internship_images/..." }
    Returns: { success: true, message: '...' }
    """
    try:
        data = request.json
        image_url = data.get('image_url', '')
        
        if not image_url:
            return jsonify({'error': 'No image URL provided'}), 400
        
        # Extract filename from URL
        filename = image_url.split('/')[-1]
        file_path = UPLOAD_FOLDER / filename
        
        # Check if file exists
        if not file_path.exists():
            return jsonify({'error': 'Image file not found'}), 404
        
        # Delete file
        file_path.unlink()
        
        return jsonify({
            'success': True,
            'message': 'Image deleted successfully'
        }), 200
        
    except Exception as e:
        print(f"Error deleting image: {str(e)}")
        return jsonify({'error': 'Failed to delete image', 'details': str(e)}), 500


@file_upload_bp.route('/api/internship-images/<filename>', methods=['GET'])
def serve_internship_image(filename):
    """
    Serve internship image
    Note: In production, use a CDN or cloud storage
    """
    try:
        from flask import send_file
        
        file_path = UPLOAD_FOLDER / secure_filename(filename)
        
        if not file_path.exists():
            return jsonify({'error': 'Image not found'}), 404
        
        return send_file(str(file_path))
        
    except Exception as e:
        print(f"Error serving image: {str(e)}")
        return jsonify({'error': 'Failed to serve image'}), 500
