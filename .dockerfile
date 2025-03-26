# Sử dụng Dart SDK chính thức
FROM dart:stable AS build

# Đặt thư mục làm việc trong container
WORKDIR /app

# Sao chép toàn bộ code vào container
COPY . .

# Biên dịch file Dart thành executable
RUN dart pub get
RUN dart compile exe server.dart -o server

# Giai đoạn chạy server
FROM debian:buster-slim AS runtime
WORKDIR /app
COPY --from=build /app/server /app/server

# Expose cổng WebSocket (8080)
EXPOSE 8080

# Chạy server khi container khởi động
CMD ["/app/server"]
