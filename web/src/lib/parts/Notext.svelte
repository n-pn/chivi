<script>
  export let chinfo = {}
</script>

<div class="notext">
  <h1>Chương tiết không có nội dung.</h1>
  <p>Một số khả năng:</p>
  <ul>
    <li>
      Javascript chưa được bật.
      <p>Hoặc là bạn đang xem nội dung trang web qua bên thứ ba.</p>
    </li>
    <li>
      Chưa có text tiếng trung trên server, phải tải từ các nguồn ngoài.
      <p>Việc này hiện nay có một số hạn chế nhất định:</p>
      <ul>
        <li>
          Các nguồn <strong>xbiquge</strong>, <strong>hetushu</strong> hay
          <strong>duokan8</strong> cần thiết bạn phải đăng nhập.
        </li>
        <li>
          Các nguồn <strong>zhwenpg</strong>, <strong>69shu</strong> hay
          <strong>paoshu8</strong> chỉ dành cho power users.
          <br />
          (Nguồn <strong>69shu</strong> hiện tại đang gặp lỗi.)
        </li>

        <li>
          Các nguồn <strong>shubaow</strong>, <strong>jx_la</strong> hiện nay không
          hoạt động.
        </li>
      </ul>
    </li>
  </ul>
  <p>
    <em>
      Lưu ý: Hiện nay thì mọi người đều xem được các chương tiết đã được lưu trữ
      trên server, nhưng điều này có thể thay đổi trong tương lai!
    </em>
  </p>
</div>

<style lang="scss">
  .notext {
    // height: calc(100vh - 10rem);
    margin: 3rem auto;
    max-width: 40rem;

    // font-style: italic;

    // @include flex($center: both);
    @include fgcolor(neutral, 7);

    h1 {
      font-weight: 500;
      @include ftsize(7);
      @include fgcolor(neutral, 7);
    }

    li {
      margin-top: 0.75rem;
      li {
        margin-top: 0rem;
      }
    }

    :global(ul) {
      margin-top: 0.5rem;
    }

    p {
      margin-top: 0.5rem;
    }

    strong {
      font-weight: 500;
    }
  }
</style>
