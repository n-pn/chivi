<script>
  import { get_rtime } from '$atoms/RTime.svelte'
  import { hint } from './_shared'

  import SIcon from '$atoms/SIcon.svelte'

  export let term
  export let p_min

  function render_time(mtime) {
    return get_rtime(mtime * 60 + 1577836800)
  }
</script>

<div class="emend">
  <div class="group" use:hint={'Quyền hạn tối thiểu để thêm/sửa nghĩa của từ'}>
    <SIcon name="lock" />
    <span class="lbl">Q. hạn:</span>
    <span class="val">{p_min}</span>
  </div>

  <div class="group" use:hint={'Lịch sử thêm/sửa dữ liệu từ điển cộng đồng'}>
    <SIcon name="users" />

    {#if term._base.mtime > 0}
      <span class="lbl">{term._base.state}:</span>
      <span class="val">{render_time(term._base.mtime)}</span>
      <span class>bởi</span>
      <span class="val user">{term._base.uname}</span>
    {:else}
      <span>Chưa có lịch sử</span>
    {/if}
  </div>

  <div class="group" use:hint={'Lịch sử thêm/sửa của từ điển cá nhân bạn'}>
    <SIcon name="user" />

    {#if term._priv.mtime > 0}
      <span>{term._priv.state}:</span>
      <span class="val">{render_time(term._priv.mtime)}</span>
    {:else}
      <span>Chưa có lịch sử</span>
    {/if}
  </div>
</div>

<style lang="scss">
  .emend {
    @include flex($center: horz, $gap: 0.2rem);
    padding: 0.25rem 0;
    line-height: 1.25rem;
    @include ftsize(xs);
    @include fgcolor(tert);

    :global(svg) {
      margin-right: -0.125rem;
    }
  }

  .group {
    @include flex($center: vert, $gap: 0.2rem);
    // prettier-ignore
    & + &:before { content: '|'; }
  }

  .lbl {
    @include bps(display, none, $sm: inline);
  }

  .val {
    font-weight: 500;
  }

  .user {
    @include clamp(5vw);
  }
</style>
