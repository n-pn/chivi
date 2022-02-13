<script lang="ts">
  export let chmeta: CV.Chmeta

  const pleb_seeds = ['5200', 'bqg_5200', 'rengshu', 'noff']
  const lvl0_seeds = ['hetushu', 'biqubao', 'bxwxorg', 'xbiquge', '69shu']
  const lvl1_seeds = ['zhwenpg', 'paoshu8', 'duokan8']

  function render_seeds(seeds: string[]) {
    return seeds.map((x) => `<strong>${x}</strong>`).join(', ')
  }
</script>

<article class="notext cvdata m-article">
  <slot name="header" />
  <h1>Chương tiết không có nội dung.</h1>

  {#if chmeta.sname == 'chivi'}
    <p>
      Nguồn <strong>chivi</strong> được cung cấp bởi người dùng của chivi. Việc không
      có nội dung hiếm khi xảy ra.
    </p>
    <p>Mời liên hệ với ban quản trị để khắc phục.</p>
  {:else if chmeta.sname == 'zxcs_me'}
    <p>
      Nguồn <strong>zxcs.me</strong> được tải bằng tay từ trang
      <a href="http://www.zxcs.me/" rel="noopener noferrer">zxcs.me</a>
    </p>
    <p>Có lẽ đã xảy ra lỗi khi đăng tải truyện lên hệ thống.</p>
    <p>Mời liên hệ với ban quản trị để khắc phục</p>
  {:else if chmeta.sname == 'shubaow'}
    <p>
      Nguồn <strong>shubaow</strong> cấm việc tải chương truyện từ các máy chủ.
    </p>
    <p>
      Liên hệ với ban quản trị nếu bạn thực sự muốn đọc truyện từ nguồn này.
    </p>
    <p>Chúng tôi sẽ sắp xếp thời gian chạy công cụ để tải truyện từ máy bàn.</p>
  {:else if pleb_seeds.includes(chmeta.sname)}
    <p>
      Các nguồn {@html render_seeds(pleb_seeds)} về lý thuyết là được mở ra với tất
      cả mọi người.
    </p>
    <p>
      Hãy kiểm tra từ <a href={chmeta.clink} rel="noopener noferrer"
        >trang gốc</a> xem có phải vấn đề từ bên đó hay không.
    </p>
    <p>Hoặc liên hệ với ban quản trị để chúng tôi kiểm tra.</p>
  {:else if lvl0_seeds.includes(chmeta.sname)}
    <p>
      Các nguồn {@html render_seeds(lvl0_seeds)} yêu cầu bạn phải đăng nhập. Kiểm
      tra lại xem mình đã đăng nhập hay chưa.
    </p>
    <p>
      Nếu không phải do vấn đề đăng nhập, hãy kiểm tra từ <a
        href={chmeta.clink}
        rel="noopener noferrer"
        target="_blank">trang gốc</a> xem có phải vấn đề từ bên đó hay không.
    </p>
    <p>Nếu vẫn còn vấn đề, mời liên hệ với ban quản trị.</p>
    <p />
  {:else if lvl1_seeds.includes(chmeta.sname)}
    <p>
      Các nguồn {@html render_seeds(lvl0_seeds)} chỉ mở ra với các bạn donors.
    </p>
    <p>
      Hãy thử nâng cấp quyền hạn của mình bằng việc ủng hộ cho trang web <a
        href="/guide/donation">tại đây</a>
    </p>

    <p>
      Nếu bạn đã là power user mà vẫn gặp lỗi, hãy thử kiểm tra <a
        href={chmeta.clink}
        rel="noopener noferrer"
        target="_blank">trang gốc</a> xem có phải vấn đề từ đó không.
    </p>
    <p>Nếu vẫn còn vấn đề, mời liên hệ với ban quản trị.</p>
  {:else if chmeta.sname == 'jx_la'}
    <p>
      Trang <strong>jx_la</strong> đã thay đổi cấu trúc trang web, cấu trúc mới rất
      khó tải nội dung.
    </p>
    <p>
      Chivi hiện tại không tiếp tục hỗ trợ <strong>jx_la</strong> nữa, chỉ giữ lại
      chương tiết đã được lưu từ trước.
    </p>
    <p>Nếu không có nội dung chương, hãy đổi nguồn.</p>
  {/if}

  <p>
    <strong
      >Trang web hỗ trợ việc xem chương tiết từ nhiều nguồn, hãy thử thay đổi
      nguồn nếu có thể.</strong>
  </p>
  <p>
    <em>
      Lưu ý: Hiện nay thì mọi người đều xem được các chương tiết đã được lưu trữ
      trên server, nhưng điều này có thể thay đổi trong tương lai!
    </em>
  </p>
</article>

<style lang="scss">
  .notext {
    // height: calc(100vh - 10rem);
    margin: 1rem auto;
    max-width: 40rem;

    // font-style: italic;

    // @include flex($center: both);
    @include fgcolor(secd);

    h1 {
      // font-weight: 500;
      // @include ftsize(6);
      text-align: center;
      margin-bottom: 2rem;
      @include fgcolor(secd);
    }

    p {
      margin-top: 1rem;
    }

    strong {
      font-weight: 500;
    }
  }

  a {
    @include fgcolor(primary, 5);
    &:hover {
      text-decoration: underline;
    }
  }
</style>
