import React, { useState } from 'react';
import { UserAuth } from '../Auth/AuthContext';
import './TaskSubmission.css';

const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:5000';

const TaskSubmission = ({ onSuccess, onCancel }) => {
  const { session } = UserAuth();
  const [formData, setFormData] = useState({
    title: '',
    description: '',
    category: 'general',
  });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const [success, setSuccess] = useState(false);

  const categories = [
    { value: 'general', label: 'General' },
    { value: 'resume', label: 'Resume Review' },
    { value: 'interview', label: 'Interview Prep' },
    { value: 'internship', label: 'Internship Application' },
    { value: 'project', label: 'Project Submission' },
    { value: 'other', label: 'Other' },
  ];

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData((prev) => ({
      ...prev,
      [name]: value,
    }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError(null);
    setSuccess(false);

    if (!formData.title.trim() || !formData.description.trim()) {
      setError('Please fill in all required fields');
      setLoading(false);
      return;
    }

    try {
      const response = await fetch(`${API_BASE_URL}/api/tasks`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          user_id: session?.user?.id,
          user_email: session?.user?.email,
          user_name: session?.user?.user_metadata?.display_name || 'Unknown User',
          title: formData.title,
          description: formData.description,
          category: formData.category,
        }),
      });

      const data = await response.json();

      if (data.success) {
        setSuccess(true);
        setFormData({
          title: '',
          description: '',
          category: 'general',
        });

        // Call success callback if provided
        if (onSuccess) {
          setTimeout(() => onSuccess(data.task), 1500);
        }
      } else {
        setError(data.error || 'Failed to submit task');
      }
    } catch (err) {
      console.error('Error submitting task:', err);
      setError('Failed to submit task. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="task-submission-container">
      <div className="task-submission-card">
        <h2>Submit Task for Review</h2>
        <p className="task-submission-subtitle">
          Submit your work for admin review. You'll receive a notification once it's reviewed.
        </p>

        {success && (
          <div className="alert alert-success">
            <svg className="alert-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
            <span>Task submitted successfully! You'll be notified when it's reviewed.</span>
          </div>
        )}

        {error && (
          <div className="alert alert-error">
            <svg className="alert-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
            <span>{error}</span>
          </div>
        )}

        <form onSubmit={handleSubmit} className="task-submission-form">
          <div className="form-group">
            <label htmlFor="category">Category *</label>
            <select
              id="category"
              name="category"
              value={formData.category}
              onChange={handleChange}
              required
            >
              {categories.map((cat) => (
                <option key={cat.value} value={cat.value}>
                  {cat.label}
                </option>
              ))}
            </select>
          </div>

          <div className="form-group">
            <label htmlFor="title">Task Title *</label>
            <input
              type="text"
              id="title"
              name="title"
              value={formData.title}
              onChange={handleChange}
              placeholder="Brief description of your task"
              required
              maxLength={200}
            />
            <span className="char-count">{formData.title.length}/200</span>
          </div>

          <div className="form-group">
            <label htmlFor="description">Description *</label>
            <textarea
              id="description"
              name="description"
              value={formData.description}
              onChange={handleChange}
              placeholder="Provide detailed information about your task submission..."
              required
              rows={6}
              maxLength={1000}
            />
            <span className="char-count">{formData.description.length}/1000</span>
          </div>

          <div className="form-actions">
            {onCancel && (
              <button
                type="button"
                className="btn btn-secondary"
                onClick={onCancel}
                disabled={loading}
              >
                Cancel
              </button>
            )}
            <button
              type="submit"
              className="btn btn-primary"
              disabled={loading}
            >
              {loading ? 'Submitting...' : 'Submit Task'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

export default TaskSubmission;
