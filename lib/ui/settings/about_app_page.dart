import 'package:flutter/material.dart';

class AboutAppPage extends StatelessWidget {
  const AboutAppPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Giới thiệu ứng dụng',
          style: TextStyle(
            fontFamily: "SF Pro",
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.deepPurple, width: 1.5),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(16),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "GIỚI THIỆU ỨNG DỤNG APP MUSIC",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                  fontFamily: "SF Pro",
                ),
              ),
              SizedBox(height: 12),
              Text(
                "Được khai sinh vào ngày 3/9/2025, App Music là dịch vụ nghe nhạc miễn phí được phát triển bởi Phạm Như Sơn (ulrichpham). "
                    "Với nhiều tính năng hữu ích giúp người nghe luôn có trải nghiệm âm nhạc tuyệt vời và xuyên suốt trên các thiết bị của mình "
                    "(từ điện thoại, máy tính bảng đến Smart TV). App Music mang đến cho người yêu nhạc thư viện nhạc khổng lồ với hàng chục triệu bài hát "
                    "chất lượng cao có bản quyền đầy đủ tất cả các thể loại và được cập nhật liên tục nội dung mới nhất mỗi ngày.\n\n"
                    "Thành viên của App Music có thể tự tổ chức thư viện nhạc cá nhân cho riêng mình, upload và lưu trữ kho nhạc của mình ngay trên App Music "
                    "và tạo playlist để nghe và chia sẻ cho bạn bè rất dễ dàng.\n\n"
                    "App Music hiện đã có đầy đủ các phiên bản và ứng dụng dành cho các nền tảng mobile Android và Smart TV.\n\n"
                    "App Music là một sản phẩm của Mega do Phạm Như Sơn phát triển. Đây là phiên bản đầu tiên đang trong quá trình phát triển và thử nghiệm",
                style: TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  fontFamily: "SF Pro",
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
