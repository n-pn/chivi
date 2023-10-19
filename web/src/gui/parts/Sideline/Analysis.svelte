<script context="module" lang="ts">
  let stats = { mt_ai: 2 }
  import type { Rdpage, Rdline } from '$lib/reader'
</script>

<script lang="ts">
  import SIcon from '$gui/atoms/SIcon.svelte'
  import Wpanel from '$gui/molds/Wpanel.svelte'

  export let rpage: Rdpage
  export let rline: Rdline

  const reload_ctree = async () => {
    rpage = await rpage.load_mt_ai(2)
  }
</script>

<Wpanel
  title="Cây ngữ pháp:"
  bind:state={stats.mt_ai}
  class="_ct"
  lines={15}
  wdata={rline.ctree_text}>
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
  {#if rline.mt_ai}
    {@html rline.ctree_html}
  {:else}
    <p class="blank">Chưa có cây ngữ pháp</p>
  {/if}
</Wpanel>
