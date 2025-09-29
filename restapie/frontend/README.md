# Frontend ReactJS cho REST API Spring Boot

## 1. Khởi tạo dự án ReactJS

Chạy lệnh sau trong thư mục `restapie`:
```
npx create-react-app frontend
```

## 2. Cài đặt axios
```
npm install axios
```

## 3. Chạy frontend
```
cd frontend
npm start
```

## 4. Cấu trúc giao diện
- Trang đăng nhập: `/login`
- Trang đăng ký: `/register`
- Trang quản lý user: `/users` (chỉ ADMIN)
- Trang quản lý blog: `/blogs`

## 5. Tích hợp API
- Sử dụng axios để gọi API backend tại `http://localhost:8080`
- Lưu JWT token vào localStorage
- Gửi token trong header `Authorization: Bearer <token>` khi gọi API

## 6. Phân quyền
- ADMIN: Quản lý user, blog
- USER: Quản lý blog của mình

## 7. Lưu ý
- Backend phải chạy tại `http://localhost:8080`
- Nếu cần hướng dẫn chi tiết hoặc code mẫu, liên hệ lại!

