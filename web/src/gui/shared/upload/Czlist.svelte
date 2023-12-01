<script lang="ts">
  import SIcon from '$gui/atoms/SIcon.svelte'
  import Dialog from '$gui/molds/Dialog.svelte'
  import Czcard from './Czcard.svelte'
  import type { Czdata } from './czdata'

  export let chaps: Czdata[]
  export let pg_no = 1

  export let actived = false

  $: start = (pg_no - 1) * 16
  $: pgmax = Math.floor((chaps.length - 1) / 16) + 1
  $: cpage = chaps.slice(start, start + 16)
</script>

<Dialog {actived} on_close={() => (actived = false)}>
  <svelte:fragment slot="header">
    Tổng {chaps.length} chương / {start + 1} - {start + 16}
  </svelte:fragment>
  <div class="chaps">
    {#each cpage as zdata, idx}
      <Czcard {zdata} index={start + idx + +1} />
    {/each}
  </div>

  {#if pgmax > 0}
    <footer class="pagi">
      <button
        class="m-btn _sm"
        data-kbd="←"
        disabled={pg_no < 2}
        on:click={() => (pg_no = pg_no - 1)}>
        <SIcon name="chevron-left" />
      </button>

      <button
        class="m-btn _sm"
        class:_primary={pg_no == 1}
        data-kbd="h"
        on:click={() => (pg_no = 1)}
        >1
      </button>

      <input
        type="number"
        class="m-input _sm"
        min={1}
        max={pgmax}
        bind:value={pg_no} />

      <button
        class="m-btn _sm"
        class:_primary={pg_no == pgmax}
        data-kbd="l"
        on:click={() => (pg_no = pgmax)}
        >{pgmax}
      </button>

      <button
        class="m-btn _sm _primary"
        data-kbd="→"
        disabled={pg_no >= pgmax}
        on:click={() => (pg_no = pg_no + 1)}>
        <SIcon name="chevron-right" />
      </button>
    </footer>
  {/if}
</Dialog>

<style lang="scss">
  .chaps {
    overflow-y: scroll;
    flex: 1;
    max-height: calc(100vh - 15rem);
    padding: 0.75rem;

    scrollbar-width: thin;
    &::-webkit-scrollbar {
      cursor: pointer;
      width: 8px;
    }
  }

  .pagi {
    @include flex-ca($gap: 0.5rem);
    margin: 0.5rem 0;

    input {
      text-align: center;
      width: 3.5rem;
    }
  }
</style>
