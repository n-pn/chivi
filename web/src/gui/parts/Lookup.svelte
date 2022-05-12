<script context="module" lang="ts">
  import { onDestroy } from 'svelte'
  import { writable, get } from 'svelte/store'
  import { api_call } from '$lib/api_call'

  import MtData from '$lib/mt_data'
  import { ztext, zfrom, zupto, vdict } from '$lib/stores'

  import pt_labels from '$lib/consts/postag_labels.json'

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

  let entries_cache: Record<string, any> = {}
  let hv_html_cache: Record<string, any> = {}
  let zh_html_cache: Record<string, any> = {}

  let entries = []
  let current = []

  let hv_html = ''
  let zh_html = ''

  let clear_cache: ReturnType<typeof setTimeout> | null = null

  $: if ($ctrl.actived) {
    zh_html = zh_html_cache[$ztext] ||= MtData.render_zh($ztext)
    get_hanviet($ztext)
    fetch_terms($ztext, $zfrom)
    if ($zfrom >= 0) update_focus()

    if (!clear_cache) {
      clear_cache = setTimeout(() => {
        entries_cache = {}
        hv_html_cache = {}
        zh_html_cache = {}
        clear_cache = null
      }, 300000) // clear cache after 5 minutes
    }
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
      const url = `dicts/${$vdict.dname}/lookup`
      const [err, data] = await api_call(fetch, url, { input, range }, 'PUT')
      if (err) return console.log({ err })

      for (let index in data) {
        const entry = data[index]
        entries[index] = entry
        for (const term of entry) {
          const viet = term[1].vietphrase as Array<string>
          if (viet) term[1].vietphrase = viet.map((x) => x.split('\t'))
        }
      }
    }

    setTimeout(update_focus, 20)
  }

  async function get_hanviet(input: string) {
    hv_html = hv_html_cache[input]

    if (!hv_html) {
      const url = `qtran/hanviet`
      const [err, data] = await api_call(fetch, url, { input }, 'PUT')
      if (err) return console.log({ err })
      hv_html_cache[input] = hv_html = new MtData(data.hanviet).render_hv()
    }
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
    <div class="input-nav _zh" on:click={handle_click} lang="zh">
      {@html zh_html}
    </div>

    <div class="input-nav _hv" on:click={handle_click}>
      {@html hv_html}
    </div>
  </section>

  <section class="terms">
    {#each current as [size, terms]}
      <div class="entry">
        <h3 class="word" lang="zh">
          <entry-key>{$ztext.substring($zfrom, $zfrom + size)}</entry-key>
          <entry-btn
            class="m-btn _sm"
            role="button"
            on:click={() => upsert.show(0, 1, $zfrom, $zfrom + size)}>
            <SIcon name="edit" />
            <span>{terms.vietphrase ? 'Sửa' : 'Thêm'}</span>
          </entry-btn>
        </h3>

        {#if terms.vietphrase}
          <div class="item">
            <h4 class="name">vietphrase</h4>
            {#each terms.vietphrase as [val, tag, dic]}
              <p class="term">
                <term-dic>
                  <SIcon name={dic % 2 ? 'book' : 'world'} />
                  <SIcon name={dic > 3 ? 'user' : 'share'} />
                </term-dic>

                <term-val>{val || '<đã xoá>'}</term-val>
                <term-tag>{pt_labels[tag] || 'Chưa phân loại'}</term-tag>
              </p>
            {/each}
          </div>
        {/if}

        {#each ['trungviet', 'cc_cedict', 'trich_dan'] as dname}
          {#if terms[dname]}
            <div class="item">
              <h4 class="name">{dname}</h4>
              {#each terms[dname] as line}
                <p class="term">{line}</p>
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

  entry-btn {
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

  term-tag {
    display: inline-block;
    @include bdradi(0.75rem);
    @include ftsize(sm);
    @include linesd(--bd-main);
    @include fgcolor(tert);
    font-weight: 500;
    padding: 0 0.5rem;
  }

  term-dic {
    display: inline-flex;
    @include ftsize(sm);
    @include fgcolor(tert);
    padding: 0.25rem 0;
  }
</style>
