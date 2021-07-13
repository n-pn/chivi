<script context="module">
  export class Pager {
    constructor(path, query = '') {
      this.path = path
      this.query = new URLSearchParams(query.toString())
    }

    url_for(opts) {
      for (const key in opts) {
        const val = opts[key]
        if (val === null) this.query.delete(key)
        else this.query.set(key, val)
      }

      if (this.query.get('page') == 1) this.query.delete('page')
      const query = this.query.toString()
      return query ? this.path + '?' + query : this.path
    }
  }
</script>

<script>
  import SIcon from '$atoms/SIcon.svelte'

  export let pager = new Pager('/')
  export let pgidx = 1
  export let pgmax = 1

  function build_pagi(pgidx, pgmax) {
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

<nav class="pagi">
  {#each build_pagi(pgidx, pgmax) as pgnow}
    {#if pgnow != pgidx}
      <a class="m-button _line" href={pager.url_for({ page: pgnow })}
        ><span>{pgnow}</span></a>
    {:else}
      <button class="m-button" disabled>
        <span>{pgnow}</span>
      </button>
    {/if}
  {/each}

  {#if pgidx < pgmax}
    <a
      class="m-button _primary _fill"
      href={pager.url_for({ page: pgidx + 1 })}>
      <span class="-txt">Kế tiếp</span>
      <SIcon name="chevron-right" />
    </a>
  {:else}
    <button class="m-button" disabled>
      <span class="-txt">Kế tiếp</span>
      <SIcon name="chevron-right" />
    </button>
  {/if}
</nav>

<style lang="scss">
  .pagi {
    display: flex;
    justify-content: center;

    .m-button + .m-button {
      // width: 5rem;
      // text-align: center;
      margin-left: 0.5rem;
    }
  }

  .-txt {
    @include fluid(display, none, $md: inline);
  }
</style>
