import React, { useState, useEffect } from 'react';
import axios from 'axios';
import './BlogManagement.css';

function BlogManagement() {
  const [blogs, setBlogs] = useState([]);
  const [title, setTitle] = useState('');
  const [content, setContent] = useState('');
  const [message, setMessage] = useState('');
  const token = localStorage.getItem('token');
  const role = localStorage.getItem('role');
  const username = localStorage.getItem('username');

  useEffect(() => {
    loadBlogs();
  }, []);

  const loadBlogs = async () => {
    try {
      const response = await axios.get('http://localhost:8080/api/blogs', {
        headers: { Authorization: `Bearer ${token}` }
      });
      setBlogs(response.data);
    } catch (error) {
      setMessage('Không thể tải danh sách blog');
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      await axios.post('http://localhost:8080/api/blogs',
        { title, content },
        { headers: { Authorization: `Bearer ${token}` }}
      );
      setMessage('Blog đã được tạo thành công!');
      setTitle('');
      setContent('');
      loadBlogs(); // Tải lại danh sách blog
    } catch (error) {
      setMessage('Không thể tạo blog');
    }
  };

  const handleDelete = async (id) => {
    try {
      await axios.delete(`http://localhost:8080/api/blogs/${id}`, {
        headers: { Authorization: `Bearer ${token}` }
      });
      loadBlogs(); // Tải lại danh sách blog
      setMessage('Blog đã được xóa');
    } catch (error) {
      setMessage('Không thể xóa blog');
    }
  };

  return (
    <div className="blog-container">
      <h2>Quản lý Blog</h2>

      <form onSubmit={handleSubmit} className="blog-form">
        <div className="form-group">
          <input
            type="text"
            value={title}
            onChange={e => setTitle(e.target.value)}
            placeholder="Tiêu đề blog"
            required
          />
        </div>
        <div className="form-group">
          <textarea
            value={content}
            onChange={e => setContent(e.target.value)}
            placeholder="Nội dung blog"
            required
          />
        </div>
        <button type="submit">Tạo Blog Mới</button>
      </form>

      {message && <div className="message">{message}</div>}

      <div className="blog-list">
        <h3>Danh sách Blog</h3>
        {blogs.map(blog => (
          <div key={blog.id} className="blog-item">
            <h4>{blog.title}</h4>
            <p>{blog.content}</p>
            <p className="blog-author">Tác giả: {blog.user?.username}</p>
            {(role === 'ADMIN' || blog.user?.username === username) && (
              <button onClick={() => handleDelete(blog.id)} className="delete-btn">
                Xóa
              </button>
            )}
          </div>
        ))}
      </div>
    </div>
  );
}

export default BlogManagement;
