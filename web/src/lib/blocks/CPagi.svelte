<script>
  export let opts = new URLSearchParams()
  export let path = '/'
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

  function make_url(pnow) {
    const query = gen_params(pnow)
    return query ? `${path}?${query}` : path
  }

  function gen_params(pnow) {
    if (pnow != 1) {
      opts.set('page', pnow)
    } else {
      opts.delete('page')
    }
    return opts.toString()
  }
</script>

<div class="pagi">
  {#each pagi as pnow}
    {#if pnow != pgidx}
      <a class="m-button" href={make_url(pnow)}><span>{pnow}</span></a>
    {:else}
      <div class="m-button _disable">
        <span>{pnow}</span>
      </div>
    {/if}
  {/each}

  {#if pgidx < pgmax}
    <a class="m-button _primary" href={make_url(pgidx + 1)}>
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
