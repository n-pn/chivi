<script lang="ts">
  import { session } from '$app/stores'
  import SIcon from '$gui/atoms/SIcon.svelte'

  export let chmeta: CV.Chmeta

  export let min_privi: number
  export let chidx_max: number
</script>

<div class="notext">
  {#if min_privi > $session.privi}
    <h1>Bạn không đủ quyền hạn để xem chương.</h1>
    {#if $session.privi < 0}
      <p class="warn">
        <em
          >Bạn chưa đăng nhập, hãy bấm biểu tượng <SIcon name="user" /> bên phải
          màn hình để đăng nhập hoặc đăng ký tài khoản mới.</em>
      </p>
    {:else}
      <p>Nâng cấp quyền hạn của bạn ngay hôm nay để mở khoá các tính năng.</p>
    {/if}

    <ul>
      <li>
        Với nguồn <x-seed>union</x-seed> (<SIcon name="share" />), bạn cần phải
        đăng nhập để xem các chương từ <x-chap>#{chidx_max + 1}</x-chap>.
      </li>
      <li>
        Với các nguồn dạng lưu trữ (ký hiệu <SIcon name="archive" />, <SIcon
          name="cloud-off" />) như <x-seed>zxcs_me</x-seed> hay
        <x-seed>users</x-seed>, bạn cần đăng nhập để xem các chương từ
        <x-chap>#1</x-chap>
        tới <x-chap>#{chidx_max}</x-chap>, và cần quyền hạn tối thiểu là
        <x-bold>1</x-bold>
        để xem các chương từ <x-chap>#{chidx_max + 1}</x-chap> trở đi.
      </li>

      <li>
        Với các nguồn truyện ngoài hiện còn đang sống (ký hiệu <SIcon
          name="cloud" />), bạn cần quyền hạn tối thiểu là <x-bold>1</x-bold>
        xem các chương từ
        <x-chap>#1</x-chap>
        tới <x-chap>#{chidx_max}</x-chap>, và cần quyền hạn tối thiểu là
        <x-bold>2</x-bold>
        để xem các chương từ <x-chap>#{chidx_max + 1}</x-chap> trở đi.
        <p>
          <em
            >* Với các chương tiết đã được lưu tạm trên hệ thống (có biểu tượng <SIcon
              name="cloud-download" />), tạm thời áp dụng các quy tắc tương tự
            các nguồn dạng lưu trữ.
          </em>
        </p>
      </li>
    </ul>

    <p>
      <strong
        >Con số đặc biệt <x-chap>{chidx_max}</x-chap> được tính bằng tổng số chương
        của nguồn truyện chia cho 3, và luôn lớn hơn 40.</strong>
    </p>
  {:else}
    <h1>Chương tiết không có nội dung.</h1>

    {#if chmeta.sname == 'users'}
      <p>
        Nguồn <x-seed>users</x-seed> được cung cấp bởi người dùng của Chivi.
      </p>
      <p>
        Liên hệ với các bạn có quyền hạn từ 2 trở lên để khắc phục chương thiếu.
      </p>
    {:else if chmeta.sname == 'zxcs_me'}
      <p>
        Nguồn <x-seed>zxcs.me</x-seed> được tải thủ công từ trang
        <a href="http://www.zxcs.me/" rel="noopener noferrer">zxcs.me</a><br />
        Không có nội dung nghĩa là có lỗi hệ thống. Hãy liên hệ ban quản trị.
      </p>
    {:else if chmeta.sname == 'shubaow'}
      <p>
        Nguồn <x-seed>shubaow</x-seed> không cho phép các IP server truy cập.
      </p>
      <p>
        Liên hệ với ban quản trị nếu bạn thực sự muốn đọc truyện từ nguồn này.
      </p>
    {:else}
      <p>
        Bạn có quyền xem chương tiết từ nguồn này, nhưng vì lý do nào đó chương
        tiết bị lỗi.
      </p>
      <p>
        Hãy kiểm tra từ <a href={chmeta.clink} rel="noopener noferrer"
          >trang gốc</a> xem có phải vấn đề từ bên đó hay không.
      </p>
      <p>
        Nếu vấn đề thuộc về bên Chivi, hãy liên hệ với ban quản trị để khắc
        phục.
      </p>
    {/if}
  {/if}
</div>

<style lang="scss">
  .notext {
    margin: 1rem auto;
    max-width: 40rem;
    min-height: 30vh;

    // @include flex($center: both);
    @include fgcolor(secd);

    h1 {
      // font-weight: 500;
      @include ftsize(x4);
      text-align: center;
      margin-bottom: 2rem;
      @include fgcolor(secd);
    }

    strong {
      font-weight: 500;
    }

    :global(svg) {
      margin-bottom: 0.2em;
    }
  }

  a {
    @include fgcolor(primary, 5);
    &:hover {
      text-decoration: underline;
    }
  }

  .warn {
    @include fgcolor(warning, 5);
    margin-bottom: 1.5rem;
    font-weight: 500;
  }

  x-seed {
    display: inline-block;
    text-transform: uppercase;
    font-weight: 500;
    padding: 0.25em 0.5em;
    font-size: em(12, 16);
    line-height: 1em;
    @include fgcolor(primary, 5);
    // @include bgcolor(primary, 5, 1);
    @include border(primary, 5);
    @include bdradi();
  }

  x-chap {
    @include fgcolor(primary, 5);
    font-weight: 500;
  }

  x-bold {
    @include fgcolor(main);
    font-weight: 500;
  }
</style>
