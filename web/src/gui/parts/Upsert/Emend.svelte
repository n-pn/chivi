<script lang="ts">
  import { get_rtime } from '$gui/atoms/RTime.svelte'
  import { hint } from './_shared'
  import SIcon from '$gui/atoms/SIcon.svelte'

  import type { VpTerm } from '$lib/vp_term'
  export let vpterm: VpTerm

  function render_time(mtime: number) {
    return get_rtime(mtime * 60 + 1577836800)
  }
</script>

<div class="emend">
  <div class="group">
    <span class="entry" use:hint={'Lịch sử thêm/sửa của từ điển cá nhân bạn'}>
      <SIcon name="user" />

      {#if vpterm.init.u_mtime > 0}
        <span>{vpterm.init.u_state}:</span>
        <span class="val">{render_time(vpterm.init.u_mtime)}</span>
      {:else}
        <span>Chưa có lịch sử</span>
      {/if}
    </span>
  </div>

  <div class="group">
    <span class="entry" use:hint={'Lịch sử thêm/sửa dữ liệu từ điển cộng đồng'}>
      <SIcon name="share" />

      {#if vpterm.init.b_mtime > 0}
        <span>{vpterm.init.b_state}:</span>
        <span class="val">{render_time(vpterm.init.b_mtime)}</span>
        <span>bởi</span>
        <span class="val user">{vpterm.init.b_uname}</span>
      {:else}
        <span>Chưa có lịch sử</span>
      {/if}
    </span>
  </div>
</div>

<style lang="scss">
  .emend {
    @include flex($center: horz, $gap: 0.2rem);

    line-height: 1.5rem;
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
