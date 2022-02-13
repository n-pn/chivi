<script>
  import { session } from '$app/stores'
</script>

{#if $session.privi < 0}
  <div class="pledge">
    Protip: Đăng ký tài khoản <strong>Chivi</strong> ngay hôm nay để mở khoá các
    tính năng!
  </div>
{:else if $session.privi < 2}
  <a class="pledge" href="/guide/donation">
    Ủng hộ <strong>Chivi</strong> để nâng cấp quyền hạn!
  </a>
{/if}

<style lang="scss">
  .pledge {
    display: block;
    text-align: vessel;
    margin: 0.75rem var(--gutter);
    // max-width: 50vw;
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
  }
</style>
