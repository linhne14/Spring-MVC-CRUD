import React from 'react';
import { BrowserRouter as Router, Routes, Route, Link, useNavigate } from 'react-router-dom';
import LoginForm from './components/LoginForm';
import RegisterForm from './components/RegisterForm';
import BlogManagement from './components/BlogManagement';
import UserManagement from './components/UserManagement';

function Navigation({ role }) {
  const navigate = useNavigate();
  const handleLogout = () => {
    localStorage.clear();
    navigate('/login');
  };
  return (
    <nav style={{marginBottom:20}}>
      <Link to="/" style={{marginRight:10}}>Trang chủ</Link>
      <Link to="/login" style={{marginRight:10}}>Đăng nhập</Link>
      <Link to="/register" style={{marginRight:10}}>Đăng ký</Link>
      <Link to="/blogs" style={{marginRight:10}}>Blog</Link>
      {role === 'ADMIN' && <Link to="/users" style={{marginRight:10}}>User</Link>}
      <button onClick={handleLogout}>Đăng xuất</button>
    </nav>
  );
}

function HomePage() {
  return (
    <div>
      <h1>Spring Boot REST API is running!</h1>
      <p>Chào mừng bạn đến với hệ thống quản lý Blog & User.</p>
      <p>Hãy sử dụng thanh menu phía trên để chuyển trang và thao tác.</p>
    </div>
  );
}

function App() {
  const role = localStorage.getItem('role'); // Lấy role từ localStorage sau khi đăng nhập

  return (
    <Router>
      <Navigation role={role} />
      <Routes>
        <Route path="/login" element={<LoginForm />} />
        <Route path="/register" element={<RegisterForm />} />
        <Route path="/blogs" element={<BlogManagement />} />
        <Route path="/users" element={<UserManagement />} />
        <Route path="/" element={<HomePage />} />
      </Routes>
    </Router>
  );
}

export default App;

