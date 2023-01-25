<script lang="ts">
  import { page } from '$app/stores'
  $: _privi = $page.data._user.privi

  $: route_id = $page.route?.id || ''
</script>

{#if !route_id.includes('_auth')}
  <div class="app-vessel">
    {#if _privi < 0}
      <div class="pledge">
        Đăng ký tài khoản <strong>Chivi</strong> ngay hôm nay để mở khoá các tính
        năng!
      </div>
    {:else if _privi < 2}
      <a class="pledge" href="/guide/donation">
        Ủng hộ <strong>Chivi</strong> để nâng cấp quyền hạn!
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
