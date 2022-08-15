<script lang="ts">
  import { get_rtime } from '$gui/atoms/RTime.svelte'
  import { hint } from './_shared'
  import SIcon from '$gui/atoms/SIcon.svelte'

  import type { VpTerm } from '$lib/vp_term'
  export let vpterm: VpTerm

  const save_modes = ['(Cộng đồng)', '(Lưu nháp)', '(Riêng bạn)']
</script>

<div class="emend">
  <div class="group">
    {#if vpterm.init.mtime > 0}
      <span>{vpterm.init.state}:</span>
      <span class="val">{get_rtime(vpterm.init.mtime)}</span>
      <span>bởi</span>
      <span class="val user">@{vpterm.init.uname}</span>
      <span>{save_modes[vpterm.init._mode]}</span>
    {:else}
      <span>Chưa có lịch sử</span>
    {/if}
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
