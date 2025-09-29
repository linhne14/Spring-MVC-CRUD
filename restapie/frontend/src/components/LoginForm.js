import React, { useState } from 'react';
import axios from 'axios';
import { useNavigate } from 'react-router-dom';
import './LoginForm.css';

function LoginForm() {
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const navigate = useNavigate();

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      const loginRes = await axios.post('http://localhost:8080/api/auth/login', { username, password });
      const token = loginRes.data.token;
      localStorage.setItem('token', token);

      // Lấy thông tin user (bao gồm role)
      const userRes = await axios.get('http://localhost:8080/api/auth/me', {
        headers: { Authorization: `Bearer ${token}` }
      });

      localStorage.setItem('role', userRes.data.role);
      localStorage.setItem('username', userRes.data.username);

      // Chuyển đến trang blogs sau khi đăng nhập thành công
      navigate('/blogs');
      window.location.reload(); // Reload để cập nhật navigation
    } catch (err) {
      setError('Sai tài khoản hoặc mật khẩu!');
    }
  };

  return (
    <div className="login-container">
      <form onSubmit={handleSubmit} className="login-form">
        <h2>Đăng nhập</h2>
        <div className="form-group">
          <input
            type="text"
            value={username}
            onChange={e => setUsername(e.target.value)}
            placeholder="Username"
            required
          />
        </div>
        <div className="form-group">
          <input
            type="password"
            value={password}
            onChange={e => setPassword(e.target.value)}
            placeholder="Password"
            required
          />
        </div>
        <button type="submit">Đăng nhập</button>
        {error && <div className="error-message">{error}</div>}
      </form>
    </div>
  );
}

export default LoginForm;
