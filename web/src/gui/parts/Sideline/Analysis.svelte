<script context="module" lang="ts">
  let stats = { ctree: 2 }
  import type { Rdpage, Rdline } from '$lib/reader'
</script>

<script lang="ts">
  import SIcon from '$gui/atoms/SIcon.svelte'
  import Wpanel from '$gui/molds/Wpanel.svelte'

  export let rline: Rdline
  export let ropts: Partial<CV.Rdopts>
  const reload_ctree = async () => {
    await rline.load_mtran(2, ropts.mt_rm)
  }
</script>

<Wpanel
  title="Cây ngữ pháp:"
  bind:state={stats.ctree}
  class="_ct"
  lines={15}
  wdata={rline.ctree_text(ropts.mt_rm)}>
  <svelte:fragment slot="tools">
    <button
      type="button"
      class="-btn"
      on:click={reload_ctree}
      data-tip="Dịch lại sau khi đã thay đổi nghĩa của từ"
      data-tip-loc="bottom"
      data-tip-pos="right">
      <SIcon name="refresh-dot" />
    </button>
  </svelte:fragment>
  {#if rline.mtran[ropts.mt_rm]}
    {@html rline.ctree_html(ropts.mt_rm)}
  {:else}
    <p class="blank">Chưa có cây ngữ pháp</p>
  {/if}
</Wpanel>
