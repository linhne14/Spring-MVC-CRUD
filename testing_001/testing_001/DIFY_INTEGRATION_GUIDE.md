# 🤖 Hướng Dẫn Tích Hợp Dify AI

## Bước 1: Lấy API Key từ Dify

1. Truy cập [Dify.ai](https://dify.ai)
2. Đăng nhập hoặc tạo tài khoản mới
3. Tạo một ứng dụng AI mới
4. Sao chép **API Key** từ phần cài đặt

## Bước 2: Cấu Hình API Key

Mở file `src/main/resources/application.properties` và thay thế:

```properties
dify.api-key=YOUR_DIFY_API_KEY_HERE
```

Thành:

```properties
dify.api-key=sk_live_xxxxxxxxxxxxxxxxxxxxx
```

Ví dụ:
```properties
dify.api-key=sk_live_abc123xyz789
dify.api-url=https://api.dify.ai/v1
```

## Bước 3: Build và Chạy Ứng Dụng

### Windows PowerShell:
```powershell
cd c:\Users\Admin\PTUDDN\testing_001\testing_001
./mvnw.cmd clean package
./mvnw.cmd spring-boot:run
```

Hoặc trong VS Code:
1. Nhấn `Ctrl + Shift + B` để build
2. Chạy Spring Boot app

## Bước 4: Sử Dụng AI Chat

1. Mở browser: `http://localhost:8080/`
2. Nhấn nút **"🤖 AI Chat"** (xanh lá cây)
3. Nhập câu hỏi của bạn
4. Nhận câu trả lời từ Dify AI

## 🎯 Các Tính Năng AI Được Cung Cấp

### 1. **Chat Tự Do**
- Hỏi bất cứ điều gì về khóa học
- Nhận gợi ý và hướng dẫn

### 2. **Gợi Ý Nhanh**
- Khóa học cho người mới
- Học lập trình
- Kỹ năng số

### 3. **API Endpoints**

#### POST `/api/ai/ask` - Hỏi AI
```json
{
  "question": "Hãy giới thiệu về Python",
  "conversationId": ""
}
```

**Phản hồi:**
```json
{
  "question": "Hãy giới thiệu về Python",
  "answer": "Python là...",
  "conversationId": ""
}
```

#### GET `/api/ai/course-suggestion` - Gợi ý khóa học
```
GET /api/ai/course-suggestion?courseName=Python%20Basics
```

**Phản hồi:**
```json
{
  "courseName": "Python Basics",
  "suggestion": "Python là một ngôn ngữ lập trình..."
}
```

#### GET `/api/ai/course-summary` - Tóm tắt khóa học
```
GET /api/ai/course-summary?courseName=Python&instructor=John
```

**Phản hồi:**
```json
{
  "courseName": "Python",
  "instructor": "John",
  "summary": "Khóa học về Python..."
}
```

## 📝 Các Files Được Tạo/Cập Nhật

### Mới Tạo:
- `src/main/java/com/example/testing_001/service/DifyAIService.java` - Service gọi API Dify
- `src/main/java/com/example/testing_001/controller/AIController.java` - REST API controller
- `src/main/resources/templates/ai_chat.html` - UI Chatbot AI

### Cập Nhật:
- `pom.xml` - Thêm dependencies (webflux, jackson)
- `application.properties` - Thêm cấu hình Dify
- `CourseController.java` - Thêm route `/ai`
- `index.html` - Thêm nút AI Chat

## 🔧 Troubleshooting

### Lỗi: "Không thể kết nối đến AI"
- ✓ Kiểm tra API key có đúng không
- ✓ Kiểm tra kết nối internet
- ✓ Kiểm tra URL API Dify

### Lỗi: "Invalid API Key"
- ✓ Lấy lại API key từ Dify
- ✓ Xóa khoảng trắng thừa
- ✓ Kiểm tra prefix `sk_live_`

### Không thấy phản hồi
- ✓ Chọn model AI đúng trong Dify
- ✓ Kiểm tra setting và prompt

## 🚀 Mở Rộng

Bạn có thể mở rộng bằng cách:

1. **Lưu Conversation History**
   - Tạo entity `Conversation`
   - Lưu messages vào database

2. **Thêm Loại AI Khác**
   - Chat về yêu cầu tuyển dụng
   - Đánh giá kỹ năng
   - Tạo plan học tập

3. **Tích Hợp Sinh viên**
   - Hỏi AI về tiến độ học
   - Nhận gợi ý cải thiện

Chúc bạn thành công! 🎉
