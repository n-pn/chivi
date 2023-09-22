<script lang="ts">
  import { page } from '$app/stores'
  import { get_user } from '$lib/stores'

  const _user = get_user()

  $: route_id = $page.route?.id || ''
</script>

{#if !route_id.includes('_auth')}
  <div class="app-vessel">
    <p class="pledge">
      <strong>
        Trang web đang đập đi làm lại, bắt đầu từ phần máy dịch. Trong quá trình
        này sẽ có rất nhiều lỗi, mong các bạn thông cảm. Có thắc mắc xin liên hệ
        Facebook của trang hoặc Discord (kéo xuống dưới cùng để xem liên kết).
      </strong>
      <br />
      <em>
        Cập nhật ngày 23/09/2023: Tính năng dịch bằng Bing + Dịch máy kiểu cũ đã
        mở trở lại. Các bạn bấm vào chỗ [Dịch tạm] để xem.
      </em>
    </p>
    {#if $_user.privi < 0}
      <a class="pledge" href="/_auth/signup">
        Đăng ký tài khoản <strong>Chivi</strong> ngay hôm nay để mở khoá các tính
        năng!
      </a>
    {:else if $_user.privi < 1}
      <a class="pledge" href="/hd/nang-cap-quyen-han">
        Nâng cấp quyền hạn để mở khoá các tính năng!
      </a>
    {/if}
  </div>
{/if}

<style lang="scss">
  .pledge {
    display: block;
    text-align: app-vessel;
    // max-width: 50vw;
    margin-top: 0.75rem;
    font-size: rem(15px);
    text-align: center;
    line-height: 1.25rem;

    padding: 0.5rem var(--gutter);

    @include fgcolor(tert);
    @include bgcolor(tert);

    @include bdradi();
  }

  a.pledge {
    &:hover {
      @include fgcolor(primary, 5);
    }

    // &._bold {
    //   font-weight: 500;
    //   font-size: rem(17px);
    //   padding: 0.75rem var(--gutter);
    //   @include fgcolor(warning, 5);

    //   &:hover {
    //     @include bgcolor(warning, 5, 1);
    //   }
    // }
  }
</style>
