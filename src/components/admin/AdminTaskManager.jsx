import React, { useState, useEffect } from 'react';
import { UserAuth } from '../Auth/AuthContext';
import './AdminTaskManager.css';

const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:5000';

const AdminTaskManager = () => {
  const { session } = UserAuth();
  const [tasks, setTasks] = useState([]);
  const [filteredTasks, setFilteredTasks] = useState([]);
  const [filter, setFilter] = useState('all'); // all, pending, approved, rejected
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const [selectedTask, setSelectedTask] = useState(null);
  const [reviewNote, setReviewNote] = useState('');
  const [reviewLoading, setReviewLoading] = useState(false);

  useEffect(() => {
    fetchTasks();
  }, []);

  useEffect(() => {
    filterTasks();
  }, [tasks, filter]);

  const fetchTasks = async () => {
    setLoading(true);
    setError(null);

    try {
      const response = await fetch(`${API_BASE_URL}/api/tasks`);
      const data = await response.json();

      if (data.success) {
        setTasks(data.tasks);
      } else {
        setError('Failed to fetch tasks');
      }
    } catch (err) {
      console.error('Error fetching tasks:', err);
      setError('Failed to fetch tasks');
    } finally {
      setLoading(false);
    }
  };

  const filterTasks = () => {
    if (filter === 'all') {
      setFilteredTasks(tasks);
    } else {
      setFilteredTasks(tasks.filter((task) => task.status === filter));
    }
  };

  const handleReview = async (taskId, status) => {
    setReviewLoading(true);
    setError(null);

    try {
      const response = await fetch(`${API_BASE_URL}/api/tasks/${taskId}/review`, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          status,
          admin_id: session?.user?.id,
          admin_notes: reviewNote,
        }),
      });

      const data = await response.json();

      if (data.success) {
        // Update local state
        setTasks((prev) =>
          prev.map((task) => (task.id === taskId ? data.task : task))
        );
        setSelectedTask(null);
        setReviewNote('');
      } else {
        setError('Failed to review task');
      }
    } catch (err) {
      console.error('Error reviewing task:', err);
      setError('Failed to review task');
    } finally {
      setReviewLoading(false);
    }
  };

  const getStatusBadge = (status) => {
    const badges = {
      pending: { class: 'badge-pending', text: 'Pending' },
      approved: { class: 'badge-approved', text: 'Approved' },
      rejected: { class: 'badge-rejected', text: 'Rejected' },
    };
    return badges[status] || badges.pending;
  };

  const getCategoryBadge = (category) => {
    const categories = {
      general: 'General',
      resume: 'Resume',
      interview: 'Interview',
      internship: 'Internship',
      project: 'Project',
      other: 'Other',
    };
    return categories[category] || category;
  };

  const formatDate = (dateString) => {
    return new Date(dateString).toLocaleString();
  };

  const stats = {
    total: tasks.length,
    pending: tasks.filter((t) => t.status === 'pending').length,
    approved: tasks.filter((t) => t.status === 'approved').length,
    rejected: tasks.filter((t) => t.status === 'rejected').length,
  };

  return (
    <div className="admin-task-manager">
      <div className="admin-header">
        <h1>Task Management</h1>
        <p>Review and manage user task submissions</p>
      </div>

      {/* Statistics */}
      <div className="stats-container">
        <div className="stat-card">
          <div className="stat-value">{stats.total}</div>
          <div className="stat-label">Total Tasks</div>
        </div>
        <div className="stat-card pending">
          <div className="stat-value">{stats.pending}</div>
          <div className="stat-label">Pending</div>
        </div>
        <div className="stat-card approved">
          <div className="stat-value">{stats.approved}</div>
          <div className="stat-label">Approved</div>
        </div>
        <div className="stat-card rejected">
          <div className="stat-value">{stats.rejected}</div>
          <div className="stat-label">Rejected</div>
        </div>
      </div>

      {/* Filters */}
      <div className="filter-container">
        <button
          className={`filter-btn ${filter === 'all' ? 'active' : ''}`}
          onClick={() => setFilter('all')}
        >
          All ({tasks.length})
        </button>
        <button
          className={`filter-btn ${filter === 'pending' ? 'active' : ''}`}
          onClick={() => setFilter('pending')}
        >
          Pending ({stats.pending})
        </button>
        <button
          className={`filter-btn ${filter === 'approved' ? 'active' : ''}`}
          onClick={() => setFilter('approved')}
        >
          Approved ({stats.approved})
        </button>
        <button
          className={`filter-btn ${filter === 'rejected' ? 'active' : ''}`}
          onClick={() => setFilter('rejected')}
        >
          Rejected ({stats.rejected})
        </button>
      </div>

      {error && (
        <div className="alert alert-error">
          <span>{error}</span>
        </div>
      )}

      {/* Task List */}
      {loading ? (
        <div className="loading">Loading tasks...</div>
      ) : filteredTasks.length === 0 ? (
        <div className="empty-state">
          <p>No tasks found</p>
        </div>
      ) : (
        <div className="task-list">
          {filteredTasks.map((task) => (
            <div key={task.id} className="task-card">
              <div className="task-header">
                <div className="task-badges">
                  <span className={`badge ${getStatusBadge(task.status).class}`}>
                    {getStatusBadge(task.status).text}
                  </span>
                  <span className="badge badge-category">
                    {getCategoryBadge(task.category)}
                  </span>
                </div>
                <div className="task-date">{formatDate(task.submitted_at)}</div>
              </div>

              <div className="task-body">
                <h3>{task.title}</h3>
                <p className="task-description">{task.description}</p>
                <div className="task-meta">
                  <span className="task-user">
                    👤 {task.user_name || 'Unknown'}
                  </span>
                  {task.user_email && (
                    <span className="task-email">
                      ✉️ {task.user_email}
                    </span>
                  )}
                </div>

                {task.reviewed_at && (
                  <div className="task-review-info">
                    <p><strong>Reviewed:</strong> {formatDate(task.reviewed_at)}</p>
                    {task.admin_notes && (
                      <p><strong>Notes:</strong> {task.admin_notes}</p>
                    )}
                  </div>
                )}
              </div>

              {task.status === 'pending' && (
                <div className="task-actions">
                  <button
                    className="btn btn-view"
                    onClick={() => setSelectedTask(task)}
                  >
                    Review Task
                  </button>
                </div>
              )}
            </div>
          ))}
        </div>
      )}

      {/* Review Modal */}
      {selectedTask && (
        <div className="modal-overlay" onClick={() => setSelectedTask(null)}>
          <div className="modal-content" onClick={(e) => e.stopPropagation()}>
            <div className="modal-header">
              <h2>Review Task</h2>
              <button
                className="modal-close"
                onClick={() => setSelectedTask(null)}
              >
                ✕
              </button>
            </div>

            <div className="modal-body">
              <div className="review-task-details">
                <h3>{selectedTask.title}</h3>
                <p><strong>Category:</strong> {getCategoryBadge(selectedTask.category)}</p>
                <p><strong>Submitted by:</strong> {selectedTask.user_name}</p>
                <p><strong>Date:</strong> {formatDate(selectedTask.submitted_at)}</p>
                <div className="review-description">
                  <strong>Description:</strong>
                  <p>{selectedTask.description}</p>
                </div>
              </div>

              <div className="review-notes">
                <label htmlFor="reviewNote">Admin Notes (Optional)</label>
                <textarea
                  id="reviewNote"
                  value={reviewNote}
                  onChange={(e) => setReviewNote(e.target.value)}
                  placeholder="Add notes about your decision..."
                  rows={4}
                />
              </div>
            </div>

            <div className="modal-actions">
              <button
                className="btn btn-reject"
                onClick={() => handleReview(selectedTask.id, 'rejected')}
                disabled={reviewLoading}
              >
                {reviewLoading ? 'Processing...' : 'Reject'}
              </button>
              <button
                className="btn btn-approve"
                onClick={() => handleReview(selectedTask.id, 'approved')}
                disabled={reviewLoading}
              >
                {reviewLoading ? 'Processing...' : 'Approve'}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default AdminTaskManager;
