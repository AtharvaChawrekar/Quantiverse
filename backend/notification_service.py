"""
Notification Service Module
Handles creation, retrieval, and management of user notifications
"""

from flask import Blueprint, request, jsonify
from pathlib import Path
import json
from datetime import datetime
import uuid

notification_bp = Blueprint('notification', __name__)

# File paths for data storage
NOTIFICATIONS_FILE = Path('notifications.json')
TASKS_FILE = Path('tasks.json')


def load_notifications():
    """Load notifications from JSON file"""
    if NOTIFICATIONS_FILE.exists():
        with open(NOTIFICATIONS_FILE, 'r') as f:
            return json.load(f)
    return []


def save_notifications(notifications):
    """Save notifications to JSON file"""
    with open(NOTIFICATIONS_FILE, 'w') as f:
        json.dump(notifications, f, indent=2)


def load_tasks():
    """Load tasks from JSON file"""
    if TASKS_FILE.exists():
        with open(TASKS_FILE, 'r') as f:
            return json.load(f)
    return []


def save_tasks(tasks):
    """Save tasks to JSON file"""
    with open(TASKS_FILE, 'w') as f:
        json.dump(tasks, f, indent=2)


def create_notification(user_id, task_id, message, notification_type='info'):
    """
    Create a new notification for a user
    
    Args:
        user_id: The ID of the user receiving the notification
        task_id: The ID of the related task
        message: The notification message
        notification_type: Type of notification (success, error, info, warning)
    
    Returns:
        The created notification object
    """
    notifications = load_notifications()
    
    notification = {
        'id': str(uuid.uuid4()),
        'user_id': user_id,
        'task_id': task_id,
        'message': message,
        'type': notification_type,
        'read': False,
        'created_at': datetime.utcnow().isoformat(),
        'updated_at': datetime.utcnow().isoformat()
    }
    
    notifications.append(notification)
    save_notifications(notifications)
    
    return notification


# ==================== TASK ENDPOINTS ====================

@notification_bp.route('/api/tasks', methods=['POST'])
def submit_task():
    """Submit a new task for admin review"""
    try:
        data = request.json
        
        # Validate required fields
        required_fields = ['user_id', 'title', 'description']
        for field in required_fields:
            if field not in data:
                return jsonify({'error': f'Missing required field: {field}'}), 400
        
        tasks = load_tasks()
        
        task = {
            'id': str(uuid.uuid4()),
            'user_id': data['user_id'],
            'user_email': data.get('user_email', ''),
            'user_name': data.get('user_name', 'Unknown User'),
            'title': data['title'],
            'description': data['description'],
            'category': data.get('category', 'general'),
            'status': 'pending',  # pending, approved, rejected
            'submitted_at': datetime.utcnow().isoformat(),
            'reviewed_at': None,
            'reviewed_by': None,
            'admin_notes': None
        }
        
        tasks.append(task)
        save_tasks(tasks)
        
        # Create notification for admin (optional - you can implement admin notifications later)
        # For now, we'll just return the task
        
        return jsonify({
            'success': True,
            'message': 'Task submitted successfully',
            'task': task
        }), 201
        
    except Exception as e:
        print(f"Error submitting task: {str(e)}")
        return jsonify({'error': 'Failed to submit task', 'details': str(e)}), 500


@notification_bp.route('/api/tasks/<task_id>', methods=['GET'])
def get_task(task_id):
    """Get a specific task by ID"""
    try:
        tasks = load_tasks()
        task = next((t for t in tasks if t['id'] == task_id), None)
        
        if not task:
            return jsonify({'error': 'Task not found'}), 404
        
        return jsonify(task), 200
        
    except Exception as e:
        print(f"Error fetching task: {str(e)}")
        return jsonify({'error': 'Failed to fetch task', 'details': str(e)}), 500


@notification_bp.route('/api/tasks/user/<user_id>', methods=['GET'])
def get_user_tasks(user_id):
    """Get all tasks for a specific user"""
    try:
        tasks = load_tasks()
        user_tasks = [t for t in tasks if t['user_id'] == user_id]
        
        # Sort by submitted_at (most recent first)
        user_tasks.sort(key=lambda x: x['submitted_at'], reverse=True)
        
        return jsonify({
            'success': True,
            'tasks': user_tasks,
            'count': len(user_tasks)
        }), 200
        
    except Exception as e:
        print(f"Error fetching user tasks: {str(e)}")
        return jsonify({'error': 'Failed to fetch tasks', 'details': str(e)}), 500


@notification_bp.route('/api/tasks', methods=['GET'])
def get_all_tasks():
    """Get all tasks (admin only)"""
    try:
        tasks = load_tasks()
        
        # Filter by status if provided
        status = request.args.get('status')
        if status:
            tasks = [t for t in tasks if t['status'] == status]
        
        # Sort by submitted_at (most recent first)
        tasks.sort(key=lambda x: x['submitted_at'], reverse=True)
        
        return jsonify({
            'success': True,
            'tasks': tasks,
            'count': len(tasks)
        }), 200
        
    except Exception as e:
        print(f"Error fetching tasks: {str(e)}")
        return jsonify({'error': 'Failed to fetch tasks', 'details': str(e)}), 500


@notification_bp.route('/api/tasks/<task_id>/review', methods=['PATCH'])
def review_task(task_id):
    """Admin endpoint to approve or reject a task"""
    try:
        data = request.json
        
        # Validate required fields
        if 'status' not in data or data['status'] not in ['approved', 'rejected']:
            return jsonify({'error': 'Invalid status. Must be "approved" or "rejected"'}), 400
        
        tasks = load_tasks()
        task = next((t for t in tasks if t['id'] == task_id), None)
        
        if not task:
            return jsonify({'error': 'Task not found'}), 404
        
        # Update task status
        task['status'] = data['status']
        task['reviewed_at'] = datetime.utcnow().isoformat()
        task['reviewed_by'] = data.get('admin_id', 'admin')
        task['admin_notes'] = data.get('admin_notes', '')
        
        save_tasks(tasks)
        
        # Create notification for the user
        if data['status'] == 'approved':
            message = f'Your task "{task["title"]}" has been approved! ✓'
            notification_type = 'success'
        else:
            message = f'Your task "{task["title"]}" was rejected.'
            notification_type = 'error'
            if task['admin_notes']:
                message += f' Reason: {task["admin_notes"]}'
        
        notification = create_notification(
            user_id=task['user_id'],
            task_id=task_id,
            message=message,
            notification_type=notification_type
        )
        
        return jsonify({
            'success': True,
            'message': 'Task reviewed successfully',
            'task': task,
            'notification': notification
        }), 200
        
    except Exception as e:
        print(f"Error reviewing task: {str(e)}")
        return jsonify({'error': 'Failed to review task', 'details': str(e)}), 500


# ==================== NOTIFICATION ENDPOINTS ====================

@notification_bp.route('/api/notifications/<user_id>', methods=['GET'])
def get_notifications(user_id):
    """Get all notifications for a specific user"""
    try:
        notifications = load_notifications()
        user_notifications = [n for n in notifications if n['user_id'] == user_id]
        
        # Sort by created_at (most recent first)
        user_notifications.sort(key=lambda x: x['created_at'], reverse=True)
        
        # Get counts
        unread_count = sum(1 for n in user_notifications if not n['read'])
        
        return jsonify({
            'success': True,
            'notifications': user_notifications,
            'total_count': len(user_notifications),
            'unread_count': unread_count
        }), 200
        
    except Exception as e:
        print(f"Error fetching notifications: {str(e)}")
        return jsonify({'error': 'Failed to fetch notifications', 'details': str(e)}), 500


@notification_bp.route('/api/notifications/<notification_id>/read', methods=['PATCH'])
def mark_notification_read(notification_id):
    """Mark a notification as read"""
    try:
        notifications = load_notifications()
        notification = next((n for n in notifications if n['id'] == notification_id), None)
        
        if not notification:
            return jsonify({'error': 'Notification not found'}), 404
        
        notification['read'] = True
        notification['updated_at'] = datetime.utcnow().isoformat()
        
        save_notifications(notifications)
        
        return jsonify({
            'success': True,
            'message': 'Notification marked as read',
            'notification': notification
        }), 200
        
    except Exception as e:
        print(f"Error marking notification as read: {str(e)}")
        return jsonify({'error': 'Failed to update notification', 'details': str(e)}), 500


@notification_bp.route('/api/notifications/user/<user_id>/mark-all-read', methods=['PATCH'])
def mark_all_notifications_read(user_id):
    """Mark all notifications as read for a user"""
    try:
        notifications = load_notifications()
        updated_count = 0
        
        for notification in notifications:
            if notification['user_id'] == user_id and not notification['read']:
                notification['read'] = True
                notification['updated_at'] = datetime.utcnow().isoformat()
                updated_count += 1
        
        save_notifications(notifications)
        
        return jsonify({
            'success': True,
            'message': f'Marked {updated_count} notifications as read',
            'updated_count': updated_count
        }), 200
        
    except Exception as e:
        print(f"Error marking all notifications as read: {str(e)}")
        return jsonify({'error': 'Failed to update notifications', 'details': str(e)}), 500


@notification_bp.route('/api/notifications/<notification_id>', methods=['DELETE'])
def delete_notification(notification_id):
    """Delete a notification"""
    try:
        notifications = load_notifications()
        original_count = len(notifications)
        
        notifications = [n for n in notifications if n['id'] != notification_id]
        
        if len(notifications) == original_count:
            return jsonify({'error': 'Notification not found'}), 404
        
        save_notifications(notifications)
        
        return jsonify({
            'success': True,
            'message': 'Notification deleted successfully'
        }), 200
        
    except Exception as e:
        print(f"Error deleting notification: {str(e)}")
        return jsonify({'error': 'Failed to delete notification', 'details': str(e)}), 500


@notification_bp.route('/api/notifications/user/<user_id>/unread-count', methods=['GET'])
def get_unread_count(user_id):
    """Get unread notification count for a user"""
    try:
        notifications = load_notifications()
        user_notifications = [n for n in notifications if n['user_id'] == user_id]
        unread_count = sum(1 for n in user_notifications if not n['read'])
        
        return jsonify({
            'success': True,
            'unread_count': unread_count
        }), 200
        
    except Exception as e:
        print(f"Error fetching unread count: {str(e)}")
        return jsonify({'error': 'Failed to fetch unread count', 'details': str(e)}), 500
