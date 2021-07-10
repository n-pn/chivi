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
  export let pager = new Pager('/')
  export let pgidx = 1
  export let pgmax = 1

  $: pagi = build_pagi(pgidx, pgmax)

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

<div class="pagi">
  {#each pagi as pnow}
    {#if pnow != pgidx}
      <a class="m-button" href={pager.url_for({ page: pnow })}
        ><span>{pnow}</span></a>
    {:else}
      <div class="m-button _disable">
        <span>{pnow}</span>
      </div>
    {/if}
  {/each}

  {#if pgidx < pgmax}
    <a class="m-button _primary" href={pager.url_for({ page: pgidx + 1 })}>
      <span class="-txt">Kế tiếp</span>
    </a>
  {:else}
    <div class="m-button _disable">
      <span class="-txt">Kế tiếp</span>
    </div>
  {/if}
</div>

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
</style>
