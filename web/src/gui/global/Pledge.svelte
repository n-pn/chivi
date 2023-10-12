<script lang="ts">
  import { page } from '$app/stores'
  import { get_user } from '$lib/stores'

  const _user = get_user()

  $: route_id = $page.route?.id || ''
</script>

{#if !route_id.includes('_auth')}
  <div class="app-vessel">
    <p class="pledge">
      <em class="em">
        Trang web làm lại, nếu gặp lỗi làm ơn liên hệ trực tiếp qua
        <a
          class="m-link"
          target="_blank"
          href="https://www.facebook.com/chivi.fb">Facebook</a>
        hoặc
        <a class="m-link" target="_blank" href="https://discord.gg/mdC3KQH"
          >Discord</a
        >.
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

  .em {
    @include fgcolor(warning, 5);
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
