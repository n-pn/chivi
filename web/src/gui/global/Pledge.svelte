<script>
  import { get_user } from '$lib/stores'
  const _user = get_user()

  $: privi = $_user.privi
</script>

<div class="app-vessel">
  {#if $_user.quota < 0}
    <div class="pledge">
      <em class="u-warn">
        Bạn đã dùng hết hạn mức dịch thuật mỗi ngày. Chi tiết tham khảo
        <a class="m-link" href="/hd/gioi-han-ky-tu">tại đây</a>. Bạn có thể nâng hạn mức bằng
        <a class="m-link" href="/me/privi">tăng quyền hạn</a>
        hoặc <a class="m-link" href="/me/quota">đổi từ vcoin</a>.
      </em>
    </div>
  {/if}

  {#if privi < 0}
    <a class="pledge" href="/_u/login">
      <strong class="u-warn">
        Bạn chưa đăng nhập, bấm vào đây để đăng nhập hoặc đăng ký tài khoản mới.
      </strong>
    </a>
  {:else if privi == 1}
    <a class="pledge" href="/me/privi"> Nâng cấp quyền hạn để mở khóa các tính năng! </a>
  {/if}
</div>

<style lang="scss">
  .pledge {
    display: block;

    margin-top: 0.75rem;
    margin-bottom: 0.75rem;

    font-size: rem(15px);
    text-align: center;
    line-height: 1.25rem;

    padding: 0.5rem var(--gutter);

    @include fgcolor(tert);
    @include bgcolor(tert);

    @include bdradi();
  }
</style>
