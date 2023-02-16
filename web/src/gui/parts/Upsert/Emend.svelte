<script lang="ts">
  import { get_rtime } from '$gui/atoms/RTime.svelte'
  import type { VpForm } from './_shared'

  export let form: VpForm
  export let dicts: CV.VpDict[]

  const save_modes = ['Tự động', 'Chung', 'Nháp', 'Riêng']

  $: vdict = form.init.dic >= 0 ? dicts[0] : dicts[1]
  $: dname = vdict.vd_id > 0 ? `Truyện ${vdict.label}` : `Tất cả bộ truyện`
</script>

<div class="emend">
  {#if form.init.mtime > 0}
    <span>{form.init.state}:</span>
    <span class="bold">{get_rtime(form.init.mtime)}</span>
    <span>bởi</span>
    <span class="bold trim">@{form.init.uname}</span>
    <span>-</span>
    <span>Phạm vi:</span>
    <span class="bold trim">{dname}</span>
    <span>({save_modes[Math.abs(form.init.tab)]})</span>
  {:else}
    <span>Chưa có lịch sử</span>
  {/if}
</div>

<style lang="scss">
  .emend {
    @include flex($center: horz, $gap: 0.2rem);
    @include clamp();

    padding: 0.25rem 0;
    line-height: 1.5rem;
    @include ftsize(xs);
    @include fgcolor(tert);
  }

  .bold {
    font-weight: 500;
  }

  .trim {
    @include clamp(5vw);
  }
</style>
