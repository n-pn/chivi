<script context="module">
  import { MtData } from '$lib/mt_data'
  import { writable } from 'svelte/store'
  import { dict_lookup } from '$api/dictdb_api'

  export const enabled = writable(false)
  export const actived = writable(false)

  const input = writable(null)
  const lower = writable(0)
  const upper = writable(0)

  export function activate(enable, mt_data, _lower, _upper) {
    if (mt_data) {
      input.set(mt_data)
      lower.set(_lower || 0)
      upper.set(_upper || mt_data.data[0][0].length)
    }

    actived.set(true)
    if (enable) enabled.set(true)
  }
</script>

<script>
  import SIcon from '$atoms/SIcon.svelte'
  import Slider from '$molds/Slider.svelte'

  export let dname = 'various'
  // export let label = 'Tổng hợp'

  let hanviet = null
  let entries = []
  let current = []

  let hv_text = ''

  $: if ($input) update_lookup($input)
  $: zh_text = $input?.render_zh() || ''

  function highlight_focused(lower, upper) {
    document
      .querySelectorAll(`.mtl x-v`)
      .forEach((x) => x.classList.remove('_active'))

    for (let idx = lower; idx < upper; idx++) {
      const nodes = document.querySelectorAll(`.mtl x-v[data-p="${idx}"]`)
      nodes.forEach((x) => {
        x.classList.add('_active')
        x.scrollIntoView({ block: 'start' })
      })
    }
  }

  async function update_lookup(input) {
    const [err, data] = await dict_lookup(fetch, input.orig, dname)
    if (err) return

    entries = data.entries
    hanviet = new MtData(data.hanviet)
    hv_text = hanviet.render_hv()
    $upper = update_focus($lower)
    setTimeout(() => highlight_focused($lower, $upper), 10)
  }

  function handle_click({ target }) {
    const name = target.nodeName
    if (name == 'X-V') $lower = +target.dataset.p
    $upper = update_focus($lower)
    highlight_focused($lower, $upper)
  }

  function update_focus(lower) {
    if (entries.length < lower) {
      current = []
      return lower
    } else {
      current = entries[lower]
      if (current.length == 0) return lower
      return lower + +current[0][0]
    }
  }
</script>

<Slider _rwidth={30} _sticky={true} bind:actived={$actived}>
  <svelte:fragment slot="header-left">
    <div class="-icon">
      <SIcon name="compass" />
    </div>
    <div class="-text">Giải nghĩa</div>
  </svelte:fragment>

  <button slot="header-right" class="-btn" on:click={() => ($enabled = false)}>
    <SIcon name="circle-off" />
  </button>

  <section class="lookup">
    <div class="mtl _zh" on:click={handle_click} lang="zh">
      {@html zh_text}
    </div>

    <div class="mtl _hv" on:click={handle_click}>
      {@html hv_text}
    </div>

    {#each current as [size, entries]}
      <div class="entry">
        <h3 class="word" lang="zh">{$input.orig.substr($lower, size)}</h3>
        {#each Object.entries(entries) as [name, items]}
          {#if items.length > 0}
            <div class="item">
              <h4 class="name">{name}</h4>
              {#if name == 'vietphrase'}
                <p class="viet">
                  {@html items.map((x) => x || '<em>(đã xoá)</em>').join('; ')}
                </p>
              {:else}
                {#each items as line}
                  <p class="term">{line}</p>
                {/each}
              {/if}
            </div>
          {/if}
        {/each}
      </div>
    {/each}
  </section>
</Slider>

<style lang="scss">
  .mtl {
    padding: 0.375rem 0.75rem;
    @include bgcolor(tert);
    overflow-y: auto;
    scrollbar-width: thin;
    &::-webkit-scrollbar {
      cursor: pointer;
      width: 8px;
    }

    &._zh {
      line-height: 1.375rem;
      max-height: #{1.375rem * 4 + 0.5rem};
    }

    &._hv {
      margin-top: var(--gutter-sm);
      line-height: 1.25rem;
      max-height: 3.25rem;
      // @include clamp($lines: 2);
    }
  }

  .word {
    font-weight: 600;
    line-height: 2rem;
    @include ftsize(md);
  }

  h4 {
    font-weight: 500;
    text-transform: uppercase;
    @include fgcolor(tert);
    @include ftsize(sm);
  }

  .entry {
    @include fgcolor(secd);
    padding: 0.375rem 0.75rem;
    // padding-top: 0;
    @include border($sides: bottom);
    &:last-child {
      border: none;
    }
  }

  .item {
    & + & {
      margin-top: var(--gutter-xs);
    }
  }

  .term {
    line-height: 1.5rem;
  }
</style>
