<script>
  import { page } from '$app/stores'

  $: privi = $page.data._user?.privi || -1
</script>

<div class="app-vessel">
  {#if privi < 0}
    <a class="pledge" href="/_u/login">
      <strong class="u-warn">
        Bạn chưa đăng nhập, bấm vào đây để đăng nhập hoặc đăng ký tài khoản mới.
      </strong>
    </a>
  {:else}
    <a class="pledge" href="/me/event/li-xi">
      <em>
        Bấm vào đây để nhận lì xì mừng năm mới. Chương trình sẽ kéo dài tới hết ngày mồng 3 tết Âm
        lịch.
      </em>

      <strong class="u-warn">
        THÔNG BÁO: Do sai sót cho nên thời hạn kết thúc chương trình lại thành 14 giờ chiều mồng 1.
        Đã sửa lại, các bạn chưa nhận lì xì hãy thử lại!
      </strong>
    </a>
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
