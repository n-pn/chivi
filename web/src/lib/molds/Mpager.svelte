<script context="module">
  import { goto } from '$app/navigation'

  export class Pager {
    constructor(path, query = '') {
      this.path = path
      this.query = new URLSearchParams(query.toString())
    }

    url(opts = {}) {
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

  export function jumpto(node, [replaceState = false, scrollTo = null]) {
    const action = async (event) => {
      if (replaceState || scrollTo) {
        event.preventDefault()
        event.stopPropagation()

        const href = event.target.getAttribute('href')

        const noscroll = !!scrollTo
        await goto(href, { replaceState, noscroll, keepfocus: false })

        scrollTo?.scrollIntoView({ block: 'start' })

        // console.log('jumped')
      }
    }

    node.addEventListener('click', action)
    return { destroy: () => node.removeEventListener('click', action) }
  }
</script>

<script>
  import SIcon from '$atoms/SIcon.svelte'

  export let pager = new Pager('/')
  export let pgidx = 1
  export let pgmax = 1

  export let replaceState = false
  export let scrollTo = null

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
  {#if pgidx > 1}
    <a
      class="m-button _fill -md"
      href={pager.url({ page: pgidx - 1 })}
      data-kbd="j"
      use:jumpto={[replaceState, scrollTo]}>
      <SIcon name="chevron-left" />
    </a>
  {:else}
    <button class="m-button -md" disabled data-kbd="j">
      <SIcon name="chevron-left" />
    </button>
  {/if}

  {#each build_pagi(pgidx, pgmax) as pgnow}
    {#if pgnow != pgidx}
      <a
        class="m-button _line"
        data-kbd={pgnow == 1 ? 'h' : pgnow == pgmax ? 'l' : ''}
        href={pager.url({ page: pgnow })}
        use:jumpto={[replaceState, scrollTo]}><span>{pgnow}</span></a>
    {:else}
      <button class="m-button" disabled>
        <span>{pgnow}</span>
      </button>
    {/if}
  {/each}

  {#if pgidx < pgmax}
    <a
      class="m-button _primary _fill"
      href={pager.url({ page: pgidx + 1 })}
      data-kbd="k"
      use:jumpto={[replaceState, scrollTo]}>
      <span class="-txt">Kế tiếp</span>
      <SIcon name="chevron-right" />
    </a>
  {:else}
    <button class="m-button" disabled data-kbd="k">
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
    @include fluid(display, none, $md: inline);
  }

  .-md {
    @include fluid(display, none, $md: inline-block);
  }
</style>
