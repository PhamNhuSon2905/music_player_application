import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Thỏa thuận sử dụng',
          style: TextStyle(
            fontFamily: "SF Pro",
            fontSize: 22,
            fontWeight: FontWeight.bold,
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
            border: Border.all(color: Colors.red, width: 1.5),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(16),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "THỎA THUẬN CUNG CẤP VÀ SỬ DỤNG DỊCH VỤ MẠNG XÃ HỘI APP MUSIC",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                  fontFamily: "SF Pro",
                ),
              ),
              SizedBox(height: 8),
              Text(
                "(Cập nhật tháng 10/2025)",
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  fontFamily: "SF Pro",
                ),
              ),
              SizedBox(height: 20),
              Text(
                "1. Điều 1: Giải thích từ ngữ",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontFamily: "SF Pro",
                ),
              ),
              SizedBox(height: 6),
              Text(
                "App Music: là dịch vụ mạng xã hội do Công ty Cổ phần Tập đoàn Mega là chủ quản có thể truy cập qua website appmusicmega.vn, ứng dụng App Music hoặc bất kỳ cách truy cập khả dụng nào khác.\n\n"
                    "Thỏa Thuận: là thỏa thuận cung cấp và sử dụng dịch vụ mạng xã hội App Music, cùng với tất cả các bản sửa đổi, bổ sung, cập nhật.\n\n"
                    "Mega: là Công ty Cổ phần Tập đoàn Mega.\n\n"
                    "Thông Tin Cá Nhân: là thông tin gắn liền với việc xác định danh tính, nhân thân của cá nhân bao gồm tên, tuổi, địa chỉ, số chứng minh nhân dân, số điện thoại, địa chỉ thư điện tử, tài khoản ngân hàng của Người Sử Dụng và một số thông tin khác theo quy định của pháp luật.\n\n"
                    "Mega ID: là tài khoản để Người Sử Dụng đăng nhập, upload nội dung lên App Music và sử dụng các tính năng nâng cao khác.\n\n"
                    "Người Sử Dụng: là bên truy cập App Music không phụ thuộc có hay không có Mega ID.\n\n"
                    "Sở Hữu Trí Tuệ: là những sáng chế, cải tiến, thiết kế, quy trình, công thức, phương pháp, cơ sở dữ liệu, thông tin, bản vẽ, mã, chương trình máy tính, tác phẩm có bản quyền (hiện tại và tương lai), thiết kế mạch tích hợp bán dẫn, thương hiệu, nhãn hiệu (dù đã đăng ký hay chưa đăng ký), tên thương mại và bao bì thương phẩm.",
                style: TextStyle(fontSize: 14, fontFamily: "SF Pro"),
              ),
              SizedBox(height: 20),
              Text(
                "2. Điều 2: Nội dung dịch vụ",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontFamily: "SF Pro",
                ),
              ),
              SizedBox(height: 6),
              Text(
                "App Music là mạng xã hội chia sẻ thông tin về âm nhạc, cho phép nghe nhạc trực tuyến, xem video clip, music video (MV) bao gồm nhiều thể loại khác nhau và/hoặc những nội dung khác được Người Sử Dụng đăng tải.\n\n"
                    "Thông qua App Music, chủ thể bản quyền có thể đăng tải bài hát, video clip, MV chất lượng để truyền đạt tới Người Sử Dụng.\n\n"
                    "Người Sử Dụng có thể nghe trực tuyến hoặc tải về từ ứng dụng App Music được phát triển trên nền tảng di động.\n\n"
                    "App Music cho phép Người Sử Dụng trao đổi, thảo luận và phản hồi thông qua công cụ chat bằng kí tự chữ về những nội dung được cung cấp trên App Music.\n\n"
                    "Người Sử Dụng App Music có thể sử dụng dịch vụ trên Website hoặc/và các ứng dụng App Music phát triển trên thiết bị di động.\n\n"
                    "Thông qua App Music, Mega cung cấp dịch vụ quảng cáo trên Website và/hoặc ứng dụng App Music phát triển trên thiết bị di động.",
                style: TextStyle(fontSize: 14, fontFamily: "SF Pro"),
              ),
              SizedBox(height: 20),

              // ===== Điều 3 =====
              Text(
                "3. Điều 3: Chấp nhận điều khoản sử dụng và sửa đổi",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontFamily: "SF Pro",
                ),
              ),
              SizedBox(height: 6),
              Text(
                "Khi sử dụng Dịch vụ App Music, Người Sử Dụng mặc định phải đồng ý và tuân theo các điều khoản được quy định tại Thỏa Thuận này và quy định, quy chế mà App Music liên kết, tích hợp (nếu có) bao gồm nhưng không giới hạn Mega ID tại http://megachat.com/mega/dieukhoan/\n\n"
                    "Khi truy cập, sử dụng App Music bằng bất cứ phương tiện (máy tính, điện thoại, tivi, thiết bị kết nối internet) hoặc sử dụng ứng dụng App Music mà Mega phát triển thì Người Sử Dụng cũng phải tuân theo Quy chế này.\n\n"
                    "Để đáp ứng nhu cầu sử dụng của Người Sử Dụng, App Music không ngừng hoàn thiện và phát triển, vì vậy các điều khoản quy định tại Thỏa thuận này có thể được cập nhật, chỉnh sửa bất cứ lúc nào mà không cần thông báo trước tới Người Sử Dụng. App Music sẽ công bố rõ trên Website, diễn đàn về những thay đổi, bổ sung đó.\n\n"
                    "Trong trường hợp một hoặc một số điều khoản Quy chế này xung đột với quy định của pháp luật, điều khoản đó sẽ được chỉnh sửa cho phù hợp với quy định pháp luật hiện hành, và phần còn lại của Quy chế sử dụng vẫn giữ nguyên giá trị.",
                style: TextStyle(fontSize: 14, fontFamily: "SF Pro"),
              ),
              SizedBox(height: 20),
              Text(
                "4. Điều 4: Đăng ký tài khoản và sử dụng dịch vụ",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontFamily: "SF Pro",
                ),
              ),
              SizedBox(height: 6),
              Text(
                "Người Sử Dụng phải đủ năng lực hành vi dân sự và đủ 13 tuổi trở lên mới được phép đăng ký Mega ID và/hoặc sử dụng App Music.\n\n"
                    "Khách hàng sử dụng tài khoản Mega ID để truy cập App Music. Khách hàng cũng có thể đăng nhập App Music từ tài khoản liên kết mà App Music cho phép.\n\n"
                    "Một số tính năng của App Music yêu cầu Người Sử Dụng phải đăng ký, đăng nhập để sử dụng. Nếu Người Sử Dụng không đăng ký, đăng nhập thì chỉ sử dụng App Music với các tính năng thông thường.\n\n"
                    "Trên Website/ứng dụng App Music xuất hiện link website hoặc biểu tượng website khác, bạn không nên suy luận rằng App Music hoạt động, kiểm soát hoặc sở hữu những website này. Việc truy cập tới các trang khác có thể gặp rủi ro. Người Sử Dụng hoàn toàn chịu trách nhiệm rủi ro khi sử dụng website liên kết này. App Music không chịu trách nhiệm về nội dung của bất kỳ website hoặc điểm đến nào ngoài trang App Music.\n\n"
                    "App Music cho phép Người Sử Dụng cung cấp, chia sẻ video, clip thuộc các thể loại mà App Music định hướng. App Music sẽ thẩm tra sơ bộ về kỹ thuật và nội dung video, và như vậy nội dung có thể không được đăng tải lên ngay lập tức.\n\n"
                    "Bài viết đánh giá ý kiến của bạn là một phần dịch vụ App Music. Người Sử Dụng phải đảm bảo bài viết, đánh giá của mình phù hợp với giới hạn ngôn từ và nội dung.",
                style: TextStyle(fontSize: 14, fontFamily: "SF Pro"),
              ),
              SizedBox(height: 20),
              Text(
                "5. Điều 5: Các nội dung cấm trao đổi và chia sẻ trên mạng xã hội",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontFamily: "SF Pro",
                ),
              ),
              SizedBox(height: 6),
              Text(
                "Khi sử dụng sản phẩm App Music, nghiêm cấm khách hàng một số hành vi bao gồm nhưng không giới hạn sau:\n\n"
                    "• Lợi dụng việc cung cấp, trao đổi, sử dụng thông tin trên App Music nhằm mục đích chống lại Nhà nước Cộng hoà xã hội chủ nghĩa Việt Nam; gây phương hại đến an ninh quốc gia, trật tự, an toàn xã hội; phá hoại khối đại đoàn kết toàn dân; tuyên truyền chiến tranh xâm lược, khủng bố; gây hận thù, mâu thuẫn giữa các dân tộc, sắc tộc, tôn giáo.\n\n"
                    "• Tuyên truyền, kích động bạo lực, dâm ô, đồi trụy, tệ nạn xã hội, mê tín dị đoan, phá hoại thuần phong mỹ tục của dân tộc.\n\n"
                    "• Tuyệt đối không bàn luận, đăng tải các nội dung về các vấn đề chính trị.\n\n"
                    "• Người Sử Dụng lợi dụng việc sử dụng App Music nhằm tiết lộ bí mật nhà nước, bí mật quân sự, kinh tế, đối ngoại và những bí mật khác do pháp luật quy định.\n\n"
                    "• Quảng cáo, tuyên truyền, mua bán hàng hoá, dịch vụ bị cấm hoặc truyền bá tác phẩm bị cấm trên App Music.\n\n"
                    "• Khi giao tiếp với người dùng khác, Người Sử Dụng quấy rối, chửi bới, làm phiền hoặc có hành vi thiếu văn hoá.\n\n"
                    "• Người Sử Dụng có quyền sử dụng đối với hình ảnh của mình. Khi sử dụng hình ảnh cá nhân khác phải được sự đồng ý của cá nhân đó.\n\n"
                    "• Lợi dụng mạng xã hội App Music để thu thập, công bố thông tin về đời tư của Người Sử Dụng khác.\n\n"
                    "• Đặt tài khoản theo tên của danh nhân, lãnh đạo Đảng và Nhà nước, tổ chức phản động hoặc tài khoản có ý nghĩa không lành mạnh.\n\n"
                    "• Đưa thông tin xuyên tạc, vu khống, nhạo báng, xúc phạm tổ chức, cá nhân dưới bất kỳ hình thức nào.\n\n"
                    "• Nghiêm cấm quảng bá sản phẩm dưới bất kỳ hình thức nào, bao gồm gửi thông điệp quảng cáo, mời gọi, thư dây chuyền, cơ hội đầu tư mà không được phép.\n\n"
                    "• Lợi dụng App Music để tổ chức các hình thức cá cược, cờ bạc, hoặc các thỏa thuận liên quan đến tiền, hiện kim, hiện vật.\n\n"
                    "• Cản trở, phá hoại hệ thống máy chủ; cản trở việc truy cập thông tin hợp pháp trên App Music.\n\n"
                    "• Sử dụng trái phép mật khẩu, khóa mã của tổ chức, cá nhân, thông tin riêng tư và tài nguyên Internet.\n\n"
                    "• Sao chép, tải về, nhân bản, phân phối hoặc truyền tải nội dung App Music mà không được phép.\n\n"
                    "• Giả mạo tổ chức, cá nhân, phát tán thông tin giả mạo hoặc sai sự thật gây hại đến quyền, lợi ích hợp pháp của người khác.\n\n"
                    "• Cài đặt, phát tán phần mềm độc hại, virus, hoặc công cụ tấn công trên Internet.\n\n"
                    "• Tuyệt đối không sử dụng chương trình, công cụ, hay hình thức nào khác để can thiệp vào App Music.\n\n"
                    "• Nghiêm cấm mọi hành vi xâm phạm sản phẩm, tài sản và uy tín của Mega.",
                style: TextStyle(fontSize: 14, fontFamily: "SF Pro"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
