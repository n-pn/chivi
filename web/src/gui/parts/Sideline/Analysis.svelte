<script context="module" lang="ts">
  let stats = { ctree: 2 }
  import type { Rdline } from '$lib/reader'
</script>

<script lang="ts">
  import SIcon from '$gui/atoms/SIcon.svelte'
  import Wpanel from '$gui/molds/Wpanel.svelte'

  export let rline: Rdline
  export let ropts: Partial<CV.Rdopts>
  const reload_ctree = async () => {
    alert('todo!')
  }
</script>

<Wpanel title="Cây ngữ pháp:" bind:state={stats.ctree} class="_ct" lines={15} wdata={'???'}>
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
  {#if rline.trans[ropts.mt_rm]}
    TODO!
  {:else}
    <p class="blank">Chưa có cây ngữ pháp</p>
  {/if}
</Wpanel>
