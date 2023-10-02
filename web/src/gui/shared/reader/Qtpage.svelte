<script context="module" lang="ts">
  const descs = {
    avail: 'Trộn kết quả dịch thủ công với kết quả dịch thô có sẵn',
    qt_v1: 'Trộn kết quả dịch thủ công với kết quả dịch của máy dịch cũ',
    bt_zv: 'Trộn kết quả dịch thủ công với kết quả dịch từ Bing Translator',
    mt_ai: 'Trộn kết quả dịch thủ công với kết quả dịch máy bằng AI',
  }

  const modes = {
    qt_v1: 'Dịch máy cũ',
    bt_zv: 'Dịch bằng Bing',
    mt_ai: 'Dịch máy mới',
  }

  import { data as lookup_data } from '$lib/stores/lookup_stores'

  import { qtran_file } from '$utils/tran_util'
</script>

<script lang="ts">
  import { browser } from '$app/environment'
  import type { Pager } from '$lib/pager'
  import Switch from './Switch.svelte'
  import Status from './Status.svelte'
  import SIcon from '$gui/atoms/SIcon.svelte'

  export let pager: Pager
  export let rdata: CV.Chpart
  export let xargs: CV.Chopts
  export let label = ''
  export let dirty = true

  let vtran: CV.Qtdata = { lines: [], mtime: 0, tspan: 0 }

  $: if (dirty && browser && xargs) load_data(xargs)

  async function load_data(xargs: CV.Chopts, rinit: RequestInit = {}) {
    dirty = false
    vtran = { lines: [], mtime: 0, tspan: 0 }

    vtran = await qtran_file(xargs, true, rinit)

    if (vtran.error) return
    lookup_data.update((x) => ({ ...x, [xargs.rmode]: vtran.lines }))
  }

  $: [title, ...paras] = vtran?.lines || []
</script>

<Switch {pager} {modes} {descs} {xargs} bind:dirty />

{#if vtran.error}
  <h1>Lỗi hệ thống:</h1>
  <p>{vtran.error || 'Không rõ lỗi mời liên hệ ban quản trị!'}</p>
{:else if title}
  <h1 id="L0" class="cdata" data-line="0">{title} {label}</h1>

  {#each paras as para, _idx}
    <p id="L{_idx + 1}" class="cdata" data-line={_idx + 1}>{para}</p>
  {/each}
{:else}
  <div class="empty">
    <SIcon name="rotate" spin={true} />
    <p>Đang tải nội dung!</p>
  </div>
{/if}

<style lang="scss">
  .empty {
    @include flex-ca($gap: 0.25rem);
    height: 50vh;
    @include fgcolor(mute);
    font-style: italic;
  }
</style>
