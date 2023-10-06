<script lang="ts">
  import SIcon from '$gui/atoms/SIcon.svelte'
  import type { Zchap } from './text_split'

  export let chaps: Zchap[]
  export let pg_no = 1

  $: start = (pg_no - 1) * 32
  $: pgmax = Math.floor((chaps.length - 1) / 32) + 1
  $: cpage = chaps.slice(start, start + 32)
</script>

<div class="count">
  <em>
    Số chương kết quả theo cách chia: <strong>{chaps.length}</strong>
  </em>
</div>

<div class="chaps">
  {#each cpage as chap, idx}
    <div class="chap">
      <div class="chap-main">
        <span class="ch.ch_no">{start + idx + 1}.</span>
        <span class="title">{chap.title}</span>
        <span class="c_len"
          >(<span class="fg-warn">{chap.ztext.length}</span> chữ)</span>
        <span class="ch_no"
          >Vị trí: <span class="fg-warn">{chap.ch_no}</span></span>
      </div>

      {#if chap.chdiv}
        <div class="chap-secd">
          <span class="chdiv">Tên tập: <span>{chap.chdiv}</span></span>
        </div>
      {/if}
    </div>
  {/each}

  {#if pgmax > 0}
    <footer class="pagi">
      <button
        class="m-btn _sm"
        on:click={() => (pg_no = pg_no - 1)}
        disabled={pg_no < 2}>
        <SIcon name="chevron-left" />
      </button>

      <button
        class="m-btn _sm"
        class:_primary={pg_no == 1}
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
        on:click={() => (pg_no = pgmax)}
        >{pgmax}
      </button>

      <button
        class="m-btn _sm _primary"
        on:click={() => (pg_no = pg_no + 1)}
        disabled={pg_no >= pgmax}>
        <SIcon name="chevron-right" />
      </button>
    </footer>
  {/if}
</div>

<style lang="scss">
  .chaps {
    overflow-y: scroll;
    flex: 1;
    max-height: calc(100vh - 15rem);
    padding-top: 0.25rem;

    scrollbar-width: thin;
    &::-webkit-scrollbar {
      cursor: pointer;
      width: 8px;
    }
  }

  .chap {
    padding: 0.25rem 0.5rem 0.25rem 0;

    @include border(--bd-soft, $loc: top);

    &:last-child {
      @include border(--bd-soft, $loc: bottom);
    }
  }

  .chap-main {
    display: flex;
    gap: 0.5rem;
    line-height: 1.375rem;
  }

  .ch_no {
    font-weight: 500;
    font-size: rem(12px);
    @include fgcolor(warning, 5);
  }

  .title {
    @include fgcolor(secd);
    // font-weight: 500;
    flex-shrink: 1;
    font-size: rem(14px);
    @include clamp;
    max-width: 25ch;
  }

  .ch_no {
    font-size: rem(14px);

    // margin-left: auto;
    @include fgcolor(tert);
    font-style: italic;
  }

  .chdiv,
  .c_len,
  .ch_no {
    @include fgcolor(tert);
    font-style: italic;
    font-size: rem(14px);
  }

  // .c_len,
  .ch_no {
    margin-left: auto;
  }

  .fg-warn {
    @include fgcolor(warning, 5);
  }

  .pagi {
    margin-top: 0.75rem;
    @include flex-ca();
    gap: 0.5rem;

    input {
      text-align: center;
      width: 3.5rem;
    }
  }

  .count {
    @include fgcolor(tert);
    font-size: rem(15px);
  }
</style>
