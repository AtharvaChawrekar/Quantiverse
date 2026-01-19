# Notification System Documentation

## Overview

This notification system enables users to submit tasks for admin review and receive real-time notifications when tasks are approved or rejected. The system provides a complete end-to-end workflow from task submission to notification delivery.

## System Architecture

### Backend Components

#### 1. Data Models

**Task Model** (`backend/tasks.json`)
```json
{
  "id": "uuid",
  "user_id": "string",
  "user_email": "string",
  "user_name": "string",
  "title": "string",
  "description": "string",
  "category": "general|resume|interview|internship|project|other",
  "status": "pending|approved|rejected",
  "submitted_at": "ISO 8601 datetime",
  "reviewed_at": "ISO 8601 datetime | null",
  "reviewed_by": "string | null",
  "admin_notes": "string | null"
}
```

**Notification Model** (`backend/notifications.json`)
```json
{
  "id": "uuid",
  "user_id": "string",
  "task_id": "string",
  "message": "string",
  "type": "success|error|info|warning",
  "read": "boolean",
  "created_at": "ISO 8601 datetime",
  "updated_at": "ISO 8601 datetime"
}
```

#### 2. API Endpoints

**Task Endpoints:**

- `POST /api/tasks` - Submit a new task
  - Body: `{ user_id, user_email, user_name, title, description, category }`
  - Returns: Created task object

- `GET /api/tasks/<task_id>` - Get specific task
  - Returns: Task object

- `GET /api/tasks/user/<user_id>` - Get all tasks for a user
  - Returns: Array of user's tasks

- `GET /api/tasks?status=<status>` - Get all tasks (admin)
  - Query params: `status` (optional): pending|approved|rejected
  - Returns: Array of tasks

- `PATCH /api/tasks/<task_id>/review` - Admin review task
  - Body: `{ status, admin_id, admin_notes }`
  - Returns: Updated task and created notification

**Notification Endpoints:**

- `GET /api/notifications/<user_id>` - Get user notifications
  - Returns: `{ notifications: [], total_count, unread_count }`

- `PATCH /api/notifications/<notification_id>/read` - Mark as read
  - Returns: Updated notification

- `PATCH /api/notifications/user/<user_id>/mark-all-read` - Mark all as read
  - Returns: `{ success, updated_count }`

- `DELETE /api/notifications/<notification_id>` - Delete notification
  - Returns: Success confirmation

- `GET /api/notifications/user/<user_id>/unread-count` - Get unread count
  - Returns: `{ unread_count }`

### Frontend Components

#### 1. Context & State Management

**NotificationContext** (`src/components/notifications/NotificationContext.jsx`)
- Manages notification state globally
- Provides notification data to all components
- Handles polling for new notifications (every 30 seconds)
- Methods:
  - `fetchNotifications()` - Load all notifications
  - `fetchUnreadCount()` - Get unread count
  - `markAsRead(id)` - Mark single notification as read
  - `markAllAsRead()` - Mark all notifications as read
  - `deleteNotification(id)` - Delete notification

#### 2. UI Components

**NotificationBell** (`src/components/notifications/NotificationBell.jsx`)
- Bell icon with unread badge
- Dropdown notification list
- Features:
  - Real-time unread count display
  - Mark individual notifications as read
  - Mark all as read
  - Delete notifications
  - Time-ago formatting
  - Click outside to close

**TaskSubmission** (`src/components/tasks/TaskSubmission.jsx`)
- Form for users to submit tasks
- Fields:
  - Category (dropdown)
  - Title (max 200 chars)
  - Description (max 1000 chars)
- Success/error feedback
- Character counters

**AdminTaskManager** (`src/components/admin/AdminTaskManager.jsx`)
- Admin interface to review tasks
- Features:
  - Statistics dashboard (total, pending, approved, rejected)
  - Filter by status
  - Review modal with approve/reject actions
  - Add admin notes
  - View task details

## User Flow

### Task Submission Flow

1. **User submits task:**
   - User navigates to `/submit-task`
   - Fills out form with title, description, and category
   - Clicks "Submit Task"
   - Task is created with status "pending"

2. **Admin reviews task:**
   - Admin navigates to `/admin/tasks`
   - Views pending tasks in dashboard
   - Clicks "Review Task" on a specific task
   - Reviews task details
   - Adds optional admin notes
   - Clicks "Approve" or "Reject"

3. **Notification created:**
   - System automatically creates notification when task is reviewed
   - Notification message is customized based on approval/rejection
   - Notification is linked to the task and user

4. **User receives notification:**
   - Notification bell updates with new count
   - User clicks bell icon to view notifications
   - User sees approval/rejection message
   - User can mark as read or delete

## Notification Lifecycle

```
Task Submission → Pending Status → Admin Review → Status Update
                                         ↓
                            Notification Creation
                                         ↓
                              User Notification List
                                         ↓
                                    Read/Delete
```

## Data Flow Diagram

```
┌──────────┐          ┌──────────┐          ┌──────────────┐
│   User   │ ─submit─→│  Backend │─creates─→│ Notification │
│          │          │          │          │              │
└────┬─────┘          └────┬─────┘          └──────┬───────┘
     │                     │                       │
     │                     │                       │
     │                ┌────▼────┐                  │
     │                │  Task   │                  │
     │                │ Storage │                  │
     │                └────┬────┘                  │
     │                     │                       │
     │                     │                       │
┌────▼─────┐         ┌────▼────┐            ┌─────▼───────┐
│  Admin   │─review─→│  Update │─triggers─→ │   Create    │
│Dashboard │         │  Task   │            │Notification │
└──────────┘         └─────────┘            └─────────────┘
                                                   │
                                                   │
                                            ┌──────▼──────┐
                                            │    User     │
                                            │Notification │
                                            │    Bell     │
                                            └─────────────┘
```

## Integration Guide

### 1. Backend Integration

Add to `backend/app.py`:
```python
from notification_service import notification_bp

# Register blueprint
app.register_blueprint(notification_bp)
```

### 2. Frontend Integration

Add to `src/main.jsx`:
```jsx
import { NotificationProvider } from "./components/notifications/NotificationContext";

<AuthContextProvider>
  <NotificationProvider>
    <App />
  </NotificationProvider>
</AuthContextProvider>
```

Add to `src/App.jsx`:
```jsx
import TaskSubmission from "./components/tasks/TaskSubmission";
import AdminTaskManager from "./components/admin/AdminTaskManager";

// Add routes
<Route path="/submit-task" element={<ProtectedRoute><TaskSubmission /></ProtectedRoute>} />
<Route path="/admin/tasks" element={<ProtectedRoute><AdminTaskManager /></ProtectedRoute>} />
```

Add to `src/components/Navbar.jsx`:
```jsx
import NotificationBell from "./notifications/NotificationBell";

// Replace existing notification button with:
<NotificationBell />
```

## Environment Variables

Add to your `.env` file:
```
VITE_API_URL=http://localhost:5000
```

## Security & Access Control

### Current Implementation:
- All endpoints are accessible without authentication
- User IDs are passed in requests
- No role-based access control

### Recommended Improvements:

1. **Add Authentication Middleware:**
```python
from functools import wraps
from flask import request, jsonify

def require_auth(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        # Verify Supabase JWT token
        auth_header = request.headers.get('Authorization')
        if not auth_header:
            return jsonify({'error': 'No authorization token'}), 401
        # Validate token with Supabase
        return f(*args, **kwargs)
    return decorated_function
```

2. **Add Admin Role Check:**
```python
def require_admin(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        # Check if user has admin role
        # This could check user_metadata or a roles table
        return f(*args, **kwargs)
    return decorated_function
```

3. **Apply to endpoints:**
```python
@notification_bp.route('/api/tasks/<task_id>/review', methods=['PATCH'])
@require_auth
@require_admin
def review_task(task_id):
    # ... implementation
```

## Features

### Current Features:
✅ Task submission with categories
✅ Admin task review interface
✅ Automatic notification creation
✅ Real-time notification bell with unread count
✅ Mark notifications as read
✅ Delete notifications
✅ Filter tasks by status
✅ Admin notes on task review
✅ User task history

### Potential Enhancements:

1. **Real-time Updates:**
   - Implement WebSockets for instant notification delivery
   - Use Server-Sent Events (SSE) for push notifications

2. **Email Notifications:**
   - Send email when task is reviewed
   - Configurable notification preferences

3. **Database Migration:**
   - Move from JSON files to Supabase database
   - Use Row Level Security (RLS) for data access

4. **Advanced Filtering:**
   - Search tasks by title/description
   - Date range filters
   - Multiple category selection

5. **Analytics:**
   - Task approval/rejection rates
   - Average review time
   - User submission patterns

6. **Notification Preferences:**
   - Enable/disable notifications
   - Notification sound/visual preferences
   - Email vs in-app notifications

## Testing

### Manual Testing Checklist:

**Task Submission:**
- [ ] Submit task successfully
- [ ] Validate required fields
- [ ] Verify character limits
- [ ] Check task appears in user's task list

**Admin Review:**
- [ ] View all pending tasks
- [ ] Filter by status
- [ ] Approve task and verify notification
- [ ] Reject task with notes and verify notification
- [ ] Check statistics update correctly

**Notifications:**
- [ ] Notification appears after task review
- [ ] Unread count displays correctly
- [ ] Mark as read updates count
- [ ] Mark all as read works
- [ ] Delete notification works
- [ ] Notifications persist across page refreshes

**UI/UX:**
- [ ] Notification dropdown closes on outside click
- [ ] Responsive design works on mobile
- [ ] Time-ago formatting is accurate
- [ ] Badge colors match notification type

## Troubleshooting

### Common Issues:

**1. Notifications not appearing:**
- Check that NotificationProvider wraps App
- Verify user session exists
- Check browser console for errors
- Verify API endpoints are accessible

**2. Unread count not updating:**
- Check polling interval (30 seconds)
- Verify fetchUnreadCount is being called
- Check network tab for API calls

**3. Task submission fails:**
- Verify user session has required fields
- Check form validation
- Review backend logs for errors
- Ensure tasks.json has write permissions

**4. Backend errors:**
- Check Python dependencies are installed
- Verify JSON files exist and have proper permissions
- Review Flask logs
- Check CORS configuration

## API Response Examples

### Successful Task Submission:
```json
{
  "success": true,
  "message": "Task submitted successfully",
  "task": {
    "id": "123e4567-e89b-12d3-a456-426614174000",
    "user_id": "user123",
    "title": "Resume Review Request",
    "status": "pending",
    "submitted_at": "2026-01-19T10:30:00Z"
  }
}
```

### Get Notifications:
```json
{
  "success": true,
  "notifications": [
    {
      "id": "notif-123",
      "message": "Your task 'Resume Review Request' has been approved! ✓",
      "type": "success",
      "read": false,
      "created_at": "2026-01-19T11:00:00Z"
    }
  ],
  "total_count": 5,
  "unread_count": 2
}
```

## Performance Considerations

### Current Implementation:
- JSON file-based storage (suitable for low traffic)
- 30-second polling interval for notifications
- Client-side filtering and sorting

### Scaling Recommendations:

1. **Database Migration:**
   - Move to PostgreSQL/Supabase for better performance
   - Add indexes on user_id, status, created_at

2. **Caching:**
   - Cache unread counts in Redis
   - Cache frequently accessed tasks

3. **Rate Limiting:**
   - Limit API requests per user
   - Throttle notification checks

4. **Pagination:**
   - Implement pagination for task lists
   - Limit notifications returned

## Conclusion

This notification system provides a complete solution for task submission and notification management. It includes both user-facing and admin interfaces, with a clean separation between backend logic and frontend presentation. The system is designed to be easily extensible and can be enhanced with additional features as needed.

For questions or support, refer to the inline code comments or contact the development team.
