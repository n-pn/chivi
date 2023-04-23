<script context="module" lang="ts">
  import { onDestroy } from 'svelte'
  import { writable, get } from 'svelte/store'
  import { api_call, api_get } from '$lib/api_call'

  import MtData from '$lib/mt_data'
  import { ztext, zfrom, zupto, vdict } from '$lib/stores'

  import { ctrl as upsert } from '$gui/parts/Upsert.svelte'

  export const ctrl = {
    ...writable({ actived: false, enabled: false }),
    hide: (enabled = true) => ctrl.set({ enabled, actived: false }),
    show(forced = true) {
      const { enabled, actived } = get(ctrl)
      if (actived || forced || enabled) ctrl.set({ enabled, actived: true })
    },
  }
</script>

<script lang="ts">
  import SIcon from '$gui/atoms/SIcon.svelte'
  import Slider from '$gui/molds/Slider.svelte'

  export let on_destroy = () => {}
  onDestroy(on_destroy)

  type Entry = [number, Record<string, string>]
  let entries_cache: Record<string, Entry[]> = {}

  let hv_html_cache: Record<string, any> = {}
  let zh_html_cache: Record<string, any> = {}

  let entries = []
  let current: Entry[] = []

  let hv_html = ''
  let zh_html = ''

  $: if ($ctrl.actived) {
    zh_html = zh_html_cache[$ztext] ||= MtData.render_zh($ztext)
    get_hanviet($ztext)
    fetch_terms($ztext, $zfrom)
    if ($zfrom >= 0) update_focus()
  }

  async function fetch_terms(input: string, zfrom: number) {
    entries = entries_cache[$ztext] ||= []

    const range = []
    if (!entries[zfrom]) range.push(zfrom)

    let z_max = input.length
    if (z_max > 10) z_max = 10

    for (let index = 1; index < z_max; index++) {
      const lower = zfrom - index
      if (lower >= 0 && !entries[lower]) range.push(lower)

      const upper = zfrom + index
      if (upper < z_max && !entries[upper]) range.push(upper)

      if (range.length > 10) break
    }

    if (range.length != 0) {
      try {
        const url = `/_sp/lookup?vd_id=${$vdict.vd_id}`
        const res = await api_call(url, { input, range }, 'PUT')
        for (let index in res) entries[index] = res[index]
      } catch (ex) {
        console.log(ex)
      }
    }

    setTimeout(update_focus, 20)
  }

  async function get_hanviet(input: string) {
    hv_html = hv_html_cache[input]
    if (hv_html) return

    const url = `/_sp/hanviet?mode=mtl`
    const headers = { 'content-type': 'text/plain' }

    const res = await fetch(url, { method: 'PUT', headers, body: input })
    const res_text = await res.text()

    if (!res.ok) console.log(res_text)
    else hv_html_cache[input] = hv_html = new MtData(res_text).render_hv()
  }

  function handle_click({ target }) {
    if (target.nodeName == 'X-N') $zfrom = +target.dataset.l
  }

  let viewer = null
  const focused = []

  function update_focus() {
    if (!viewer) return

    current = entries[$zfrom] || []
    if (current.length == 0) $zupto = $zfrom
    else $zupto = $zfrom + +current[0][0]

    focused.forEach((x) => x.classList.remove('focus'))
    focused.length = 0

    for (let idx = $zfrom; idx < $zupto; idx++) {
      const nodes = viewer.querySelectorAll(`x-n[data-l="${idx}"]`)

      nodes.forEach((x: HTMLElement) => {
        focused.push(x)
        x.classList.add('focus')
        x.scrollIntoView({ block: 'end', behavior: 'smooth' })
      })
    }
  }
</script>

<Slider
  class="lookup"
  _sticky={true}
  bind:actived={$ctrl.actived}
  --slider-width="30rem">
  <svelte:fragment slot="header-left">
    <div class="-icon">
      <SIcon name="compass" />
    </div>
    <div class="-text">Giải nghĩa</div>
  </svelte:fragment>

  <svelte:fragment slot="header-right">
    <button class="-btn" data-kbd="`" on:click={() => ctrl.hide(false)}>
      <SIcon name="circle-off" />
    </button>
  </svelte:fragment>

  <section class="input" bind:this={viewer}>
    <!-- svelte-ignore a11y-click-events-have-key-events -->
    <div class="input-nav _zh" on:click={handle_click} lang="zh">
      {@html zh_html}
    </div>

    <!-- svelte-ignore a11y-click-events-have-key-events -->
    <div class="input-nav _hv" on:click={handle_click}>
      {@html hv_html}
    </div>
  </section>

  <section class="terms">
    {#each current as [size, terms]}
      <div class="entry">
        <h3 class="word" lang="zh">
          <span class="entry-key"
            >{$ztext.substring($zfrom, $zfrom + size)}</span>
          <button
            class="m-btn _sm btn-edit"
            on:click={() => upsert.show(0, 1, $zfrom, $zfrom + size)}>
            <SIcon name="edit" />
          </button>
        </h3>

        {#each Object.entries(terms) as [dict, defn]}
          {#if defn}
            {@const defns = defn.split('\n')}

            <div class="item">
              <h4 class="name">{dict}</h4>
              {#each defns as defn}
                <p class="term">{defn}</p>
              {/each}
            </div>
          {/if}
        {/each}
      </div>
    {/each}
  </section>
</Slider>

<style lang="scss">
  .input-nav {
    padding: 0.375rem 0.75rem;
    margin-top: 0.5rem;
    @include border($loc: top);
    @include bgcolor(tert);
    @include scroll;

    &._zh {
      $line: 1.5rem;
      line-height: $line;
      max-height: $line * 3 + 0.75rem;
      @include ftsize(lg);
      @include border($loc: bottom);
    }

    &._hv {
      $line: 1.25rem;
      line-height: $line;
      max-height: $line * 3 + 0.75rem;
    }
  }

  :global {
    x-n {
      --color: #{color(primary, 5)};
      cursor: pointer;

      &:hover {
        background: linear-gradient(to top, var(--color) 0.75px, transparent 0);
      }

      &.focus {
        color: var(--color);
      }
    }
  }

  .terms {
    @include scroll;
    flex: 1;
  }

  .word {
    font-weight: 600;
    line-height: 2rem;
    @include ftsize(md);
  }

  h3 {
    display: flex;
  }

  .btn-edit {
    margin-left: auto;
    background: transparent;
  }

  h4 {
    font-weight: 500;
    text-transform: uppercase;
    @include fgcolor(tert);
    @include ftsize(sm);
  }

  .entry {
    @include fgcolor(secd);
    padding: 0.5rem 0.75rem;
    // padding-top: 0;
    @include border($loc: top);
  }

  .item {
    margin-top: 0.25rem;

    & + & {
      margin-top: 0.5rem;
    }

    p + p {
      margin-top: 0.25rem;
    }
  }

  .term {
    @include flex($gap: 0.25rem);
    flex-wrap: wrap;
    line-height: 1.5rem;
  }

  // term-tag {
  //   display: inline-block;
  //   @include bdradi(0.75rem);
  //   @include ftsize(sm);
  //   @include linesd(--bd-main);
  //   @include fgcolor(tert);
  //   font-weight: 500;
  //   padding: 0 0.5rem;
  // }

  // term-dic {
  //   display: inline-flex;
  //   @include ftsize(sm);
  //   @include fgcolor(tert);
  //   padding: 0.25rem 0;
  // }
</style>
