import React, { useState, useEffect } from 'react';
import axios from 'axios';
import './UserManagement.css';

function UserManagement() {
  const [users, setUsers] = useState([]);
  const [message, setMessage] = useState('');
  const token = localStorage.getItem('token');
  const currentUsername = localStorage.getItem('username');

  useEffect(() => {
    loadUsers();
  }, []);

  const loadUsers = async () => {
    try {
      const response = await axios.get('http://localhost:8080/api/users', {
        headers: { Authorization: `Bearer ${token}` }
      });
      setUsers(response.data);
    } catch (error) {
      setMessage('Không thể tải danh sách user');
    }
  };

  const handleDelete = async (id, username) => {
    // Không cho phép xóa chính mình
    if (username === currentUsername) {
      setMessage('Không thể xóa tài khoản của chính mình!');
      return;
    }

    try {
      await axios.delete(`http://localhost:8080/api/users/${id}`, {
        headers: { Authorization: `Bearer ${token}` }
      });
      loadUsers(); // Tải lại danh sách user
      setMessage('User đã được xóa');
    } catch (error) {
      setMessage('Không thể xóa user');
    }
  };

  return (
    <div className="user-container">
      <h2>Quản lý User</h2>

      {message && <div className="message">{message}</div>}

      <div className="user-list">
        <table>
          <thead>
            <tr>
              <th>Username</th>
              <th>Role</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {users.map(user => (
              <tr key={user.id}>
                <td>{user.username}</td>
                <td>{user.role}</td>
                <td>
                  {user.username !== currentUsername && (
                    <button
                      onClick={() => handleDelete(user.id, user.username)}
                      className="delete-btn"
                    >
                      Xóa
                    </button>
                  )}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}

export default UserManagement;
