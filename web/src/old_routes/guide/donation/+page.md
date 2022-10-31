---
title: Ủng hộ Chivi
---

Chivi hiện không sống bằng quảng cáo, tiền ủng hộ của các bạn là đầu vào duy nhất để nuôi sống trang web.

## Phương thức ủng hộ

<p class="em">
Lưu ý: Khi ủng hộ hãy để lại tên đăng nhập hoặc hòm thư đã đăng ký trên Chivi để định danh tài khoản.
</p>

### Quốc tế (ưu tiên)

- https://ko-fi.com/chivi
- https://www.paypal.com/paypalme/nipinium

### Việt Nam:

- Ví Momo: https://me.momo.vn/nipin
- Techcombank: **19034964108016**

Hoặc liên hệ qua các kênh liên lạc: [Facebook](https://www.facebook.com/chivi.app), [Discord](https://discord.gg/mdC3KQH).

Khi bạn ủng hộ Chivi bằng tiền mặt, bạn sẽ được tặng một đơn vị tiền tệ ảo là vcoin, bạn có thể dùng vcoin để nâng cấp quyền hạn, gửi tặng người dùng khác, hoặc sử dụng các tính năng nâng cao sẽ dần được phát triển bổ sung.

<p class="em">Quy ước trao đổi: 1000 VND = 1 vcoin, $1 USD = 20 vcoin.</p>

## Tại sao phải ủng hộ Chivi?

- Server của Chivi cần CPU + RAM khoẻ để phục vụ tính năng dịch truyện thời gian thực.
  Ngoài ra thì hiện tại trên server còn chạy khoảng 10 tác vụ ngầm để tải dữ liệu từ các nguồn text/nội dung từ yousuu. Mỗi tác vụ này đều tốn RAM/CPU để chạy và xử lý dữ liệu.

- Server của Chivi cần ổ SSD dung lượng cao để có thể chạy mượt

  - Hiện tại trên chivi có khoảng 100.000 bộ truyện, mỗi bộ truyện có thể không có nguồn text, cũng có thể có 10+ nguồn text.
    Dù chỉ lưu text gốc từ nguồn đầu tiên + các nguồn chết, thì cũng cần ít nhất 100 GB ổ cứng chỉ để lưu text gốc (đã nén) của truyện.
  - Ngoài text của truyện, trên Chivi còn lưu thông tin chương tiết, file html gốc của chương truyện, ảnh bìa các bộ truyện... đống này cũng chiếm khoảng 20~30 GB ổ cứng.

  - Một trong những killer feature của Chivi là đống dữ liệu lấy từ trang yousuu.com, gồm thông tin bộ truyện (đánh giá cho điểm), các bình luận truyện, phản hồi bình luận, thư đơn... Để phần này chạy trơn tru thì trên server cũng phải lưu hết dữ liệu tải về từ yousuu vào các file json. Đống này cũng khoảng trên dưới 10 GB.

  - Database: Hiện tại database của Chivi nặng khoảng 7GB (chủ yếu là dũ liệu yousuu). Cộng thêm một thư mục base_backup + một thư mục wal_log với tổng dung lượng khoảng gấp 3 dung lượng server phục vụ cho việc phục hồi khẩn cấp trong trường hợp lỗi.

  Hiện tại server của Chivi chỉ có 160 GB SSD, hoàn toàn không đủ dùng.
  Giải pháp tạm thời hiện giờ là lưu text gốc của một số nguồn cố định trên AWS S3, chỉ tải xuống khi cần. Vụ này giúp tiết kiệm được khoảng 50GB ổ cứng, nhưng tốn công duy trì và giảm trải nghiệm.

  Lý tưởng nhất là Chivi có một cái server khoẻ, dung lượng ổ cứng không phải nghĩ. Và để có được điều này thì cách duy nhất là các bạn ủng hộ Chivi bằng tiền mặt, vì Chivi không sống bằng quảng cáo.

- Chivi lấy text truyện từ nhiều nguồn, những nguồn này không ổn định và cần thiết thời gian để bảo dưỡng.
  Ví dụ: `5200.net` đổi tên thành `5200.tv`, `xbiquge.cc` đổi thành `xbiquge.so`, `69shu.com` đổi lại bố cục trang web, `jx.la` chết rồi phục sinh thành trang khác....

- Như nhiều bạn đã biết, Chivi đang nỗ lực phát triển cỗ máy dịch thuật thông minh hơn, hiện đại hơn so với các công cụ dịch thuần tuý text replacement (e.g QT).
  Để hoàn thiện máy dịch và để nó đem lại kết quả tốt cần rất nhiều thời gian công sức và nỗ lực.

  _Các công việc cần thiết liên quan tới máy dịch:_

  - Hoàn thiện các luật ngữ pháp cho máy dịch.
    Hiện tại còn có kha khá luật ngữ pháp còn sai hoặc chưa cho vào.

    Mỗi lần sửa máy dịch cần thiết thời gian tương đối dài để chạy thử + kiểm tra chất lượng, cho nên quá trình này tương đối chậm và tốn thời gian.

  - Thêm/sửa nghĩa của từ thông qua các nguồn tổng hợp (bản VietPhrase sưu tầm)
    Như nhiều bạn đã có kinh nghiệm, thì các nguồn ngoài này rất nhiều rác, chính tả sai, hán việt sai, thêm chú thích thừa...

  - Phân tích từ loại thông qua các công cụ NLP POS tagging như `pkuseg` hay `baidu-lac`.
    Vì các công cụ này dùng AI để phân tích từ loại, cho nên không chính xác tuyệt đối (cao nhất chỉ tầm 85%), phải tốn nhiều thời gian để loại bỏ thông tin nhiễu/rác.

  - Bổ sung các từ điển liên quan cần thiết như từ điển Hán Việt, phân loại dấu câu, cụm emoji...

  - Hàng tá công việc lặt vặt khác tốn thời gian

- Hoàn thiện tính năng về thư viện sách như đánh giá truyện, lập danh sách tiến cứ truyện, thảo luận nội dung truyện....

- Các công việc bảo dưỡng làm hàng ngày/hàng tuần như backup dữ liệu, crawl thông tin mới từ các nguồn như `yousuu.com`, `zxcs.me`, `hetushu.com`....

_TLDR_: Phát triển tính năng cho Chivi rất tốn kém về thời gian và tiền bạc. Chivi cần thiết sự ủng hộ của các bạn để tiếp tục tồn tại và phát triển.