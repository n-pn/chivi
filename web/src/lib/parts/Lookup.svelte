<script context="module">
  import { onDestroy } from 'svelte'
  import { writable } from 'svelte/store'
  import CvData from '$lib/cv_data'

  import { dict_lookup } from '$api/dictdb_api'
  import { create_input } from '$utils/create_stores'

  import { ptnames } from '$parts/Postag.svelte'
  import { ctrl as upsert } from '$parts/Upsert.svelte'

  const input = create_input()

  export const ctrl = {
    ...writable({ actived: false, enabled: false }),
    activate(data, enabled = false) {
      input.put(data)
      ctrl.set({ enabled, actived: true })
    },
    deactivate: (enabled = true) => ctrl.set({ enabled, actived: false }),
  }
</script>

<script>
  import SIcon from '$atoms/SIcon.svelte'
  import Gslide from '$molds/Gslide.svelte'

  export let dname = 'various'
  export let on_destroy = () => {}
  // export let label = 'Tổng hợp'

  onDestroy(on_destroy)

  let entries = []
  let current = []

  let { lower, upper } = $input
  $: if ($input && $ctrl.actived) update_lookup($input)

  let hv_html = ''
  let zh_html = ''

  $: if (lower >= 0 && $input.upper > 0) update_focus(lower)

  async function update_lookup(input) {
    if (!input.ztext) return
    zh_html = CvData.render_zh(input.ztext)
    lower = input.lower
    upper = input.upper

    const [lookup_err, data] = await dict_lookup(fetch, input.ztext, dname)
    if (lookup_err) return console.log({ lookup_err })

    entries = data.entries

    for (const entry of entries) {
      for (const term of entry) {
        const viet = term[1].vietphrase
        if (viet) term[1].vietphrase = viet.map((x) => x.split('\t'))
      }
    }

    hv_html = new CvData(data.hanviet).render_hv()
    update_focus(lower)
  }

  function handle_click({ target }) {
    const name = target.nodeName
    if (name == 'X-N') lower = +target.dataset.l
  }

  function update_focus(lower) {
    current = entries[lower] || []

    if (current.length == 0) upper = lower
    else upper = lower + +current[0][0]
    highlight_focused(lower, upper)
  }

  let viewer = null
  let focused = []

  function highlight_focused(lower, upper) {
    if (!viewer) return
    focused.forEach((x) => x.classList.remove('focus'))
    focused = []

    for (let idx = lower; idx < upper; idx++) {
      const nodes = viewer.querySelectorAll(`x-n[data-l="${idx}"]`)
      nodes.forEach((x) => {
        focused.push(x)
        x.classList.add('focus')
        x.scrollIntoView({ block: 'end', behavior: 'smooth' })
      })
    }
  }
</script>

<Gslide
  _klass="lookup"
  _rwidth={30}
  _sticky={true}
  bind:actived={$ctrl.actived}>
  <svelte:fragment slot="header-left">
    <div class="-icon">
      <SIcon name="compass" />
    </div>
    <div class="-text">Giải nghĩa</div>
  </svelte:fragment>

  <svelte:fragment slot="header-right">
    <button class="-btn" on:click={() => ctrl.deactivate(false)}>
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
          <entry-key>{$input.ztext.substr(lower, size)}</entry-key>
          <entry-btn
            class="m-btn _sm"
            role="button"
            on:click={() =>
              upsert.activate([$input.ztext, lower, lower + size])}>
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
                <term-tag>{ptnames[tag] || 'Chưa phân loại'}</term-tag>
              </p>
            {/each}
          </div>
        {/if}

        {#each ['trungviet', 'cc_cedict'] as dname}
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
</Gslide>

<style lang="scss">
  .input-nav {
    padding: 0.375rem 0.75rem;
    margin-top: 0.5rem;
    @include border($loc: top);
    @include bgcolor(tert);
    @include scroll;

    &._zh {
      $line: 1.375rem;
      line-height: $line;
      max-height: $line * 2 + 0.75rem;
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
