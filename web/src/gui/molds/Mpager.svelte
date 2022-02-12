<script context="module" lang="ts">
  import { goto } from '$app/navigation'

  export class Pager {
    url: URL
    dfs: object

    constructor(url: URL, dfs: object = { pg: 1 }) {
      this.url = url
      this.dfs = dfs
    }

    get(key: string) {
      return this.url.searchParams.get(key) || this.dfs[key]
    }

    make_url(opts = {}) {
      const query = new URLSearchParams(this.url.searchParams)

      for (const key in opts) {
        const val = opts[key]
        if (val && val != this.dfs[key]) {
          query.set(key, val)
        } else {
          query.delete(key)
        }
      }

      const qs = query.toString()
      return qs ? this.url.pathname + '?' + qs : this.url.pathname
    }
  }

  export function navigate(node: Element, { href = null, replace, scrollto }) {
    const opts = { replaceState: replace, noscroll: !!scrollto }

    const action = async (event: Event) => {
      href = href || node.getAttribute('href')
      await goto(href, opts)
      // console.log({ href, replace, scrollto })

      event.preventDefault()
      event.stopPropagation()

      if (scrollto) {
        const elem = document.querySelector(scrollto)
        elem?.scrollIntoView({ block: 'start' })
      }
    }

    if (!replace && !scrollto) return { destroy: () => {} } // return noop

    node.addEventListener('click', action)
    return { destroy: () => node.removeEventListener('click', action) }
  }

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

  export let pager
  export let pgidx = 1
  export let pgmax = 1
  export let _navi = { replace: false, scrollto: null }
</script>

<nav class="pagi">
  {#if pgidx > 1}
    <a
      class="m-btn _fill -md"
      href={pager.make_url({ pg: pgidx - 1 })}
      data-kbd="j"
      sveltekit:noscroll={_navi.scrollto}
      use:navigate={_navi}>
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
        href={pager.make_url({ pg: pgnow })}
        data-kbd={pgnow == 1 ? 'h' : pgnow == pgmax ? 'l' : ''}
        sveltekit:noscroll={_navi.scrollto}
        use:navigate={_navi}><span>{pgnow}</span></a>
    {:else}
      <button class="m-btn" disabled>
        <span>{pgnow}</span>
      </button>
    {/if}
  {/each}

  {#if pgidx < pgmax}
    <a
      class="m-btn _primary _fill"
      href={pager.make_url({ pg: pgidx + 1 })}
      data-kbd="k"
      sveltekit:noscroll={_navi.scrollto}
      use:navigate={_navi}>
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
