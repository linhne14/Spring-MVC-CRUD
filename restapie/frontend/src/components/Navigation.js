import React from 'react';

function Navigation({ role, onLogout }) {
  return (
    <nav>
      <a href="/blogs">Blog</a>
      {role === 'ADMIN' && <a href="/users">User</a>}
      <button onClick={onLogout}>Đăng xuất</button>
    </nav>
  );
}

export default Navigation;

