<script>
  import { get_rtime } from '$atoms/RTime.svelte'
  import { hint } from './_shared'
  import SIcon from '$atoms/SIcon.svelte'

  export let vpterm

  function render_time(mtime) {
    return get_rtime(mtime * 60 + 1577836800)
  }
</script>

<div class="emend">
  <div class="group">
    <span class="entry" use:hint={'Lịch sử thêm/sửa của từ điển cá nhân bạn'}>
      <SIcon name="user" />

      {#if vpterm.u_mtime > 0}
        <span>{vpterm.u_state}:</span>
        <span class="val">{render_time(vpterm.u_mtime)}</span>
      {:else}
        <span>Chưa có lịch sử</span>
      {/if}
    </span>
  </div>

  <div class="group">
    <span class="entry" use:hint={'Lịch sử thêm/sửa dữ liệu từ điển cộng đồng'}>
      <SIcon name="share" />

      {#if vpterm.b_mtime > 0}
        <span>{vpterm.b_state}:</span>
        <span class="val">{render_time(vpterm.b_mtime)}</span>
        <span class>bởi</span>
        <span class="val user">{vpterm.b_uname}</span>
      {:else}
        <span>Chưa có lịch sử</span>
      {/if}
    </span>
  </div>
</div>

<style lang="scss">
  .emend {
    @include flex($center: horz, $gap: 0.2rem);

    line-height: 1.25rem;
    @include ftsize(xs);
    @include fgcolor(tert);
  }

  .group {
    @include flex($center: vert, $gap: 0.2rem);
    // prettier-ignore
    & + &:before { content: '|'; }
  }

  .entry {
    @include flex($center: vert, $gap: 0.2rem);
    padding: 0.25rem 0;
    @include clamp();
  }

  .val {
    font-weight: 500;
  }

  .user {
    @include clamp(5vw);
  }
</style>
