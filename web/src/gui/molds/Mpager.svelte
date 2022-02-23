<script context="module" lang="ts">
  import type { Pager } from '$lib/pager'
  export { Pager } from '$lib/pager'

  function make_pages(pgidx: number, pgmax: number) {
    const res = []
    const min = pgidx > 2 ? pgidx - 2 : 1
    const max = min + 5 <= pgmax ? min + 5 : pgmax

    const min2 = max - 5 > 1 ? max - 5 : 1

    for (let idx = min2; idx <= max; idx++) res.push(idx)
    if (res[0] > 1) res[0] = 1

    const max2 = res.length - 1
    if (res[max2] < pgmax) res[max2] = pgmax

    return res
  }
</script>

<script lang="ts">
  import SIcon from '$gui/atoms/SIcon.svelte'

  export let pager: Pager
  export let pgidx = 1
  export let pgmax = 1

  export let on_navigate = (_e: Event, _pg: number) => {}
</script>

<nav class="pagi">
  {#if pgidx > 1}
    <a
      class="m-btn _fill -md"
      href={pager.gen_url({ pg: pgidx - 1 })}
      data-kbd="j"
      on:click={(evt) => on_navigate(evt, pgidx - 1)}>
      <SIcon name="chevron-left" />
    </a>
  {:else}
    <button class="m-btn -md" disabled data-kbd="j">
      <SIcon name="chevron-left" />
    </button>
  {/if}

  {#each make_pages(pgidx, pgmax) as pgnow}
    {#if pgnow != pgidx}
      <a
        class="m-btn _line"
        href={pager.gen_url({ pg: pgnow })}
        data-kbd={pgnow == 1 ? 'h' : pgnow == pgmax ? 'l' : ''}
        on:click={(evt) => on_navigate(evt, pgnow)}><span>{pgnow}</span></a>
    {:else}
      <button class="m-btn" disabled>
        <span>{pgnow}</span>
      </button>
    {/if}
  {/each}

  {#if pgidx < pgmax}
    <a
      class="m-btn _primary _fill"
      href={pager.gen_url({ pg: pgidx + 1 })}
      data-kbd="k"
      on:click={(evt) => on_navigate(evt, pgidx + 1)}>
      <span class="-txt">Kế tiếp</span>
      <SIcon name="chevron-right" />
    </a>
  {:else}
    <button class="m-btn" disabled data-kbd="k">
      <span class="-txt">Kế tiếp</span>
      <SIcon name="chevron-right" />
    </button>
  {/if}
</nav>

<style lang="scss">
  .pagi {
    @include flex($center: horz, $gap: 0.5rem);
  }

  .-txt {
    @include bps(display, none, $tm: inline);
  }

  .-md {
    @include bps(display, none, $tm: inline-block);
  }
</style>
